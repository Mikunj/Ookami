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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FontAwesomeIcon.register()
        IQKeyboardManager.shared().isEnabled = true
        Theme.NavigationTheme().apply()
        
        window = UIWindow(frame: UIScreen.main.bounds);
        
        if CurrentUser().isLoggedIn() {
            AppCoordinator.showStartingVC(in: window!)
        } else {
            AppCoordinator.showLoginVC(in: window!)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CacheManager().clearCache()
    }

}

