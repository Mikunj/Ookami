//
//  MangaService.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class MangaService: BaseService {
    
    //TODO: Need to refactor the find function here .. so ugly
    
    /// Find a manga with a given title
    ///
    /// - Parameters:
    ///   - title: The title to search for
    ///   - filters: The filters to apply
    ///   - page: The paging to apply
    ///   - completion: The completion block which passes an array of manga ids that were found or an error if it occured and a bool to indicate whether it was the original request
    /// - Returns: The search operation which can be cancelled.
    public func find(title: String, filters: MangaFilter = MangaFilter(), limit: Int = 20, completion: @escaping ([Int]?, Error?, Bool) -> Void) -> PaginatedService {
        let url = Constants.Endpoints.manga
        return MediaServiceHelper().find(type: Manga.self, url: url, client: client, database: database, title: title, filters: filters, limit: limit) { objects, error, original in
            
            guard error == nil,
                let objects = objects else {
                    completion(nil, error, original)
                    return
            }
            
            //Return the ids of the objects
            if let manga = objects as? [Manga] {
                let ids = manga.map { $0.id }
                completion(ids, nil, original)
                return
            }
            
        }
    }
    
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
