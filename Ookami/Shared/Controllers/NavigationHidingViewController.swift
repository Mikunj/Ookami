//
//  NavigationHidingViewController.swift
//  Ookami
//
//  Created by Maka on 14/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

//A controller which has a custom navigation bar which is transparent but after a certain offset it becomes visible
class NavigationHidingViewController: UIViewController {
    
    //The navigation bar container view to emulate a navigation bar set by the system
    lazy var barContainer: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.NavigationTheme().barColor
        return v
    }()
    
    //The height constraint of the bar container
    var barContainerHeight: NSLayoutConstraint?
    
    //The navigation bar we use so we can get transparancy
    lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        let theme = Theme.NavigationTheme()
        bar.isTranslucent = true
        bar.barTintColor = UIColor.clear
        bar.tintColor = theme.barTextColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName: theme.barTextColor]
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.shadowImage = UIImage()
        
        let item = UINavigationItem(title: "")
        
        let close = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(didDismiss))
        item.leftBarButtonItem = close
        
        bar.setItems([item], animated: false)
        
        return bar
    }()
    
    //Variable to check if current VC is modal
    private var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        barContainer.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Add the bar
        barContainer.addSubview(navigationBar)
        constrain(navigationBar) { bar in
            bar.bottom == bar.superview!.bottom
            bar.left == bar.superview!.left
            bar.right == bar.superview!.right
            bar.height == 44
        }
        
        //The top view
        self.view.addSubview(barContainer)
        constrain(barContainer) { view in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            barContainerHeight = (view.height == 44)
        }
        updateBarContainerHeight()
        
        //May need to call this again in subclass
        self.view.bringSubview(toFront: barContainer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateBarContainerHeight()
    }
    
    //Update the height of the bar container incase of orientation changes
    func updateBarContainerHeight() {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let barHeight = self.navigationController?.navigationBar.frame.size.height ?? 44
        barContainerHeight?.constant = barHeight + statusHeight
        barContainer.layoutIfNeeded()
    }
    
    //The offset that makes the bar visible
    func visibleOffset() -> CGFloat {
        return 0
    }
    
    //The title to put on the bar
    func barTitle() -> String {
        return ""
    }
    
    /// The function to update the custom navigation bar display
    /// Call this in scrollViewDidScroll(:)
    func updateNavigationBar(offset: CGFloat = 0) {
        let minOffset: CGFloat = visibleOffset()
        
        UIView.animate(withDuration: 0.3) {
            let shouldShow = offset > minOffset
            let color = shouldShow ? Theme.NavigationTheme().barColor : UIColor.clear
            self.navigationBar.topItem?.title = shouldShow ? self.barTitle() : ""
            self.barContainer.backgroundColor = color
        }
    }
    
    //The dismiss button was pressed
    //We handle both cases incase we forget to present modally
    func didDismiss() {
        if isModal {
            self.dismiss(animated: true)
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

}
