//
//  GettableObject.swift
//  Ookami
//
//  Don't mind the name, i am very bad at naming things :( - Mikunj
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

/// A protocol for defining if a object is gettable
public protocol GettableObject {
    //The type of the ID/primary key. E.g: Int, String
    associatedtype IDType
    
    //The type of the return object when fetching multiple
    associatedtype MultipleReturnType
    
    //The object type
    associatedtype T
    
    /// Get an object `T` with an id of type `IDType`
    ///
    /// - Parameter id: The id
    /// - Returns: An object of type `T` or nil if failed to get
    static func get(withId id: IDType) -> T?
    
    
    /// Get objects of type `T` with id of type `IDType`
    ///
    /// - Parameter ids: An array of ids
    /// - Returns: A value of type `MultipleReturnType` which contains objects of type `T`
    static func get(withIds ids: [IDType]) -> MultipleReturnType
    
    /// Get all objects of type T
    ///
    /// - Returns: A value of type `MultipleReturnType` which contains objects of type `T`
    static func all() -> MultipleReturnType
}

/// Apply the extenstion to realm objects
/// This uses `Int` as the default IDType and `Results<T>` for the MultipleReturnType
extension GettableObject where T: Object {

    /// Get a realm object with a given int id
    ///
    /// - Parameter id: The object id
    /// - Returns: A realm object for given id
    public static func get(withId id: Int) -> T? {
        let r = RealmProvider().realm()
        return r.object(ofType: T.self, forPrimaryKey: id)
    }
    
    /// Get realm objects from an array of given int ids
    /// If an object doesn't have a primary key then it will assume 'id' is the value for the primary key
    ///
    /// - Parameter ids: An array of genre ids
    /// - Returns: A Realm result of the realm objects
    public static func get(withIds ids: [Int]) -> Results<T> {
        let key = T.primaryKey() ?? "id"
        let r = RealmProvider().realm()
        return r.objects(T.self).filter("\(key) IN %@", ids)
    }
    
    /// Get all realm objects
    ///
    /// - Returns: A Realm result of all realm objects
    public static func all() -> Results<T> {
        let r = RealmProvider().realm()
        return r.objects(T.self)
    }
    
}
