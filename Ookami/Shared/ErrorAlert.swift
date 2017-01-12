//
//  ErrorAlert.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

class ErrorAlert {
    private init() {}
    
    static func showAlert(in controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        //Present the alert if we haven't
        if controller.presentedViewController == nil {
            controller.present(alert, animated: true)
        }
        
    }
}
