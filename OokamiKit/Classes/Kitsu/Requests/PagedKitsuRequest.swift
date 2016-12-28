//
//  PagedKitsuRequest.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

class PagedKitsuRequest: KitsuRequest {
    
    public struct Page {
        var offset: Int = 0
        var limit: Int = 50
    }
    
    //The current page
    public internal(set) var page: Page = Page()
    
    override func parameters() -> Parameters {
        var params = super.parameters()
        params["page"] = ["offset": page.offset, "limit": page.limit]
        return params
    }
    
    /// Set the page offset
    public func page(offset: Int) {
        page.offset = max(0, offset)
    }
    
    /// Set the limit of objects per page
    public func page(limit: Int) {
        page.limit = max(0, limit)
    }
    
    /// Create a copy of the request
    ///
    /// - Returns: The copied request
    override public func copy() -> KitsuRequest {
        let request = PagedKitsuRequest(relativeURL: url, headers: headers, needsAuth: needsAuth)
        request.includes = includes
        request.filters = filters
        request.sort = sort
        request.page = page
        return request
    }
    
}
