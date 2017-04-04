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
import FBSDKLoginKit
import OnePasswordExtension

class LoginViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var onePasswordButton: UIButton!
    
    var activityIndicator: FullScreenActivityIndicator = {
        return FullScreenActivityIndicator()
    }()
    
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
        
        activityIndicator.add(to: view)
        
        self.view.backgroundColor = Theme.Colors().primary
        loginButton.backgroundColor = Theme.Colors().secondary
        onePasswordButton.tintColor = Theme.Colors().secondary
        
        //Check if we have 1 pass installed, if not hide the button
        onePasswordButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
        
        usernameField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        updateLoginButton()
        
        //Set the icon on the facebook button
        let fb = FontAwesomeIcon.facebookSignIcon.image(ofSize: CGSize(width: 22, height: 22), color: UIColor.white)
        facebookButton.setImage(fb, for: .normal)
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        loginButton.isEnabled = false
        
        activityIndicator.showIndicator()
        
        AuthenticationService().authenticate(usernameOrEmail: username, password: password) { error in
            DispatchQueue.main.async {
                self.loginButton.isEnabled = true
                self.activityIndicator.hideIndicator()
                
                guard error == nil else {
                    ErrorAlert.showAlert(in: self, title: "Login Error", message: "\(error!.localizedDescription). Please try again.")
                    return
                }
                
                self.onLoginSuccess?()
            }
            
        }
    }
    
    @IBAction func didTapOnePassword(_ sender: Any) {
        OnePasswordExtension.shared().findLogin(forURLString: "https://kitsu.io", for: self, sender: sender) { dict, error in
            guard let dict = dict else {
                if (error! as NSError).code != Int(AppExtensionErrorCodeCancelledByUser) {
                    ErrorAlert.showAlert(in: self, title: "1 Password Error", message: "An error occured! \(error!.localizedDescription)")
                }
                return
            }
            
            //Change in the main queue
            DispatchQueue.main.async {
                let username = dict[AppExtensionUsernameKey] as? String
                let password = dict[AppExtensionPasswordKey] as? String
                self.updateText(username: username, password: password)
            }
        }
    }
    
    @IBAction func didTapSignup(_ sender: UIButton) {
        showSignUp()
    }
    
    func updateText(username: String?, password: String?) {
        UIView.animate(withDuration: 0.3) {
            self.usernameField.text = username
            self.passwordField.text = password
            self.updateLoginButton()
        }
    }
    
    //Show the signup view
    func showSignUp(facebookID: String? = nil, email: String? = nil) {
        let signup = SignupViewController()
        signup.facebookID = facebookID
        signup.initialEmail = email
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
    
    //MARK:- Facebook
    
    //Facebook button tap
    @IBAction func didTapFacebook(_ sender: Any) {
        
        //Force a logout
        FBSDKLoginManager().logOut()
        
        //Login
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { result, error in
            //Check for errors
            guard error == nil else {
                ErrorAlert.showAlert(in: self, title: "Facebook Login Error", message: "\(error!.localizedDescription). Please try again.")
                return
            }
            
            //Check for cancelation
            guard let result = result,
                !result.isCancelled,
                let token = result.token else {
                    return
            }
            
            //Check that we have the email permission grant atlease
            guard let grantedPermissions = result.grantedPermissions,
                grantedPermissions.contains("email") else {
                    ErrorAlert.showAlert(in: self, title: "Facebook Login Error", message: "Email permission must be granted to login to Kitsu!")
                    
                    FBSDKLoginManager().logOut()
                    
                    return
            }
            
            //Start auth
            DispatchQueue.main.async {
                self.activityIndicator.showIndicator()
            }
            
            //Get the token and login
            AuthenticationService().authenticate(facebookToken: token.tokenString, register: self.registerFacebookUser, completion: self.onFacebookCompletion)
        }
    }
    
    //Register the facebook user to kitsu
    func registerFacebookUser() {
        
        //User needs to be registered. Fetch their email and show them the signup page
        let params = ["fields": "email"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start { connection, result, error in
            
            DispatchQueue.main.async {
                //Stop the loading indicator
                self.activityIndicator.hideIndicator()
                
                let id = FBSDKAccessToken.current().userID
                
                guard error == nil,
                    let data = result as? [String: Any],
                    let email = data["email"] as? String else {
                        ErrorAlert.showAlert(in: self, title: "Facebook Login Error", message: "Something went wrong when fetching email :(")
                        
                        FBSDKLoginManager().logOut()
                        return
                }
                
                FBSDKLoginManager().logOut()
                
                
                self.showSignUp(facebookID: id, email: email)
            }
        }
        
    }
    
    //Facebook login completed
    func onFacebookCompletion(error: Error?) {
        
        DispatchQueue.main.async {
            
            //Stop the loading indicator
            self.activityIndicator.hideIndicator()
            
            //Logout of facebook
            FBSDKLoginManager().logOut()
            
            guard error == nil else {
                ErrorAlert.showAlert(in: self, title: "Login Error", message: "\(error!.localizedDescription). Please try again.")
                return
            }
            
            self.onLoginSuccess?()
        }
    }
    
}

