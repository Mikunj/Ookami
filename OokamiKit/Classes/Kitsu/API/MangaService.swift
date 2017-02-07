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
    ///   - filters: The filters to apply
    ///   - page: The paging to apply
    ///   - completion: The completion block which passes an array of manga ids that were found or an error if it occured
    /// - Returns: The search operation which can be cancelled.
    public func find(title: String, filters: MangaFilter = MangaFilter(), completion: @escaping ([Int]?, Error?) -> Void) -> PaginatedService {
        let url = Constants.Endpoints.manga
        return MediaServiceHelper().find(type: Manga.self, url: url, client: client, database: database, title: title, filters: filters) { objects, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let objects = objects else {
                completion(nil, NetworkClientError.error("Failed to get objects - Manga Service FIND"))
                return
            }
            
            //Return the ids of the objects
            if let manga = objects as? [Manga] {
                let ids = manga.map { $0.id }
                completion(ids, nil)
                return
            }
            
        }
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
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Invalid JSON recieved - Manga Service GET"))
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
