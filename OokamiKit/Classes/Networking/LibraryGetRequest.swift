//
//  LibraryGetRequest.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

/// Enum for the filters
public enum LibraryRequestFilters {
    case user(id: Int)
    case media(type: LibraryRequestMedia)
    case status(LibraryEntryStatus)
    case statuses([LibraryEntryStatus])
}

/// Enum for media types
public enum LibraryRequestMedia: String {
    case anime = "Anime"
    case manga = "Manga"
    
    /// Convert LibraryRequestMedia to LibraryEntry Media.MediaType
    ///
    /// - Returns: The Media.MediaType of the current value
    public func toEntryMediaType() -> Media.MediaType {
        switch self {
            case .anime: return Media.MediaType.anime
            case .manga: return Media.MediaType.manga
        }
    }
}

/// Enum for the includes in the request
public enum LibraryRequestIncludes: String {
    case genres = "media.genres"
    case user
}

/// A library GET request builder
/// Many functions return Self to allow chaining
public class LibraryGETRequest {
    
    public struct Page {
        var offset: Int = 0
        var limit: Int = 50
    }
    
    public internal(set) var userID: Int
    public let url: String
    public let headers: HTTPHeaders?
    public internal(set) var includes: [String] = []
    public internal(set) var filters: [LibraryRequestFilters] = []
    public internal(set) var page: Page = Page()
    
    /// Create a library get request
    ///
    /// - Parameters:
    ///   - userID: The id of the user to build requests for
    ///   - url: The relative url endpoint of the request
    ///   - headers: Any headers to include with the request
    init(userID: Int, relativeURL url: String, headers: HTTPHeaders? = nil) {
        self.url = url
        self.headers = headers
        
        //Set the id
        self.userID = userID
        filter(.user(id: userID))
    }
    
    
    /// Build the network request
    ///
    /// - Returns: The network request
    public func build() -> NetworkRequest {
        var params: Parameters = [:]
        params["include"] = includes.joined(separator: ",")
        params["filter"] = getFilters()
        params["page"] = ["offset": page.offset, "limit": page.limit]
        return NetworkRequest(relativeURL: url, method: .get, parameters: params, headers: headers, needsAuth: false)
    }
}

/// Getting realm entries
extension LibraryGETRequest {
    
    /// Get Realm results of library entries that comply with the request.
    /// This then can be used to subscribe to notifcations straight from realm
    ///
    /// - Returns: Realm results of library entries linked to the request
    public func getEntries() -> Results<LibraryEntry> {
        var entries = LibraryEntry.all().filter("userID = %d", self.userID)
        entries = applyAdditionalRealmFilters(to: entries)
        return entries
    }
    
    /// Apply additional realm filters to the entries
    func applyAdditionalRealmFilters(to entries: Results<LibraryEntry>) -> Results<LibraryEntry> {
        
        var e = entries
        
        //Look through the filters array backwards and find the relevant filters
        var mediaFilter: LibraryRequestMedia?
        var statuses: [LibraryEntryStatus]?
        filters.reversed().forEach {
            
            //Get the media type
            if mediaFilter == nil {
                if case .media(let type) = $0 { mediaFilter = type }
            }
            
            if statuses == nil {
                if case .status(let status) = $0 { statuses = [status] }
                if case .statuses(let statusArray) = $0 { statuses = statusArray }
            }
            
        }
        
        //Apply media type filter
        if mediaFilter != nil {
            e = e.filter("media.rawType = %@", mediaFilter!.toEntryMediaType().rawValue)
        }
        
        //Apply status filter
        if statuses != nil {
            let rawStatuses = statuses!.map { return $0.rawValue }
            e = e.filter("rawStatus IN %@", rawStatuses)
        }
        
        return e
    }
}

/// Filters
extension LibraryGETRequest {
    
    /// Set a filter on the request
    @discardableResult public func filter(_ filter: LibraryRequestFilters) -> Self {
        
        //If it's a user id filter then we must change the id of the request
        if case LibraryRequestFilters.user(let id) = filter {
            self.userID = id
        } else {
            filters.append(filter)
        }
        
        return self
    }
    
    /// Set a filters using a block
    @discardableResult public func filter(_ filterArray: [LibraryRequestFilters]) -> Self {
        filterArray.forEach { filter($0) }
        return self
    }
    
    /// Get the filters set on the request
    ///
    /// - Returns: A dictionary of filter keys and associated values
    func getFilters() -> [String: Any] {
        var filters: [String: Any] = [:]
        
        //Add the user filter into the array
        var finalFilters = self.filters
        finalFilters.append(.user(id: userID))
        
        finalFilters.forEach { filter in
            switch filter {
                case .user(let id):
                    filters["user_id"] = id
                    break
                case .media(let type):
                    filters["media_type"] = type.rawValue
                    break
                case .status(let status):
                    filters["status"] = LibraryEntryStatus.all.index(of: status)! + 1
                    break
                case .statuses(let statuses):
                    filters["status"] = statuses.map {
                        return LibraryEntryStatus.all.index(of: $0)! + 1
                    }
                    break
            }
        }
        
        return filters
    }

}

/// Includes
extension LibraryGETRequest {
    
    /// Include extra information in the request
    @discardableResult public func include(_ info: LibraryRequestIncludes) -> Self {
        includes.append(info.rawValue)
        return self
    }
    
    /// Include extra information in the request
    @discardableResult public func include(_ infoArray: [LibraryRequestIncludes]) -> Self {
        infoArray.forEach { include($0) }
        return self
    }
    
    /// Exclude extra information that was included in the request
    @discardableResult public func exclude(_ info: LibraryRequestIncludes) -> Self {
        if let index = includes.index(of: info.rawValue) {
            includes.remove(at: index)
        }
        return self
    }
}

/// Page
extension LibraryGETRequest {
    
    /// Set the page offset
    @discardableResult public func page(offset: Int) -> Self {
        page.offset = max(0, offset)
        return self
    }
    
    /// Set the limit of objects per page
    @discardableResult public func page(limit: Int) -> Self {
        page.limit = max(0, limit)
        return self
    }
    
    /// Increment the page offset
    @discardableResult public func nextPage() -> Self {
        return page(offset: page.offset + 1)
    }
    
    /// Decrement the page offset
    @discardableResult public func prevPage() -> Self {
        return page(offset: page.offset - 1)
    }
}

//Copying
extension LibraryGETRequest: NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let r = LibraryGETRequest(userID: userID, relativeURL: url, headers: headers)
        r.includes = includes
        r.filters = filters
        r.page = page
        return r
    }
}
