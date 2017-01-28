//
//  Date+Utils.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

public extension Date {
    
    //An iso-8601 formatter
    public static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    /// The ISO8601 string repreentation for the date
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
    
    /// Convert a String to a Date
    ///
    /// - Parameter dateString: The String
    /// - Returns: A Date if string could be converted else nil
    static func from(string dateString: String) -> Date? {
        
        if dateString.isEmpty { return nil }
        
        let dateFormatter = DateFormatter()
        
        switch dateString.characters.count {
            case 10:
                dateFormatter.dateFormat = "YYYY-MM-dd"
            
            case 19:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
            
            case 21:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.S"
            
            case 22:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SS"
            
            case 24:
                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
            
            default:
                break
        }

        return dateFormatter.date(from: dateString)
    }
}
