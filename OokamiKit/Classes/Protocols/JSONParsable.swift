//
//  JSONParsable.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Protocol for an object that can be parsable with JSON data
protocol JSONParsable {
    associatedtype T
    
    /// Construct an object from JSON Data
    ///
    /// - Parameter json: The JSON data
    /// - Returns: The parsed object
    static func parse(json: JSON) -> T?
}
