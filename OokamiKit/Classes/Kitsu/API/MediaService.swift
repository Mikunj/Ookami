//
//  MediaService.swift
//  Ookami
//
//  Created by Maka on 30/8/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

public class MediaService: BaseService {
    
    /// Get the media relationships for the given media.
    ///
    /// - Parameters:
    ///   - id: The media id.
    ///   - type: The media type.
    ///   - completion: The completion block which passes an array of the media relationship ids or an error if it occurred.
    /// - Returns: The paginated service.
    @discardableResult public func getMediaRelationships(for id: Int, type: Media.MediaType, completion: @escaping ([Int]?, Error?) -> Void) -> PaginatedService {
        let endpoint = Constants.Endpoints.mediaRelationships
        let request = KitsuPagedRequest(relativeURL: endpoint)
        request.filter(key: "source_id", value: id)
        request.filter(key: "source_type", value: type.rawValue.capitalized)
        request.include("destination", "source")
        request.page = KitsuPagedRequest.Page(offset: 0, limit: 20)
        
        let paginated = PaginatedService(request: request, client: client) { parsed, error, original in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let parsed = parsed else {
                completion(nil, NetworkClientError.error("Failed to get parsed objects - Media Service"))
                return
            }
            
            //Add the objects to the database
            self.database.addOrUpdate(parsed)
            
            //Filter the MediaReplationships out of the parsed objects and return it
            let filtered = parsed.filter { $0 is MediaRelationship } as! [MediaRelationship]
            completion(filtered.map { $0.id }, nil)
        }
        
        paginated.start()
        
        return paginated
    }
}
