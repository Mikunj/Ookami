//
//  AnimeService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class AnimeService: BaseService {
    
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
