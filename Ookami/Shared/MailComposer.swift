//
//  MailComposer.swift
//  Ookami
//
//  Created by Maka on 28/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import MessageUI
import OokamiKit

//A class to handle the mail composing
class MailComposer: NSObject, MFMailComposeViewControllerDelegate {
    
    weak var parent: UIViewController?
    var mailController: MFMailComposeViewController {
        let c = MFMailComposeViewController()
        c.mailComposeDelegate = self
        
        c.setToRecipients(["mikunj@live.com.au"])
        c.setMessageBody("", isHTML: false)
        
        let user = CurrentUser().user?.name ?? "Anonymous"
        let subject = "[Ookami Feedback] - \(user)"
        c.setSubject(subject)
        
        c.title = "Feedback"
        
        return c
    }
    
    init(parent: UIViewController) {
        self.parent = parent
    }
    
    func present() {
        if !MFMailComposeViewController.canSendMail(),
            let parent = parent {
            ErrorAlert.showAlert(in: parent, title: "Could not send feedback", message: "Mail account is not configured on this device!")
            return
        }
        
        if parent?.presentedViewController == nil {
            parent?.present(mailController, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
            
        case MFMailComposeResult.saved:
            print("Mail saved")
            
        case MFMailComposeResult.sent:
            print("Mail sent")
            
        case MFMailComposeResult.failed:
            print("Mail sent failure")
            
            //We dismiss the controller after showing the error
            showError(controller: controller, title: "Mail Sent Failure", message: error!.localizedDescription, completion: {
                controller.dismiss(animated: true)
            })
            return
            
        }
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true)
        
    }
    
    func showError(controller: MFMailComposeViewController, title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            completion()
        }
        alert.addAction(action)
        
        //Present the alert if we haven't
        if controller.presentedViewController == nil {
            controller.present(alert, animated: true)
        }

    }
}
