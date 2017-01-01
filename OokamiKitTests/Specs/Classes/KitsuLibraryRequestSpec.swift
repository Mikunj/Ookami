//
//  KitsuLibraryRequestSpec.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class KitsuLibraryRequestSpec: QuickSpec {
    
    override func spec() {
        describe("Kitsu Library Request") {
            it("should correctly apply filters") {
                let date = Date(timeIntervalSince1970: 1)
                let type: Media.MediaType = .anime
                let status: LibraryEntry.Status = .current
                let request = KitsuLibraryRequest(userID: 1, type: type, status: status, since: date)
                
                let filters = request.filters
                
                expect(filters["user_id"] as? Int).to(equal(1))
                expect(filters["media_type"] as? String).to(equal(type.toLibraryMediaTypeString()))
                expect(filters["status"] as? String).to(equal(status.rawValue))
                //expect(filters["since"] as? String).to(equal("1970-01-01T00:00:01.000Z"))
            }
        }
    }
}
