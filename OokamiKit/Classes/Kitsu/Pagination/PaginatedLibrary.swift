//
//  PaginatedLibrary.swift
//  Ookami
//
//  Created by Maka on 13/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/*
 The reason we have a paginated library class is because users won't look at ALL of another users library if you think about it.
 
 Say a user `A` looks at user `B`'s completed library which has 1000 entries. `A` won't bother looking through all 1000 entries of `B`, thus we can save time and data usage by adding in pagination, which is already supported by the api. This makes it so user `A` can still look at user `B`'s completed library, but if they wish to view more we just fetch the next page from the server for them.
 
 However we still need to be able to fetch a full users library regardless of pagination, thus the FetchLibraryOperation still exists. This is needed for the current user using the app. We need to reliably be able to sync between the website and the app (e.g if user deletes entry on website, then it should be deleted in app) and the only way to do that is to fetch the users whole library.
*/

/// Class for fetching a user's library paginated from the server.
public class PaginatedLibrary: PaginatedService {
    
    /// Create a paginated library.
    /// call `start()` to begin the fetch
    ///
    /// - Parameters:
    ///   - request: The paged kitsu library request
    ///   - client: The client to execute request on
    ///   - completion: The completion block, returns the fetched entries and related objects on the current page, or an Error if something went wrong.
    ///                 This gets called everytime a page of entries is recieved.
    ///                 This can be through calls such as `next()`, `prev()` etc ...
    public init(request: KitsuLibraryRequest, client: NetworkClientProtocol, completion: @escaping PaginatedBaseCompletion) {
        super.init(request: request, client: client, completion: completion)
    }
    
    ///Mark this as private so that we force users to use a library request
    private override init(request: KitsuPagedRequest, client: NetworkClientProtocol, completion: @escaping PaginatedBaseCompletion) {
        super.init(request: request, client: client, completion: completion)
    }
}
