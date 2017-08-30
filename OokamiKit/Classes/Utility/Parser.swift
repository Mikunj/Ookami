//
//  Parser.swift
//  Ookami
//
//  Created by Maka on 26/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/// A class to parse objects
public class Parser {
    
    public typealias ParserBlock = (JSON) -> Object?
    
    //The parsers to use
    var parsers: [String: ParserBlock] = [:]
    
    public init() {
        registerParsers()
    }
    
    /// Initialize all the parsers
    private func registerParsers() {
        register(object: Anime.self)
        register(object: Manga.self)
        register(object: User.self)
        register(object: Genre.self)
        register(object: LibraryEntry.self)
        register(object: MediaRelationship.self)
    }
    
    /// Register a parser. This parser's type will be used to determine which objects get passed to it.
    /// If an object's type matches the parser type then that object will be passed to the `parser` block.
    ///
    /// - Parameters:
    ///   - type: The type string of objects to parse. E.g "anime", "libraryEntries"
    ///   - parser: The parsing block.
    ///             Passes a JSON object and should return the resulting parsed Object.
    ///             If `nil` is passed then this will assume parsing failed.
    public func register(type: String, parser: @escaping ParserBlock) {
        parsers[type] = parser
    }
    
    /// Register a parser with a <JSONParsable, Object> class.
    /// This will use `object.typeString` as the type
    ///
    /// - Parameters:
    ///   - object: The <JSONParsable, Object> class
    public func register<T: Object>(object: T.Type) where T: JSONParsable {
        register(type: T.typeString) { json in
            return T.parse(json: json) as! Object?
        }
    }
    
    /// Parse JSON data on a background thread
    ///
    /// - Parameters:
    ///   - json: the JSON data
    ///   - callback: An block which passes back an array of parsed objects
    public func parse(json: JSON, callback: @escaping ([Object]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let parsed = self.parse(json: json)
            DispatchQueue.main.async {
                callback(parsed)
            }
        }
        
    }
    
    /// Parse JSON data
    ///
    /// - Parameter json: The json data
    /// - Returns: An array of parsed objects
    private func parse(json: JSON) -> [Object] {
        //We need to parse the included objects first then the data objects.
        //This is because some data objects may depend/have a link with the objects inside the `included` array
        //E.g Anime only has genre ids to link to, but the Genre objects are passed in the `included` array
        
        //First check to see that we have data or included else this is a bad JSON file
        let included = json["included"]
        let data = json["data"]
        guard json.type == .dictionary && (included.exists() || data.exists())  else {
            return []
        }
        
        //The results of the other parsers
        var results: [Object] = []
        
        //Parse objects from included and data fields
        for field in [included, data] {
            if field.exists() {
                
                //Parse objects based on the type, since we can have both arrays and dictionary in the json data.
                switch field.type {
                case .dictionary:
                    if let parsed = self.parseDictionary(json: field) {
                        results.append(parsed)
                    }
                    
                case .array:
                    results.append(contentsOf: self.parseArray(json: field))
                    
                default:
                    break
                }
            }
        }
        
        return results
        
    }
    
    /// Parse a json array of objects.
    ///
    /// - Parameters:
    ///   - json: The JSON array
    /// - Returns: An array of parsed objects
    private func parseArray(json: JSON) -> [Object] {
        
        //Be 100% sure that we have an array
        guard json.type == .array else {
            return []
        }
        
        //We use [Object?] and then flatMap it to [Object] later
        var results: [Object?] = []
        
        //Go through all the objects and parse them
        json.arrayValue.forEach {
            //Parse the dictionary object in the array
            results.append(parseDictionary(json: $0))
        }
        
        //This returns only non-nil values
        return results.flatMap { $0 }
    }
    
    /// Parse a json dictionary object.
    ///
    /// - Parameters:
    ///   - json: The JSON dictionary
    ///   - realm: The realm instance
    /// - Returns: The parsed object or nil if it failed to parse
    private func parseDictionary(json: JSON) -> Object? {
        //Make sure the object is a dictionary
        guard json.type == .dictionary else {
            return nil
        }
        
        //Get the object type
        let type = json["type"].stringValue
        
        //Make sure we have the parser and the parsed object
        guard let parser = parsers[type],
            let parsedObject = parser(json) else {
                return nil
        }
        
        return parsedObject
    }
    
}
