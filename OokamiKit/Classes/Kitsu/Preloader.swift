//
//  Preloader.swift
//  Ookami
//
//  Created by Maka on 23/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

public class Preloader {
    
    public init () {}
    
    /// Prelad any necessary data
    public func preloadData() {
        
        //The genres need to be preloaded
        preloadGenres()
    }
    
    func preloadGenres() {
        let genreRequest = KitsuPagedRequest(relativeURL: Constants.Endpoints.genres)
        genreRequest.page(limit: 9999)
        
        let operation = NetworkOperation(request: genreRequest.build(), client: Ookami.shared.networkClient) { json, error in
            guard error == nil,
                    let json = json else {
                print("Failed to preload genres")
                return
            }
            
            Parser().parse(json: json) { objects in
                Database().addOrUpdate(objects)
                print("Preloaded genres")
            }
            
        }
        
        Ookami.shared.queue.addOperation(operation)
    }
}
