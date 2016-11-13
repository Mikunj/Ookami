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
        
        let r = NetworkRequest(relativeURL: "/library-entries", method: .get, parameters: ["filter": ["user_id": 2875, "media_type": "Anime", "status": 1], "page": ["offset": 0, "limit": 50]])
        
        let o = NetworkOperation(request: r, client: client) { json, error in
            print(json ?? "No JSON")
            print(error ?? "No Error")
        }
        
        let q = OperationQueue()
        let libraryOperation = FetchAllLibraryOperation(relativeURL: "/library-entries", userID: 2875, type: .anime, client: client) { results in
            debugPrint(results)
        }
        
        libraryOperation.completionBlock = {
            print(LibraryEntry.all().count)
            print(Anime.all().count)
            print(User.get(withId: 2875)!.name)
        }
        
        q.addOperation(libraryOperation)
        
        ///http://staging.kitsu.io/api/edge/anime?filter%5Bslug%5D=ajin-2nd-season
        
        
//        Alamofire.request("http://staging.kitsu.io/api/edge/anime/1", method: .get, parameters: nil, encoding: KitsuJSONEncoding.default, headers: ["Content-Type": "application/vnd.api+json", "Accept": "application/vnd.api+json"]).responseJSON { response in
//            print(response)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

