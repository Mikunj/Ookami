//
//  LibraryService.swift
//  Ookami
//
//  Created by Maka on 24/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

public class LibraryService: BaseService {
    
    /// Get a paginated library for a given user and a given status.
    ///
    /// This will add everything except `LibraryEntry` to the database!
    ///
    /// The returned `PaginatedLibrary` instance can be used to get the `next` or `previous` pages. Keep in mind doing this will call the `onFetch` block when it fetches any entries.
    ///
    /// - Parameters:
    ///   - userID: The user id
    ///   - type: The type of entries
    ///   - status: The status to fetch
    ///   - since: A date, only entries whos lastUpdate time is more recent than this date will be recieved.
    ///   - onFetch: The callback block which gets called anytime entries are fetched. This can be through calls such as `next()` on the returned `PaginatedLibrary` instance.
    /// - Returns: A Paginated Library instance which can be used to make further calls.
    public func getPaginated(userID: Int, type: Media.MediaType, status: LibraryEntry.Status, since: Date = Date(timeIntervalSince1970: 0), onFetch: @escaping ([LibraryEntry]?, Error?) -> Void) -> PaginatedLibrary {
        
        //Make the request
        let request = KitsuLibraryRequest(userID: userID, type: type, status: status, since: since)
        request.include("media", "user")
        
        let library = PaginatedLibrary(request: request, client: client, completion: { objects, error in
            guard error != nil else {
                onFetch(nil, error)
                return
            }
            
            guard let objects = objects else {
                onFetch(nil, ServiceError.error(description: "Failed to get paginated objects"))
                return
            }
            
            //Add everything except Library entries
            let entries = objects.filter { $0 is LibraryEntry } as! [LibraryEntry]
            let filtered = objects.filter { !($0 is LibraryEntry) }
            self.database.addOrUpdate(filtered)
            
            onFetch(entries, nil)
        })
        
        library.start()
        return library
    }
    
    /// Get all the library entries for a given user and a given status.
    ///
    /// This will also add the entries to the database.
    ///
    /// Note that this will disregard the `since` date when returning `Results<LibraryEntry>`
    ///
    ///
    /// - Parameters:
    ///   - userID: The user id.
    ///   - type: The type of library to fetch.
    ///   - status: The status to fetch.
    ///   - since: A date, only entries whos lastUpdate time is more recent than this date will be recieved.
    ///   - completion: A block that gets called once the request finishes or an error occured.
    /// - Returns: A Realm Result of LibraryEntries which then can be used for tracking changes, filtering etc
    @discardableResult public func get(userID: Int, type: Media.MediaType, status: LibraryEntry.Status, since: Date = Date(timeIntervalSince1970: 0), completion: @escaping (Error?) -> Void) -> Results<LibraryEntry> {
        
        //Make the request
        let request = KitsuLibraryRequest(userID: userID, type: type, status: status, since: since)
        request.include("media", "user")
        
        let operation = FetchLibraryOperation(request: request, client: client, onFetch: { objects in
            
            //Add the objects to the database
            self.database.addOrUpdate(objects)
            
        }, completion: completion)
        
        queue.addOperation(operation)
        
        return LibraryEntry.belongsTo(user: userID).filter("media.rawType = %@ AND rawStatus = %@ ", type.rawValue, status.rawValue)
    }
    
    /// Get all the library entries of a user.
    ///
    /// Note: This requires that user is authenticated as it will pass private entries.
    ///
    /// This adds the entries to the database.
    ///
    /// Note that this will disregard the `since` date when returning `Results<LibraryEntry>`
    ///
    /// - Parameters:
    ///   - userID: The user
    ///   - type: The type of entries to fetch
    ///   - since: A date, only entries whos lastUpdate time is more recent than this date will be recieved.
    ///   - completion: The completion block which passes back an array of tuples of type `(LibraryEntry.Status, Error)`, which are set when fetching a specific status fails
    /// - Returns: A Realm Result of LibraryEntries which then can be used for tracking changes, filtering etc
    @discardableResult public func getAll(userID: Int, type: Media.MediaType, since: Date = Date(timeIntervalSince1970: 0), completion: @escaping ([(LibraryEntry.Status, Error)]) -> Void) -> Results<LibraryEntry> {
        
        //An array of ids that we keep track off so that we can delete entries later
        var ids: [Int] = []
        
        let operation = FetchAllLibraryOperation(client: client, request: { status in
            let request = KitsuLibraryRequest(userID: userID, type: type, status: status, since: since, needsAuth: true)
            request.include("media", "user")
            return request
        }, onFetch: { objects in
            
            //Add the objects to the database
            self.database.addOrUpdate(objects)
            
            //Track which entries we have recieved
            let entries = objects.filter { $0 is LibraryEntry } as! [LibraryEntry]
            ids.append(contentsOf: entries.map { $0.id })
            
        }, completion: { error in
            
            //Delete any entries not present in the request if we fetched all of them
            //We only delete these if since = Date(timeIntervalSince1970: 0) as then we are 100% sure we have the full library
            if error.isEmpty && since == Date(timeIntervalSince1970: 0) {
                UserHelper.deleteEntries(notIn: ids, type: type, forUser: userID)
            }
            
            completion(error)
        })
        
        queue.addOperation(operation)
        
        return LibraryEntry.belongsTo(user: userID).filter("media.rawType = %@", type.rawValue)
    }

}