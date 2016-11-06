//
//  Date+Utils.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

extension Date {
    
    /// Convert a String to a Date
    ///
    /// - Parameter dateString: The String
    /// - Returns: A Date if string could be converted else nil
    static func from(string dateString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        
        switch dateString.characters.count {
            case 10:
                dateFormatter.dateFormat = "YYYY-MM-dd"
                break
            case 19:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
                break
            case 21:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.S"
                break
            case 22:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SS"
                break
            case 24:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
                break
            default:
                return nil
        }

        return dateFormatter.date(from: dateString)
    }
}
