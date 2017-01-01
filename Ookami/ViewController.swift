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

class ItemSource: ItemViewControllerDataSource {
    var delegate: ItemViewControllerDelegate?
    
    let userID: Int
    let type: Media.MediaType
    var token: NotificationToken?
    var results: Results<LibraryEntry>
    
    init(userID: Int, type: Media.MediaType) {
        self.userID = userID
        self.type = type
        
        results = LibraryEntry.belongsTo(user: userID).filter("media.rawType = %@", type.rawValue).sorted(byProperty: "updatedAt", ascending: false)
        
        defer {
            token = results.addNotificationBlock { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.delegate?.didReloadItems(dataSource: self)
                    break
                case .update(_, _, _, _):
                    self.delegate?.didReloadItems(dataSource: self)
                    break
                default:
                    break
                }
            }
            
            LibraryService().getAll(userID: 2875, type: .anime) { _ in }
        }
        
        
    }
    
    deinit {
        token?.stop()
    }
    
    func toItemData(entry: LibraryEntry) -> ItemData {
        
        var data = ItemData()
        
        var maxCount = -1
        
        //Name
        if let media = entry.media, let type = media.type {
            switch type {
            case .anime:
                let anime = Anime.get(withId: media.id)
                data.name = anime?.canonicalTitle
                data.posterImage = anime?.posterImage
                maxCount = anime?.episodeCount ?? -1
                break
            case .manga:
                let manga = Manga.get(withId: media.id)
                data.name = manga?.canonicalTitle
                data.posterImage = manga?.posterImage
                maxCount = manga?.chapterCount ?? -1
                break
            }
        }
        
        data.countString = maxCount > 0 ? "\(entry.progress) / \(maxCount)" : "\(entry.progress)"
        
        return data
    }
    
    func items() -> [ItemData] {
        return Array(results).map { toItemData(entry: $0) }
    }
    
    func didSelectItem(at indexpath: IndexPath) {
        
    }
}

class ViewController: UIViewController {
    
    var libraryView: ItemViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database().write { realm in
            realm.deleteAll()
        }
        
        let d = ItemSource(userID: 2875, type: .anime)
        
        libraryView = ItemViewController(dataSource: d)
        
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

