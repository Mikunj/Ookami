//
//  AppCoordinator.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import XCDYouTubeKit
import AVFoundation

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
    static func showLibraryEntryVC(in nav: UINavigationController?, entry: LibraryEntry, shouldShowMediaButton: Bool = true) {
        let e = LibraryEntryViewController(entry: entry)
        e.shouldShowMediaButton = shouldShowMediaButton
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
    static func showStartingVC(in window: UIWindow, isUITest: Bool = false) {
        guard let user = isUITest ? 2875 : CurrentUser().userID else {
            return
        }
        
        //Discover
        let discoverView = mediaDiscoverVC()
        let discoverImage = UIImage(named: "Search_tab_bar")
        discoverView.tabBarItem = UITabBarItem(title: "Discover", image: discoverImage, tag: 0)
        let discoverNav = UINavigationController(rootViewController: discoverView)
        
        //Trending
        //TODO: Get a nice pdf image icon for trending
        let trendingView = mediaTrendingVC()
        trendingView.tabBarItem = UITabBarItem(withIcon: .barChartIcon, size: CGSize(width: 25, height: 25), title: "Trending")
        let trendingNav = UINavigationController(rootViewController: trendingView)
        
        //Library
        let libraryView = userLibraryVC(for: user) //42603 - Wopians id to test large libraries
        let libraryImage = UIImage(named: "Book_tab_bar")
        libraryView.tabBarItem = UITabBarItem(title: "Library", image: libraryImage, tag: 1)
        let libraryNav = UINavigationController(rootViewController: libraryView)
        
        //Default to the library tab
        let tab = initialTabBarController()
        tab.viewControllers = [discoverNav, trendingNav, libraryNav]
        tab.selectedIndex = 2
        
        
        window.setRootViewController(tab)
    }
    
    static func showAnimeVC(in parent: UIViewController, anime: Anime) {
        let animeVC = AnimeViewController(anime: anime)
        let nav = UINavigationController(rootViewController: animeVC)
        parent.present(nav, animated: true)
    }
    
    static func showMangaVC(in parent: UIViewController, manga: Manga) {
        let mangaVC = MangaViewController(manga: manga)
        let nav = UINavigationController(rootViewController: mangaVC)
        parent.present(nav, animated: true)
    }
    
    private static func initialTabBarController() -> UITabBarController {
        let tab = UITabBarController()
        tab.view.backgroundColor = Theme.ControllerTheme().backgroundColor
        tab.tabBar.isTranslucent = false
        tab.tabBar.tintColor = Theme.Colors().secondary
        return tab
    }
    
    private static func mediaTrendingVC() -> MediaTrendingViewController {
        return MediaTrendingViewController()
    }
    
    private static func mediaDiscoverVC() -> MediaDiscoverViewController {
        return MediaDiscoverViewController()
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
    
    ///Show a youtube video in a controller.
    static func showYoutubeVideo(videoID: String, in controller: UIViewController) {
        guard !videoID.isEmpty else { return }
        
        //Allow audio
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        //Show the video
        let player = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoID)
        controller.present(player, animated: true)
        
    }
}
