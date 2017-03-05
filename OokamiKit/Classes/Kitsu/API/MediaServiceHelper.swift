//
//  MediaServiceHelper.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

///A class which holds common code between media services
class MediaServiceHelper {
    
    
    /// Find a media object
    ///
    /// - Parameters:
    ///   - type: The type of media
    ///   - url: The url of where to find the media
    ///   - client: The client
    ///   - database: The database
    ///   - title: The title of the media to search, if empty then all results will be returned
    ///   - filters: The filters to apply
    ///   - completion: The completion block which passes back an array of T objects that were recieved or an error if it occured and a bool to indicate if it was the original request
    /// - Returns: A Paginated Discover class which can be used to fetch other pages
    func find<T: Object>(type: T.Type, url: String, client: NetworkClient, database: Database, title: String, filters: MediaFilter, limit: Int, completion: @escaping ([Object]?, Error?, Bool) -> Void) -> PaginatedService {
        let request = KitsuPagedRequest(relativeURL: url)
        
        //Apply title filter
        if !title.isEmpty {
            request.filter(key: "text", value: title)
        } else {
            request.sort(by: filters.sort.key, ascending: filters.sort.direction == .ascending)
        }
        
        //Apply the other filters
        for (key, value) in filters.construct() {
            request.filter(key: key, value: value)
        }
        
        //Set the paging
        request.page = KitsuPagedRequest.Page(offset: 0, limit: limit)
        
        let paginated = PaginatedService(request: request, client: client) { parsed, error, original in
            guard error == nil else {
                completion(nil, error, original)
                return
            }
            
            guard let parsed = parsed else {
                completion(nil, NetworkClientError.error("Failed to get parsed objects - Media Service Helper"), original)
                return
            }
            
            //Add the objects to the database
            database.addOrUpdate(parsed)
            
            //Filter the type T out of the parsed objects and return it
            completion(parsed.filter { $0 is T }, nil, original)
        }
        
        paginated.start()
        
        return paginated
        
    }
    
}
