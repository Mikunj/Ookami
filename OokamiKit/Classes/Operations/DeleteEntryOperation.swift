//
//  DeleteEntryOperation.swift
//  Ookami
//
//  Created by Maka on 12/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

//The different modes for deleting from array
public enum DeleteEntryArrayMode: Int {
    case notInArray = 0
    case inArray
}

/// An operation to delete entries based on certain conditions for a given user
public class DeleteEntryOperation: AsynchronousOperation {
    
    //The different modes
    enum DeleteMode: Int {
        //Delete entries not in array
        case notInArray = 0
        
        //Delete entries in array
        case inArray = 1
        
        //Delete entries that are older than x amount of time
        //E.g Delete entries which are older than 3 days
        case time = 2
    }
    
    //The id of the user
    public let id: Int
    
    //The block to get the realm instance from
    public let realmBlock: () -> Realm
    
    //The array of entry ids
    public internal(set) var entryIds: [Int]? = nil
    
    //The time interval to delete from
    public internal(set) var timeInterval: TimeInterval? = nil
    
    //The mode of the operation
    let mode: DeleteMode
    
    /// Create an operation which deletes all entries that are in/not in the array
    /// Set the completionBlock property to know if operation was completed
    ///  - Important: Make sure in the realm closure you don't return a stored instance, rather it should return a brand new realm instance.
    ///
    /// - Example: Instead of `return storedRealm`, you should do `return try! Realm()`.
    ///
    /// This ensures that there will be no threading issues in the operation.
    ///
    /// - Parameters:
    ///   - userID: The user id to delete entries from
    ///   - ids: The array of entry ids that should be kept
    ///   - mode: The deletion mode.
    ///   - realm: A closure which returns a realm instance
    public init(userID: Int, ids: [Int], mode: DeleteEntryArrayMode = .notInArray, realm: @escaping () -> Realm) {
        self.mode = DeleteMode(rawValue: mode.rawValue)!
        self.id = userID
        self.entryIds = ids
        self.realmBlock = realm
    }
    
    /// Create an operation which deletes all entries that are older than the given time interval
    /// Set the completionBlock property to know if operation was completed
    ///  - Important: Make sure in the realm closure you don't return a stored instance, rather it should return a brand new realm instance.
    ///
    /// - Example: Instead of `return storedRealm`, you should do `return try! Realm()`.
    ///
    /// This ensures that there will be no threading issues in the operation.
    ///
    /// - Parameters:
    ///   - userID: The user id to delete entries from
    ///   - timeInterval: The time interval in seconds (must be positive)
    ///   - realm: A closure which returns a realm instance
    public init(userID: Int, timeInterval: TimeInterval, realm: @escaping () -> Realm) {
        self.id = userID
        self.mode = .time
        
        self.timeInterval = timeInterval
        self.realmBlock = realm
    }
    
    /// Get the predicate for the current mode
    func getPredicate() -> NSPredicate? {
        switch mode {
        case .inArray:
            guard let ids = entryIds else { return nil }
            return NSPredicate(format: "userID = %d AND id IN %@", id, ids)
        case .notInArray:
            guard let ids = entryIds else { return nil }
            return NSPredicate(format: "userID = %d AND NOT id IN %@", id, ids)
        case .time:
            guard let interval = timeInterval else { return nil }
            let date = Date(timeIntervalSinceNow: -interval) as NSDate
            return NSPredicate(format: "userID = %d AND updatedAt < %@", id, date)
        }
    }
    
    override public func main() {
        guard let predicate = getPredicate() else {
            self.completeOperation()
            return
        }
        let realm = realmBlock()
        let entries = LibraryEntry.all().filter(predicate)
        if !isCancelled {
            try! realm.write {
                realm.delete(entries)
            }
        }
        
        self.completeOperation()
    }
    
}
