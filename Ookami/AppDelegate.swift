//
//  AppDelegate.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import UIKit
import IQKeyboardManager
import OokamiKit

//TODO: Handle the case where user changes password but doesn't logout in the app. (maybe during launch, check auth and if valid then show main vc else show the login?)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fetcher: LibraryFetcher?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MigrationManager().applyMigrations()
        FontAwesomeIcon.register()
        Theme.NavigationTheme().apply()
        IQKeyboardManager.shared().isEnabled = true
        
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
        if let window = window {
            AppCoordinator.showLoginVC(in: window)
        }
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
    
}

