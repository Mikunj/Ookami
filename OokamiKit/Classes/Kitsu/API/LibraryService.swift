//
//  LibraryService.swift
//  Ookami
//
//  Created by Maka on 24/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

public class LibraryService: BaseService {
    
    /// The notifications this service sends
    public enum Notifications: String {
        case addedEntry = "Added Library Entry"
        case deletedEntry = "Deleted Library Entry"
        
        public var name: Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }
    
    /// Create a library entry on the server
    ///
    /// - Parameters:
    ///   - mediaID: The media to add the entry for
    ///   - mediaType: The type of media it is
    ///   - status: The status of the entry
    ///   - completion: The completion block which passes back an entry if successful or an error if not
    public func add(mediaID: Int, mediaType: Media.MediaType, status: LibraryEntry.Status, completion: @escaping (LibraryEntry?, Error?) -> Void) {
        
        guard currentUser.isLoggedIn() else {
            completion(nil, ServiceError.notAuthenticated)
            return
        }
        
        guard let currentUser = currentUser.userID else {
            completion(nil, ServiceError.error(description: "User is logged in but id has not been set"))
            return
        }
        
        //Contruct the params
        let media: [String: Any] = ["data": ["id": mediaID, "type": mediaType.rawValue]]
        let user: [String: Any] = ["data": ["id": currentUser, "type": User.typeString]]
        let params: [String: Any] = ["type": LibraryEntry.typeString,
                                     "attributes": ["status": status.rawValue],
                                     "relationships": [mediaType.rawValue: media, "user": user]]
        let data = ["data": params]
        
        let request = NetworkRequest(relativeURL: Constants.Endpoints.libraryEntries, method: .post, parameters: data, needsAuth: true)
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Failed to get json - LibraryService Add"))
                return
            }
            
