//
//  MangaService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class MangaService: BaseService {
    
    /// Find a manga with a given title
    ///
    /// - Parameters:
    ///   - title: The title to search for
    ///   - limit: The amount of anime to return
    ///   - completion: The completion block which passes an array of manga ids that were found or an error if it occured
    /// - Returns: The search operation which can be cancelled.
    public func find(title: String, limit: Int = 20, completion: @escaping ([Int]?, Error?) -> Void) -> Operation {
        let url = Constants.Endpoints.manga
        let params: [String: Any] = ["filter": ["text": title], "page":["limit": limit]]
        
        let request = NetworkRequest(relativeURL: url, method: .get, parameters: params)
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, NetworkClientError.error("Failed to parse json - Anime Service"))
                return
            }
            
            //Parse the objects and return the ids of the anime back
            Parser().parse(json: json, callback: { objects in
                
                //Add the objects to the database
                self.database.addOrUpdate(objects)
                
                //Return the results to the user
                let filtered = objects.flatMap { $0 is Manga ? $0 : nil }
                if let filteredAnime = filtered as? [Manga] {
                    let ids = filteredAnime.map { $0.id }
                    
                    completion(ids, nil)
                    return
                }
                
            })
        }
        
        queue.addOperation(operation)
        
        return operation
    }
}
