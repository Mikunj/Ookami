//
//  AppDelegate.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import UIKit
import IQKeyboardManager
import OokamiKit

//TODO: NEED A REALM MIGRATION CLASS!! DON'T FORGET!!
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fetcher: LibraryFetcher?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FontAwesomeIcon.register()
        IQKeyboardManager.shared().isEnabled = true
        Theme.NavigationTheme().apply()
        
        //Start the fetching timer
        fetcher = LibraryFetcher()
        fetcher?.startFetching()
        
        window = UIWindow(frame: UIScreen.main.bounds);
        
        if CurrentUser().isLoggedIn() {
            AppCoordinator.showStartingVC(in: window!)
            
            //Update the user info
            AuthenticationService().updateInfo() { _ in }
        } else {
            AppCoordinator.showLoginVC(in: window!)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        fetcher?.stopFetching()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        fetcher?.startFetching()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CacheManager().clearCache()
        fetcher?.stopFetching()
    }
    
}

