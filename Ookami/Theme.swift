//
//  Theme.swift
//  Ookami
//
//  Created by Maka on 4/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import DynamicColor

enum Theme {}

extension Theme {
    
    struct Colors {
        var primary = UIColor(hexString: "#2F343B")
        var secondary = UIColor(hexString: "#02b4ef")
    }
    
    struct ActivityIndicatorTheme {
        var color = Colors().secondary
        var size = CGSize(width: 40, height: 40)
    }
    
    struct NavigationTheme {
        var barColor = Colors().primary
        var barTextColor = UIColor.white
        
        func apply() {
            let appearance = UINavigationBar.appearance()
            appearance.isTranslucent = false
            appearance.barTintColor = barColor
            appearance.tintColor = barTextColor
            appearance.titleTextAttributes = [NSForegroundColorAttributeName: barTextColor]
        }
    }
    
    struct DropDownTheme {
        var backgroundColor = Colors().primary.darkened(amount: 0.04)
        var selectionBackgroundColor = Colors().primary.darkened(amount: 0.1)
        var seperatorColor = UIColor.black
        var textColor = UIColor.white
    }
    
    struct PagerButtonBarTheme {
        var backgroundColor = Colors().primary.darkened(amount: 0.02)
        var buttonColor = Colors().primary.darkened(amount: 0.02)
        var buttonTextColor = UIColor.white
    }
    
    //Theme for the controllers
    struct ControllerTheme {
        var backgroundColor = UIColor.groupTableViewBackground
    }
    
    struct ViewTheme {
        var backgroundColor = UIColor.white
        
    }
    
    //Any text based elements
    struct TextTheme {
        var textColor = UIColor.black
    }
}
