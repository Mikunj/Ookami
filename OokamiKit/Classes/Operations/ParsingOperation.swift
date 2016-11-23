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
    
    public typealias ParsedObjects = [String: [Any]]
    public typealias ParseCompletionBlock = (ParsedObjects?, [JSON]?) -> Void
    public typealias ParserBlock = (JSON) -> Object?
    public typealias RealmBlock = () -> Realm
    
    public let realmBlock: RealmBlock
    public let json: JSON
    let parseComplete: ParseCompletionBlock
    var parsers: [String: ParserBlock] = [:]
    
    /// Dictionary of objects that we have parsed.
    /// Type of the object is the key and the value is an array of ids that were parsed for that type
    var parsedObjects: ParsedObjects = [:]
    
    
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
    ///   - completion: The completion block. 
    ///         Passes a dictionary of parsed objects (key: object type, value: array of ids)
    ///         Passes an array of JSON objects that failed to be parsed, or nil if everything was parsed
    public init(json: JSON, realm: @escaping RealmBlock, completion: @escaping ParseCompletionBlock) {
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
    
    /// Add a parsed object to the parsedObjects dictionary
    ///
    /// - Parameters:
    ///   - object: The object
    ///   - type: The key to use for the dictionary.
    func add(parsedObject object: Object, forType type: String) {
        if !parsedObjects.keys.contains(type) {
            parsedObjects[type] = []
        }
        
        if let key = object[type(of: object).primaryKey() ?? ""] {
            parsedObjects[type]!.append(key)
        }
    }
    
    /// Parse a json array of objects.
    /// Note: This needs to be called in a write transaction.
    ///
    /// - Parameters:
    ///   - json: The JSON array
    ///   - realm: The realm instance
    /// - Returns: An array of objects that failed to parse
    func parseArray(json: JSON, realm: Realm) -> [JSON]? {
        
        //Be 100% sure that we have an array
        guard json.type == .array else {
            return nil
        }
        
        var failed: [JSON] = []
        
        //Go through all the objects and parse them
        for object in json.arrayValue {
            
            //Parse the dictionary object in the array
            if !parseDictionary(json: object, realm: realm) {
                failed.append(object)
            }
        }
        
        return failed
    }
    
    /// Parse a json dictionary object.
    /// Note: This needs to be called in a write transaction.
    ///
    /// - Parameters:
    ///   - json: The JSON dictionary
    ///   - realm: The realm instance
    /// - Returns: Whether the object was parsed or not.
    func parseDictionary(json: JSON, realm: Realm) -> Bool {
        //Make sure the object is a dictionary
        guard json.type == .dictionary else {
            return false
        }
        
        //Get the object type
        let type = json["type"].stringValue
        
        //Make sure we have the parser and the parsed object
        guard let parser = parsers[type],
            let parsedObject = parser(json) else {
            return false
        }
        
        //Add this object to the parsed list.
        //We add this here because we 'parsed' it but the object decides whether it should be stored or not
        add(parsedObject: parsedObject, forType: type)
        
        //Check if we can store the object. If so then add it to realm
        if realm.isInWriteTransaction {
            if parsedObject.canBeStored() { realm.add(parsedObject, update: true) }
        }
        
        return true
    }
    
    /// Parse an arrar or dictionary of JSON objects.
    ///
    /// - Parameter json: A JSON array or dictionary contaning object(s)
    /// - Returns: An array of objects that failed to parse, or nil if an array/dictionary wasn't passed in
    func parse(json: JSON) -> [JSON]? {
        
        let realm = realmBlock()
        var failed: [JSON] = []
        
        //Make sure we're only dealing with arrays and dictionaries
        guard json.type == .dictionary || json.type == .array else {
            return nil
        }
        
        realm.beginWrite()
        
        switch json.type {
            case .array:
                let f = parseArray(json: json, realm: realm)
                if f != nil {
                    failed.append(contentsOf: f!)
                }
                break
            case .dictionary:
                if !parseDictionary(json: json, realm: realm) {
                    failed.append(json)
                }
                break
            default:
                break
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
            self.parseComplete(nil, [json])
            self.completeOperation()
            return
        }
        
        //Register the parsers
        registerParsers()
        
        var failed: [JSON] = []
        
        let arrays = [included, data]
        
        //Parse objects from included and data fields
        for array in arrays {
            if array.exists() {
                if let result = parse(json: array) {
                    failed += result
                } else {
                    failed.append(array)
                }
            }
        }
        
        if !isCancelled {
            let fail: [JSON]? = failed.isEmpty ? nil : failed
            self.parseComplete(parsedObjects, fail)
        }
        
        self.completeOperation()
    }
    
    override public func cancel() {
        super.cancel()
        if realmBlock().isInWriteTransaction {
            realmBlock().cancelWrite()
        }
        self.completeOperation()
    }
    
}
