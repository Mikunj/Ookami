//
//  SignupViewController.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import NVActivityIndicatorView

class SignupViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameIndicator: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailIndicator: UIImageView!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordIndicator: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var onSignupSuccess: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Theme.Colors().primary
        signupButton.backgroundColor = Theme.Colors().secondary
        
        nameField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        updateUI()
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSignup(_ sender: UIButton) {
        
        let name = nameField.text ?? ""
        let email = emailField.text ?? ""
        let pass = passwordField.text ?? ""
        signupButton.isEnabled = false
        
        let theme = Theme.ActivityIndicatorTheme()
        startAnimating(theme.size, type: theme.type, color: theme.color)
        
        AuthenticationService().signup(name: name, email: email, password: pass) { error in
            self.signupButton.isEnabled = true
            self.stopAnimating()
            
            guard error == nil else {
                ErrorAlert.showAlert(in: self, title: "Sign up Error", message: "\(error!.localizedDescription). Please try again.")
                return
            }
            
            self.onSignupSuccess?()
        }
        
    }
    
    
    func updateUI() {
        let nameValid = isNameValid()
        let passValid = isPasswordValid()
        let emailValid = isEmailValid()
        
        let theme = Theme.Colors()
        let size = CGSize(width: 22, height: 22)
        let cross = FontAwesomeIcon.removeIcon.image(ofSize: size, color: theme.red)
        let tick = FontAwesomeIcon.okIcon.image(ofSize: size, color: theme.green)
        
        signupButton.isEnabled = nameValid && passValid && emailValid
        signupButton.alpha = signupButton.isEnabled ? 1.0 : 0.75
        
        nameIndicator.image = nameValid ? tick : cross
        emailIndicator.image = emailValid ? tick : cross
        passwordIndicator.image = passValid ? tick : cross
    }
    
    func isNameValid() -> Bool {
        return !(nameField.text ?? "").isEmpty
    }
    
    func isPasswordValid() -> Bool {
        let password = passwordField.text ?? ""
        return password.characters.count >= 8
    }
    
    func isEmailValid() -> Bool {
        let email = emailField.text ?? ""
        return email.contains("@")
    }
    
    func textFieldDidChange(textField: UITextField) {
        updateUI()
    }
}
