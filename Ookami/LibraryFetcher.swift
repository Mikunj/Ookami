//
//  LibraryFetcher.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

//A class which is used to fetch the current users library every 20 minutes
//TODO: Maybe implement Background Fetching?
class LibraryFetcher {
    
    var timer: Timer?
    var interval: TimeInterval = 60 * 3 //Every 3 minutes
    var timesCalled: Int = 0
    
    @objc func updateLibrary() {
        //We need the current user to be logged in
        guard let user = CurrentUser().userID else {
            return
        }
        
        //Every 5 calls we should fetch the main library
        if timesCalled >= 5 {
            timesCalled = 0
            print("Updated full library")
            LibraryService().getAll(userID: user, type: .anime) { _ in }
            LibraryService().getAll(userID: user, type: .manga) { _ in }
            return
        }
        
        //Check if we have a last fetched object, if not then don't get the library
        //This avoids the issue of fetching a full users library every 3 minutes if we haven't initially fetched all of it
        if let fetched = LastFetched.get(withId: user) {
            print("Updated partial library")
            LibraryService().getAll(userID: user, type: .anime, since: fetched.anime) { _ in }
            LibraryService().getAll(userID: user, type: .manga, since: fetched.manga) { _ in }
        }
        
        timesCalled += 1
    }
    
    func startFetching() {
        if timer != nil { timer?.invalidate() }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateLibrary), userInfo: nil, repeats: true)
    }
    
    func stopFetching() {
        timer?.invalidate()
    }
}

