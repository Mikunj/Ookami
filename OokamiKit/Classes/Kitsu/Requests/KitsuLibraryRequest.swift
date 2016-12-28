//
//  KitsuLibraryRequest.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

public class KitsuLibraryRequest: KitsuPagedRequest {
    
    ///The user id to use for the request
    public private(set) var userID: Int! {
        didSet {
            self.filter(key: "user_id", value: userID)
        }
    }
    
    ///The type of library to fetch
    public private(set) var type: Media.MediaType! {
        didSet {
            self.filter(key: "media_type", value: type.toLibraryMediaTypeString())
        }
    }
    
    ///The status to fetch, set to nil to fetch any
    public private(set) var status: LibraryEntry.Status? {
        didSet {
            if status != nil {
                self.filter(key: "status", value: status!.rawValue)
            } else {
                self.filters.removeValue(forKey: "status")
            }
        }
    }
    
    ///The min date that entries have to be updated since
    public private(set) var since: Date! {
        didSet {
            //TODO: This is passing an internal server error atm, need to ask Nuck
            self.filter(key: "since", value: since.iso8601)
        }
    }
    
    /// Create a library request.
    ///
    /// This will automatically add filters for userID, type and status. No other property will be touched.
    ///
    /// - Parameters:
    ///   - userID: The user id.
    ///   - type: The type of library to filter.
    ///   - status: A specific status of the library to filter.
    ///   - since: A date, only entries whos lastUpdate time is more recent than this date will be recieved.
    ///   - url: The relative endpoint url.
    ///   - headers: Any headers to include with the request.
    ///   - needsAuth: Whether the request needs authentication.
    public init(userID: Int,
                type: Media.MediaType,
                status: LibraryEntry.Status? = nil,
                since date: Date = Date(timeIntervalSince1970: 0),
                relativeUrl url: String = Constants.Endpoints.libraryEntries,
                headers: HTTPHeaders? = nil,
                needsAuth: Bool = false) {
        //Set default endpoint
        super.init(relativeURL: url, headers: headers, needsAuth: needsAuth)
        
        update(userID: userID, type: type, status: status, since: date)
    }
    
    //Update the stored values
    private func update(userID: Int, type: Media.MediaType, status: LibraryEntry.Status?, since: Date) {
        self.userID = userID
        self.type = type
        self.status = status
        self.since = since
    }
    
    /// Create a copy of the request
    ///
    /// - Returns: The copied request
    override public func copy() -> KitsuRequest {
        let request = KitsuLibraryRequest(userID: userID, type: type, status: status, since: since, relativeUrl: url, headers: headers, needsAuth: needsAuth)
        request.includes = includes
        request.filters = filters
        request.sort = sort
        request.page = page
        return request
    }
}
