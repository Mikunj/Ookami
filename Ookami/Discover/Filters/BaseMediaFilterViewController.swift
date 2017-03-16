//
//  BaseMediaFilterViewController.swift
//  Ookami
//
//  Created by Maka on 24/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography

class BaseMediaFilterViewController: UIViewController {
    
    //The filter view
    var filterView: FilterViewController
    
    init() {
        filterView = FilterViewController(filters: [])
        super.init(nibName: nil, bundle: nil)
        self.reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init() instead.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        //Add the filter view
        self.addChildViewController(filterView)
        self.view.addSubview(filterView.view)
        
        constrain(filterView.view) { view in
            view.edges == view.superview!.edges
        }
        
        filterView.didMove(toParentViewController: self)
        
        //Add the save and cancel buttons
        let cancelImage = UIImage(named: "Close")
        let cancel = UIBarButtonItem(image: cancelImage, style: .done, target: self, action: #selector(didCancel))
        
        let clear = UIBarButtonItem(withIcon: .trashIcon, size: CGSize(width: 22, height: 22), target: self, action: #selector(didClear))
        
        let saveImage = UIImage(named: "Check")
        let save = UIBarButtonItem(image: saveImage, style: .done, target: self, action: #selector(didSave))
        
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItems = [save, clear]
    }
    
    func didCancel() {
        dismiss(animated: true)
    }
    
    func didSave() {
        dismiss(animated: true)
    }
    
    func didClear() {
        
    }
    
    func reload() {
    }
}
