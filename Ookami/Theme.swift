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
    
    struct ActivityIndicatorTheme {
        var color = UIColor(hexString: "#02b4ef")
        var size = CGSize(width: 40, height: 40)
    }
    
    struct NavigationTheme {
        var barColor = UIColor(hexString: "#2F343B")
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
        var backgroundColor = UIColor(hexString: "#2F343B").darkened(amount: 0.04)
        var selectionBackgroundColor = UIColor(hexString: "#2F343B").darkened(amount: 0.1)
        var seperatorColor = UIColor.black
        var textColor = UIColor.white
    }
    
    struct PagerButtonBarTheme {
        var backgroundColor = UIColor(hexString: "#2F343B").darkened(amount: 0.02)
        var buttonColor = UIColor(hexString: "#2F343B").darkened(amount: 0.02)
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
