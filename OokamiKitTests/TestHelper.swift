//
//  TestHelper.swift
//  Ookami
//
//  Created by Maka on 4/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON

class TestHelper {
    
    /// Load a JSON file
    ///
    /// - Parameter file: The file name without extension
    /// - Returns: the JSON content if valid file/contents
    static func loadJSON(fromFile file: String) -> JSON? {
        if let path = Bundle.main.path(forResource: file, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                return json
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        } else {
            print("Invalid filename/path \(file).")
            return nil
        }
    }
}

