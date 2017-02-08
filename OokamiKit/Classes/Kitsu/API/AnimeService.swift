//
//  AnimeService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class AnimeService: BaseService {
    
    /// Find an anime with a given title and filters
    ///
    /// - Parameters:
    ///   - title: The title to search for
    ///   - filters: The filters to apply
    ///   - completion: The completion block which passes an array of anime ids that were found or an error if it occured and a bool to indicate whether it was the original request
    /// - Returns: The paginated discover class which can be used to get further entries
    public func find(title: String, filters: AnimeFilter = AnimeFilter(), completion: @escaping ([Int]?, Error?, Bool) -> Void) -> PaginatedService {
        let url = Constants.Endpoints.anime
        return MediaServiceHelper().find(type: Anime.self, url: url, client: client, database: database, title: title, filters: filters) { objects, error, original in
            
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
                
                //Get the user we parsed
                let anime = parsed.first { $0 is Anime } as? Anime
                completion(anime, nil)
            }

        }
        
        queue.addOperation(operation)
    }
}
