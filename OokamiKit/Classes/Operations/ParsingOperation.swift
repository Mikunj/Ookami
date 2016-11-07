//
//  ParsingOperation.swift
//  Ookami
//
//  Created by Maka on 7/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// An operation to parse JSON data into objects which then get stored in the realm database
public class ParsingOperation: AsynchronousOperation {
    
    typealias ParseCompletionBlock = ([JSON]) -> Void
    typealias ParserBlock = (JSON) -> Object?
    public typealias RealmBlock = () -> Realm
    
    public let realmBlock: RealmBlock
    public let json: JSON
    let parseComplete: ParseCompletionBlock
    var parsers: [String: ParserBlock] = [:]
    
    
    /// Create a parsing operation.
    ///  - Important: Make sure in the realm closure you don't return a stored instance, rather it should return a brand new realm instance.
    ///
    /// - Example: Instead of `return storedRealm`, you should do `return try! Realm()`.
    ///
    /// This ensures that there will be no threading issues in the operation.
    ///
    /// - Parameters:
    ///   - json: The JSON data to parse
    ///   - realm: A closure which should return a *brand new Realm instance*.
    ///            A closure is called instead of passing in a realm instance because the operation may not be executed in the same thread as the realm instance which was passed in.
    ///   - completion: The completion block. Passes an array of JSON objects that could not be parsed.
    init(json: JSON, realm: @escaping RealmBlock, completion: @escaping ParseCompletionBlock) {
        self.json = json
        self.realmBlock = realm
        self.parseComplete = completion
    }
    
    /// Initialize all the parsers
    func registerParsers() {
        register(object: Anime.self)
        register(object: User.self)
        register(object: Genre.self)
        register(object: LibraryEntry.self)
    }
    
    
    /// Register a parser. This parser's type will be used to determine which objects get passed to it.
    /// If an object's type matches the parser type then that object will be passed to the `parser` block.
    ///
    /// - Parameters:
    ///   - type: The type string of objects to parse. E.g "anime", "libraryEntries"
    ///   - parser: The parsing block. 
    ///             Passes a JSON object and should return the resulting parsed Object.
    ///             If `nil` is passed then this will assume parsing failed.
    func register(type: String, parser: @escaping ParserBlock) {
        parsers[type] = parser
    }
    
    /// Register a parser with a <JSONParsable, Object> class.
    /// This will use `object.typeString` as the type
    ///
    /// - Parameters:
    ///   - object: The <JSONParsable, Object> class
    func register<T: Object>(object: T.Type) where T: JSONParsable {
        register(type: T.typeString) { json in
            return T.parse(json: json) as! Object?
        }
    }
    
    /// Parse an array of JSON objects.
    ///
    /// - Parameter objectArray: An array of JSON objects.
    /// - Returns: An array of objects that failed to parse, or nil if an array wasn't passed in
    func parse(objectArray json: JSON) -> [JSON]? {
        
        //Be 100% sure that we have an array
        guard json.type == .array else {
            return nil
        }
        
        var failed: [JSON] = []
        let realm = realmBlock()
        
        //Start parsing
        realm.beginWrite()
        
        for object in json.arrayValue {
            
            //Check if operation was cancelled
            guard !isCancelled else {
                realm.cancelWrite()
                return []
            }
            
            //Make sure the object is a dictionary
            guard object.type == .dictionary else {
                failed.append(object)
                continue
            }
            
            //Get the object type
            let type = object["type"].stringValue
            
            //Check if we have parser for it, and that it parsed correcrtly
            if let parser = parsers[type],
                let parsedObject = parser(object) {
                realm.add(parsedObject, update: true)
            } else {
                failed.append(object)
            }
        }
        
        try! realm.commitWrite()
        
        return failed
    }
    
    /// Start parsing the JSON data
    override public func main() {
        //We need to parse the included objects first then the data objects.
        //This is because some data objects may depend/have a link with the objects inside the `included` array
        //E.g Anime only has genre ids to link to, but the Genre objects are passed in the `included` array
        
        //First check to see that we have data or included else this is a bad JSON file
        let included = json["included"]
        let data = json["data"]
        guard json.type == .dictionary && (included.exists() || data.exists())  else {
            self.parseComplete([json])
            self.completeOperation()
            return
        }
        
        //Register the parsers
        registerParsers()
        
        var failed: [JSON] = []
        
        let arrays = [included, data]
        //Parse objects
        for array in arrays {
            if array.exists() {
                if let result = parse(objectArray: array) {
                    failed += result
                } else {
                    failed.append(array)
                }
            }
        }
        
        if !isCancelled {
            self.parseComplete(failed)
        }
        
        self.completeOperation()
    }
    
}
