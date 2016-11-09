//
//  LibraryGetRequest.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

/// Enum for media types
public enum LibraryRequestMedia: String {
    case anime = "Anime"
    case manga = "Manga"
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
    
    public let url: String
    public let headers: HTTPHeaders?
    public internal(set) var includes: [String] = []
    public internal(set) var filters: [String: Any] = [:]
    public internal(set) var page: Page = Page()
    
    /// Create a library get request
    ///
    /// - Parameters:
    ///   - url: The relative url endpoint of the request
    ///   - headers: Any headers to include with the request
    init(relativeURL url: String, headers: HTTPHeaders? = nil) {
        self.url = url
        self.headers = headers
    }
    
    
    /// Build the network request
    ///
    /// - Returns: The network request
    public func build() -> NetworkRequest {
        var params: Parameters = [:]
        params["include"] = includes.joined(separator: ",")
        params["filter"] = filters
        params["page"] = ["offset": page.offset, "limit": page.limit]
        return NetworkRequest(relativeURL: url, method: .get, parameters: params, headers: headers, needsAuth: false)
    }
}

/// Filters
extension LibraryGETRequest {
    
    /// Filter the user
    @discardableResult public func filter(userID: Int) -> Self {
        filters["user_id"] = userID
        return self
    }
    
    /// Filter the media type
    @discardableResult public func filter(media: LibraryRequestMedia) -> Self {
        filters["media_type"] = media.rawValue
        return self
    }
    
    /// Filter the status
    @discardableResult public func filter(status: LibraryEntryStatus) -> Self {
        filters["status"] = LibraryEntryStatus.all.index(of: status)! + 1
        return self
    }
    
    /// Filter multiple statuses
    @discardableResult public func filter(statuses: [LibraryEntryStatus]) -> Self {
        filters["status"] = statuses.map {
            return LibraryEntryStatus.all.index(of: $0)! + 1
        }
        return self
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
        let r = LibraryGETRequest(relativeURL: url, headers: headers)
        r.includes = includes
        r.filters = filters
        r.page = page
        return r
    }
}
