//
//  MediaTitle.swift
//  Ookami
//
//  Created by Maka on 30/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

/**
 The reason we can safely assign compoundKey via didSet (note realm will not call didSet or willSet after object has been written to database) is because the mediaId and the key of the title will not change after it has first been added.
 
 WARNING: If you do decide to change the mediaID or key in OokamiKit then the compoundKey will be invalid!
 The key and value can only be modified internally (in OokamiKit) thus preventing the problem where apps using this framework modify the values accidentally
 */
public class MediaTitle: Object {
    
    public enum LanguageKey: String {
        case english = "en"
        case japanese = "ja_jp"
        case romanized = "en_jp"
        
        /// Get the string representation of the language key
        ///
        /// - Returns: The string value
        public func toString() -> String {
            switch self {
            case .english:
                return "English"
            case .japanese:
                return "Japanese"
            case .romanized:
                return "Romanized"
            }
        }
    }
    
    //The media this title belongs to
    public internal(set) dynamic var mediaID = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }

    //The type of media this belongs to
    public internal(set) dynamic var mediaType = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the language key, E.g en or en_jp
    public internal(set) dynamic var key = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //The language key in an enum format
    public var languageKey: LanguageKey? {
        return LanguageKey(rawValue: key)
    }
    
    //The title for the given key
    public internal(set) dynamic var value = ""
    
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(mediaID)-\(mediaType)-\(key)"
    }
    
    override public static func primaryKey() -> String {
        return "compoundKey"
    }
}
