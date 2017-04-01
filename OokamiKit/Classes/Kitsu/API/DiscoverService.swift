//
//  DiscoverService.swift
//  Ookami
//
//  Created by Maka on 1/4/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public class DiscoverService: BaseService {
    
    /// Find a given media with the given title and filters.
    ///
    /// - Parameters:
    ///   - type: The type of media to find
    ///   - title: The title to search for
    ///   - filters: The filters to apply
    ///   - limit: The amount of media to fetch per page
    ///   - completion: The completion block which passes an array of the media ids or an error if it occurred. It also passes a bool which indicates whether the request was the original.
    /// - Returns: The paginated service which can be used to fetch further media.
    public func find(type: Media.MediaType, title: String, filters: MediaFilter, limit: Int = 20, completion: @escaping ([Int]?, Error?, Bool) -> Void) -> PaginatedService {
        
        let objectType: Object.Type = type == .anime ? Anime.self : Manga.self
        let endpoint = type == .anime ? Constants.Endpoints.anime : Constants.Endpoints.manga
        
        return self.find(objectType: objectType, url: endpoint, title: title, filters: filters, limit: limit) { objects, error, original in
            
            //Parse the ids
            var ids: [Int]? = nil
            
            //We don't need to check against 'type' here because if let will automatically handle that :)
            if let anime = objects as? [Anime] {
                ids = anime.map { $0.id }
            } else if let manga = objects as? [Manga] {
                ids = manga.map { $0.id }
            }
            
            completion(ids, error, original)
        }
    }
    
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
    private func find<T: Object>(objectType: T.Type, url: String, title: String, filters: MediaFilter, limit: Int, completion: @escaping ([Object]?, Error?, Bool) -> Void) -> PaginatedService {
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
            self.database.addOrUpdate(parsed)
            
            //Filter the type T out of the parsed objects and return it
            completion(parsed.filter { $0 is T }, nil, original)
            
        }
        
        paginated.start()
        
        return paginated
        
    }

}
