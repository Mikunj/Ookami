//
//  LastFetched.swift
//  Ookami
//
//  Created by Maka on 30/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

//An object to track when a library was last fetched
class LastFetched: Object {
    
    //The user to track the last library fetch for
    public dynamic var userID: Int = -1
    
    //The last fetch of the anime library
    public dynamic var anime: Date = Date(timeIntervalSince1970: 0)
    
    //The last fetch of the manga library
    public dynamic var manga: Date = Date(timeIntervalSince1970: 0)
    
    override public static func primaryKey() -> String {
        return "userID"
    }
    
    

}

extension LastFetched: GettableObject { public typealias T = LastFetched }
