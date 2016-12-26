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
    
    //MARK: GET
    public typealias LibraryCompletion = (Results<LibraryEntry>?, Error?) -> Void
    
    /// Get the library entried for a given user
    ///
    /// - Parameters:
    ///   - userID: The user id
    ///   - type: The type of entries
    ///   - status: The library status to fetch
    ///   - completion: The completion block which gets called everytime a fetch is done, Passes the fetched entries or an error if it occured
    /// - Returns: A PaginatedLibrary instance which can be used for further entry fetching
    public func get(userID: Int, type: Media.MediaType, status: LibraryEntry.Status, completion: @escaping LibraryCompletion) -> PaginatedLibrary? {
        let request = LibraryGETRequest(userID: userID, relativeURL: Constants.Endpoints.libraryEntries)
        request.filter([.media(type: type), .status(status)])
        request.include([.genres, .user])
       /* let library = PaginatedLibrary(request: request, client: client, completion: { parsed, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard parsed != nil else {
                print("Parsed entries is nil for user \(userID)")
                return
            }
            
            //let entries = LibraryEntry.get(withIds: parsed!)
            completion(LibraryEntry.all(), nil)
        })
        library.start()
        return library*/
        return nil
    }
    
    /// Get all the library entries of a user
    ///
    /// - Parameters:
    ///   - userID: The user
    ///   - type: The type of entries to fetch
    ///   - completion: The completion block which passes back an array of tuples of type `(LibraryEntry.Status, Error)`, which are set when fetching a specific status fails
    public func getAll(userID: Int, type: Media.MediaType, completion: @escaping ([(LibraryEntry.Status, Error)]) -> Void) {
        //let operation = FetchAllLibraryOperation(relativeURL: Constants.Endpoints.libraryEntries, userID: userID, type: type, client: client, completion: completion)
        //queue.addOperation(operation)
    }

}
