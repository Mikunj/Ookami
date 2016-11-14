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

        let id = 5097
        let notif = LibraryEntry.all().addNotificationBlock { changes in
            if case .initial(let a) = changes {
                print("\(a.count) entries added.")
            }
            
        }
        
        let q = OperationQueue()
        
        let start = Date()
        let libraryOperation = FetchAllLibraryOperation(relativeURL: "/library-entries", userID: id, type: .anime, client: client) { results in
            print("Entries: \(LibraryEntry.all().count)")
            print("User: \(User.get(withId: id)?.name)")
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

