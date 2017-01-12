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
    var interval: TimeInterval = 1200
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    @objc func updateLibrary(completion: (() -> Void)? = nil) {
        
        var fetched = Set<Media.MediaType>()
        let checkForCompletion = {
            if fetched.count == 2 {
                completion?()
            }
        }
        
        //Fetch the libraries for the current user
        if CurrentUser().isLoggedIn(), let user = CurrentUser().userID {
            LibraryService().getAll(userID: user, type: .anime) { _ in
                fetched.insert(.anime)
                checkForCompletion()
            }
            LibraryService().getAll(userID: user, type: .manga) { _ in
                fetched.insert(.manga)
                checkForCompletion()
            }
        } else {
            completion?()
        }
    }
    
    func startFetching() {
        if timer != nil { timer?.invalidate() }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateLibrary(completion:)), userInfo: nil, repeats: true)
    }
    
    func stopFetching() {
        timer?.invalidate()
    }
}