            //Add the new entry to the library
            Parser().parse(json: json) { parsed in
                
                let parsedEntry = parsed.first { $0 is LibraryEntry } as? LibraryEntry
                if let parsedEntry = parsedEntry {
                    //Before we add the entry we have to set the userID on it
                    //This is because the entry in the response does not contain the relationship data for user
                    parsedEntry.userID = currentUser
                    
                    //We also set the media on it
                    let media = Media()
                    media.entryID = parsedEntry.id
                    media.id = mediaID
                    media.rawType = mediaType.rawValue
                    parsedEntry.media = media
                }
                
                self.database.addOrUpdate(parsed)
                
                //Send the notification of adding entry
                let id = parsedEntry?.id ?? -1
                NotificationCenter.default.post(name: Notifications.addedEntry.name, object: nil, userInfo: ["id": id, "mediaID": mediaID, "mediaType": mediaType])
                
                completion(parsedEntry, nil)
            }
        }
        
        queue.addOperation(operation)
    }
    
    /// Update a library entry on the server
    ///
    /// - Important: The authenticator must be set or else an error is passed back.
    ///
    /// User must be logged in, and the entry must belong to them, else an error will be passed back.
    ///
    /// - Parameters:
    ///   - entry: The library entry to update
    ///   - completion: The completion block which passes back an entry if successful or an error if not
    public func update(entry: LibraryEntry, completion: @escaping (LibraryEntry?, Error?) -> Void) {
        
        guard currentUser.isLoggedIn() else {
            completion(nil, ServiceError.notAuthenticated)
            return
        }
        
        //Check if the entry belongs to the user
        guard entry.userID == currentUser.userID else {
            completion(nil, ServiceError.error(description: "Cannot update entry that belongs to another user."))
            return
        }
        
        let params = entry.toJSON().dictionaryObject
        let url = "\(Constants.Endpoints.libraryEntries)/\(entry.id)"
        
        let request = NetworkRequest(relativeURL: url, method: .patch, parameters: params, needsAuth: true)
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Failed to get json - LibraryService Update"))
                return
            }
            
            //Add the updated info to the library
            Parser().parse(json: json) { parsed in
                
                let parsedEntry = parsed.first { $0 is LibraryEntry } as? LibraryEntry
                if let parsedEntry = parsedEntry {
                    //Before we add the entry we have to set the userID on it
                    //This is because the entry in the response does not contain the relationship data for user
                    parsedEntry.userID = entry.userID
                }
                
                //Add the objects to the database
                self.database.addOrUpdate(parsed)
                completion(parsedEntry, nil)
            }
        }
        
        queue.addOperation(operation)
    }
    
    /// Delete an entry from the server
    ///
    /// - Parameters:
    ///   - entry: The entry to delete
    ///   - completion: The completion block which passes back an error if something went wrong
    public func delete(entry: LibraryEntry, completion: @escaping (Error?) -> Void) {
        let url = "\(Constants.Endpoints.libraryEntries)/\(entry.id)"
        let request = NetworkRequest(relativeURL: url, method: .delete, needsAuth: true)
        let operation = NetworkOperation(request: request, client: client) { json, error in
            
            if error == nil {
                //Remove the entry from the db, make sure we get it for the current realm
                if let e = LibraryEntry.get(withId: entry.id) {
                    
                    //Send notification for delete
                    if let media = e.media, let type = media.type {
                        NotificationCenter.default.post(name: Notifications.deletedEntry.name, object: nil, userInfo: ["id": entry.id, "mediaID": media.id, "mediaType": type])
                    }
                    self.database.delete(e)
                }
            }
            
            completion(error)
        }
        queue.addOperation(operation)
    }
    
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
        request.include("user")
        request.sort(by: "updated_at", ascending: false)
        
        let library = PaginatedLibrary(request: request, client: client, completion: { objects, error in
            guard error == nil else {
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
        request.include("user")
        request.sort(by: "updated_at", ascending: false)
        
        let operation = FetchLibraryOperation(request: request, client: client, onFetch: { objects in
            
            //Add the objects to the database
            self.database.addOrUpdate(objects)
            
        }, completion: completion)
        
        queue.addOperation(operation)
        
        return LibraryEntry.belongsTo(user: userID, type: type, status: status)
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
            request.include("user")
            request.sort(by: "updated_at", ascending: false)
            return request
        }, onFetch: { objects in
            
            //Add the objects to the database
            self.database.addOrUpdate(objects)
            
            //Track which entries we have recieved
            let entries = objects.filter { $0 is LibraryEntry } as! [LibraryEntry]
            ids.append(contentsOf: entries.map { $0.id })
            
        }, completion: { error in
            
            //Check that we sucessfully fetched all the entries
            if error.isEmpty {
                
                //Update last fetched
                self.updateLastFetched(forUser: userID, type: type)
                
                //Delete any entries not present in the request if we fetched all of them
                //We only delete these if since = Date(timeIntervalSince1970: 0) as then we are 100% sure we have the full library
                if since == Date(timeIntervalSince1970: 0) {
                    UserHelper.deleteEntries(notIn: ids, type: type, forUser: userID)
                }
            }
            
            completion(error)
        })
        
        queue.addOperation(operation)
        
        return LibraryEntry.belongsTo(user: userID, type: type)
    }
    
    /// Update the last fetched library time for a given user
    ///
    /// - Parameters:
    ///   - userID: The user to update for
    ///   - type: The type of library fetched
    private func updateLastFetched(forUser userID: Int, type: Media.MediaType) {
        var fetched = LastFetched.get(withId: userID)
        if fetched != nil {
            //We need to get the unmanaged object, so we can update values
            fetched = LastFetched(value: fetched!)
        } else {
            fetched = LastFetched()
            fetched!.userID = userID
        }
        
        //Update the times
        switch type {
        case .anime:
            fetched!.anime = Date()
        case .manga:
            fetched!.manga = Date()
        }
        
        //Add it to the database
        database.addOrUpdate(fetched!)
    }
    
}
