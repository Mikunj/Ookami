//
//  AnimeService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class AnimeService: BaseService {
    
    /// Find an anime with a given title and filters.
    /// We don't return `Anime` objects in the call back because the objects may be accessed on another thread, thus it is better to pass back the ids and the object calling can handle fetching objects from the database.
    ///
    /// - Parameters:
    ///   - title: The title to search for
    ///   - filters: The filters to apply
    ///   - limit: The amount of anime per page to return.
    ///   - completion: The completion block which passes an array of anime ids that were found or an error if it occured and a bool to indicate whether it was the original request
    /// - Returns: The paginated discover class which can be used to get further entries
    public func find(title: String, filters: AnimeFilter = AnimeFilter(), limit: Int = 20, completion: @escaping ([Int]?, Error?, Bool) -> Void) -> PaginatedService {
        let url = Constants.Endpoints.anime
        return MediaServiceHelper().find(type: Anime.self, url: url, client: client, database: database, title: title, filters: filters, limit: limit) { objects, error, original in
            
            guard error == nil else {
                completion(nil, error, original)
                return
            }
            
            guard let objects = objects else {
                completion(nil, NetworkClientError.error("Failed to get objects - Anime Service FIND"), original)
                return
            }
            
            //Return the ids of the objects
            if let anime = objects as? [Anime] {
                let ids = anime.map { $0.id }
                completion(ids, nil, original)
                return
            }
            
        }
    }
    
    /// Get the weekly trending anime.
    ///
    /// - Parameter completion: The completion block which passes back an array of trending anime ids or an error if something went wrong.
    public func trending(completion: @escaping ([Int]?, Error?) -> Void) {
        let endpoint = Constants.Endpoints.trending
        let request = KitsuRequest(relativeURL: endpoint + "/anime")
        
        let operation = NetworkOperation(request: request.build(), client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Invalid JSON recieved - Anime Trending GET"))
                return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                
                //Get the anime
                let anime = parsed.filter { $0 is Anime } as? [Anime] ?? []
                let ids = anime.map { $0.id }
                completion(ids, nil)
            }
            
        }
        
        queue.addOperation(operation)
    }
    
    /// Get an anime with the given id.
    ///
    /// - Parameters:
    ///   - id: The anime id.
    ///   - completion: A completion block which passes back the anime object or and error if something went wrong
    public func get(id: Int, completion: @escaping (Anime?, Error?) -> Void) {
        let endpoint = Constants.Endpoints.anime
        let request = KitsuRequest(relativeURL: "\(endpoint)/\(id)")
        request.include("genres")
        
        let operation = NetworkOperation(request: request.build(), client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Invalid JSON recieved - Anime Service GET"))
                return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                
                //Get the anime we parsed
                let anime = parsed.first { $0 is Anime } as? Anime
                completion(anime, nil)
            }

        }
        
        queue.addOperation(operation)
    }
}
