//
//  AppCoordinator.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

extension UIWindow {
    
    /// Set the root view controller on the window with a nice animation
    ///
    /// - Parameters:
    ///   - controller: The controller to set root to
    ///   - animated: Whether to animate the change
    func setRootViewController(_ controller: UIViewController, animated: Bool = true) {
        var snapshot: UIView?
        
        if animated {
            snapshot = self.snapshotView(afterScreenUpdates: true)
            if snapshot != nil {
                controller.view.addSubview(snapshot!)
            }
        }
        
        self.rootViewController = controller
        self.makeKeyAndVisible()
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                snapshot?.layer.opacity = 0;
            }, completion: { _ in
                snapshot?.removeFromSuperview();
            })
        }
        
    }
    
}

class AppCoordinator {
    private init() {}
    
    //Show the library entry view controller for a given entry
    static func showLibraryEntryVC(in nav: UINavigationController?, entry: LibraryEntry) {
        let e = LibraryEntryViewController(entry: entry)
        nav?.pushViewController(e, animated: true)
    }
    
    /// Show login as the root view
    static func showLoginVC(in window: UIWindow) {
        let login = LoginViewController()
        login.onLoginSuccess = {
            self.showStartingVC(in: window)
        }
        
        let nav = UINavigationController(rootViewController: login)
        window.setRootViewController(nav)
    }
    
    //Show the starting view controller
    static func showStartingVC(in window: UIWindow) {
        guard let user = CurrentUser().userID else {
            return
        }
        
        let libraryView = userLibraryVC(for: user) //42603 - Wopians id to test large libraries
        
        let nav = UINavigationController(rootViewController: libraryView)
        window.setRootViewController(nav)
    }
    
    
    //Get the library view controller for the given user id
    private static func userLibraryVC(for user: Int) -> UserLibraryViewController {
        var anime: [LibraryEntry.Status: FullLibraryDataSource] = [:]
        var manga: [LibraryEntry.Status: FullLibraryDataSource] = [:]
        
        for status in LibraryEntry.Status.all {
            anime[status] = FullLibraryDataSource(userID: user, type: .anime, status: status)
            manga[status] = FullLibraryDataSource(userID: user, type: .manga, status: status)
        }
        
        let data = try! UserLibraryViewDataSource(anime: anime, manga: manga)
        
        return UserLibraryViewController(userID: user, dataSource: data)
    }
}
