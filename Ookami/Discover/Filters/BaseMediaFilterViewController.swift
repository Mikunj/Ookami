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
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancel))
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSave))
        
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = save
    }
    
    func didCancel() {
        dismiss(animated: true)
    }
    
    func didSave() {
        dismiss(animated: true)
    }
    
    func reload() {
    }
}
