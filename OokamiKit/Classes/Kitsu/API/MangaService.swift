//
//  MangaService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class MangaService: BaseService {
    
    /// Get the weekly trending manga.
    ///
    /// - Parameter completion: The completion block which passes back an array of trending manga ids or an error if something went wrong.
    public func trending(completion: @escaping ([Int]?, Error?) -> Void) {
        let endpoint = Constants.Endpoints.trending
        let request = KitsuRequest(relativeURL: endpoint + "/manga")
        
        let operation = NetworkOperation(request: request.build(), client: client) { json, error in
            guard error == nil,
                let json = json else {
                    completion(nil, error)
                    return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                
                //Get the anime
                let manga = parsed.filter { $0 is Manga } as? [Manga] ?? []
                let ids = manga.map { $0.id }
                completion(ids, nil)
            }
            
        }
        
        queue.addOperation(operation)
    }
    
    
    /// Get a manga with the given id.
    ///
    /// - Parameters:
    ///   - id: The manga id.
    ///   - completion: A completion block which passes back the manga object or and error if something went wrong
    public func get(id: Int, completion: @escaping (Manga?, Error?) -> Void) {
        let endpoint = Constants.Endpoints.manga
        let request = KitsuRequest(relativeURL: "\(endpoint)/\(id)")
        request.include("genres")
        
        let operation = NetworkOperation(request: request.build(), client: client) { json, error in
            guard error == nil,
                let json = json else {
                completion(nil, error)
                return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                
                //Get the user we parsed
                let manga = parsed.first { $0 is Manga } as? Manga
                completion(manga, nil)
            }
            
        }
        
        queue.addOperation(operation)
    }
}
