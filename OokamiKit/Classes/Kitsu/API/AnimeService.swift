//
//  AnimeService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class AnimeService: BaseService {
    
    /// Find an anime with a given title
    ///
    /// - Parameters:
    ///   - title: The title to search for
    ///   - limit: The amount of anime to return
    ///   - completion: The completion block which passes an array of anime ids that were found or an error if it occured
    /// - Returns: The search operation which can be cancelled.
    public func find(title: String, limit: Int = 20, completion: @escaping ([Int]?, Error?) -> Void) -> Operation {
        let url = Constants.Endpoints.anime
        let request = KitsuPagedRequest(relativeURL: url)
        request.filter(key: "text", value: title)
        request.page(limit: limit)
        
        let operation = NetworkOperation(request: request.build(), client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, NetworkClientError.error("Failed to parse json - Anime Service FIND"))
                return
            }
            
            //Parse the objects and return the ids of the anime back
            Parser().parse(json: json, callback: { objects in
                
                //Add the objects to the database
                self.database.addOrUpdate(objects)
                
                //Return the results to the user
                let filtered = objects.flatMap { $0 is Anime ? $0 : nil }
                if let filteredAnime = filtered as? [Anime] {
                    let ids = filteredAnime.map { $0.id }

                    completion(ids, nil)
                    return
                }
                
            })
        }
        
        queue.addOperation(operation)
        
        return operation
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
