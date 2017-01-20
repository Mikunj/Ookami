//
//  LoginViewController.swift
//  Ookami
//
//  Created by Maka on 12/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import NVActivityIndicatorView

class LoginViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var onLoginSuccess: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.Colors().primary
        loginButton.backgroundColor = Theme.Colors().secondary
        
        usernameField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        updateLoginButton()
    }

    @IBAction func didTapLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        loginButton.isEnabled = false
        
        let theme = Theme.ActivityIndicatorTheme()
        startAnimating(theme.size, type: theme.type, color: theme.color)
        
        AuthenticationService().authenticate(usernameOrEmail: username, password: password) { error in
            self.loginButton.isEnabled = true
            self.stopAnimating()
            
            guard error == nil else {
                ErrorAlert.showAlert(in: self, title: "Login Error", message: "\(error!.localizedDescription). Please try again.")
                return
            }
            
            self.onLoginSuccess?()
        }
    }
    
    @IBAction func didTapSignup(_ sender: UIButton) {
        let signup = SignupViewController()
        signup.onSignupSuccess = onLoginSuccess
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    func updateLoginButton() {
        //We disable login button if both fields are empty
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        loginButton.isEnabled = !(username.isEmpty || password.isEmpty)
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.75
    }
    
    func textFieldDidChange(textField: UITextField) {
        updateLoginButton()
    }
}
