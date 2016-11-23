//
//  ViewController.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Heimdallr
import RealmSwift
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://test")
        let h = Heimdallr(tokenURL: url!)
        let client = NetworkClient(baseURL: "http://staging.kitsu.io/api/edge", heimdallr: h)

        let id = 2875//5097
        
        try! RealmProvider.realm().write {
            RealmProvider.realm().deleteAll()
        }
        
        let notif = LibraryEntry.all().addNotificationBlock { changes in
            if case .initial(let a) = changes {
                print("\(a.count) entries initially.")
            }
            
        }
        
        let q = OperationQueue()
        
        let start = Date()
        
        //NOTE: This will return 404 for any operation which uses the 'next' link as Nuck hasn't hooked up the links to the correct domain
        // currently in kitsu-api-staging.herokuapp.com instead of staging.kitsu.io
        let libraryOperation = FetchAllLibraryOperation(relativeURL: "/library-entries", userID: id, type: .anime, client: client) { results in
            let user = User.get(withId: id)
            print("Entries: \(LibraryEntry.all().filter("userID = \(id)").count)")
            print("User: \(user?.name)")
            let finish = Date()
            let executionTime = finish.timeIntervalSince(start)
            print("Execution Time: \(executionTime)")
            notif.stop()
        }
        
        
        q.addOperation(libraryOperation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

