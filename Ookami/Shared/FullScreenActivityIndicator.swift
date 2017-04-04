//
//  FullScreenActivityIndicator.swift
//  Ookami
//
//  Created by Maka on 30/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography
import NVActivityIndicatorView

//A class for displaying a full screen activity indicator as that on the login and signup pages
class FullScreenActivityIndicator {
    
    //The activity indicator
    var activityIndicator: NVActivityIndicatorView = {
        let theme = Theme.ActivityIndicatorTheme()
        let view = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: theme.size), type: theme.type, color: theme.color)
        return view
    }()
    
    //The indicator overlay for displaying
    var indicatorOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return v
    }()
    
    func add(to view: UIView) {
        view.addSubview(indicatorOverlay)
        constrain(indicatorOverlay) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the indicator ontop of the overlay
        indicatorOverlay.addSubview(activityIndicator)
        let size = Theme.ActivityIndicatorTheme().size
        constrain(activityIndicator) { view in
            view.center == view.superview!.center
            view.width == size.width
            view.height == size.height
        }
        
        hideIndicator()
    }
    
    func showIndicator() {
        UIView.animate(withDuration: 0.25) {
            self.activityIndicator.startAnimating()
            self.indicatorOverlay.isHidden = false
        }
    }
    
    func hideIndicator() {
        UIView.animate(withDuration: 0.25) {
            self.activityIndicator.stopAnimating()
            self.indicatorOverlay.isHidden = true
        }
    }
}
