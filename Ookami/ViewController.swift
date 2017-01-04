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
import Cartography

class ViewController: UIViewController {
    
    var libraryView: UserLibraryViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database().write { realm in
            realm.deleteAll()
        }
        
        var anime: [LibraryEntry.Status: FullLibraryDataSource] = [:]
        var manga: [LibraryEntry.Status: FullLibraryDataSource] = [:]
        
        for status in LibraryEntry.Status.all {
            anime[status] = FullLibraryDataSource(userID: 2875, type: .anime, status: status)
            manga[status] = FullLibraryDataSource(userID: 2875, type: .manga, status: status)
        }
        
        let data = try! UserLibraryViewDataSource(anime: anime, manga: manga)
        
        
        libraryView = UserLibraryViewController(dataSource: data)
        
        addChildViewController(libraryView!)
        
        let v = libraryView!.view as UIView
        self.view.addSubview(v)
        constrain(v) { view in
            view.edges == view.superview!.edges
        }
        
        libraryView?.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

