//
//  AppDelegate.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import UIKit
import IQKeyboardManager
import OokamiKit
import FBSDKLoginKit
import Siren

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fetcher: LibraryFetcher?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Initialise libraries
        MigrationManager().applyMigrations()
        FontAwesomeIcon.register()
        Theme.NavigationTheme().apply()
        IQKeyboardManager.shared().isEnabled = true
        
        //Alert user of any updates
        Siren.shared.checkVersion(checkType: .immediately)
        
        //Preload data
        Preloader().preloadData()
        
        //Start the fetching timer
        fetcher = LibraryFetcher()
        fetcher?.startFetching()
        
        //Register for logout notification
        let logout = CurrentUser.Notifications.userLoggedOut.name
        NotificationCenter.default.addObserver(self, selector: #selector(showLogin), name: logout, object: nil)
        
        window = UIWindow(frame: UIScreen.main.bounds);
        
        //Check for UITest
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            AppCoordinator.showStartingVC(in: window!, isUITest: true)
            return true
        }
        
        //Main
        if CurrentUser().isLoggedIn() {
            AppCoordinator.showStartingVC(in: window!)
            
            //Update the user info
            AuthenticationService().updateInfo() { _ in }
        } else {
            showLogin()
        }
        
        return true
    }
    
    func showLogin() {
        
        //If we're not logged in then clear facebook login
        if !CurrentUser().isLoggedIn() {
            FBSDKLoginManager().logOut()
        }
    
        if let window = window {
            AppCoordinator.showLoginVC(in: window)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        fetcher?.stopFetching()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        fetcher?.startFetching()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        CacheManager.shared.clearCache()
        fetcher?.stopFetching()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .daily)
    }
    
}

