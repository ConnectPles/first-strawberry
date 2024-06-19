//
//  LoginViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 3/5/24.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var googleSigninButton: UIButton!
    
    @IBOutlet weak var warningLabel: UILabel!
        
    @IBOutlet weak var darkenedImageView: DarkenedImageView!
    
    var textFieldWidth: CGFloat?
    var textFieldHeight: CGFloat?
    
    
    let userAccount = UserManager.sharedInstance

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.darkenedImageView.hideLoading()
        
        do {//Create username textfield
            self.textFieldWidth = self.view.frame.width / 3 * 2
            self.textFieldHeight = self.view.frame.height / 15
            
            let emailTextFieldIcon = UIImage(systemName: "person.fill")
            let emailTextFieldImageView = UIImageView(image: emailTextFieldIcon)
            emailTextFieldImageView.tintColor = .gray
            self.emailTextField.leftView = emailTextFieldImageView
            self.emailTextField.leftViewMode = .always
            self.emailTextField.borderStyle = .roundedRect
            self.emailTextField.placeholder = "Email"
        }
        do {//Create password textfield
            let passwordTextFieldIcon = UIImage(systemName: "lock.fill")
            let passwordTextFieldImageView = UIImageView(image: passwordTextFieldIcon)
            passwordTextFieldImageView.tintColor = .gray
            self.passwordTextField.leftView = passwordTextFieldImageView
            self.passwordTextField.leftViewMode = .always
            
            self.passwordTextField.borderStyle = .roundedRect
            self.passwordTextField.placeholder = "Password"
            
            //set visible toggle
            let passwordVisibilityBtn = UIButton(type: .custom)
            let passwordInvisibleIcon = UIImage(systemName: "eye.slash.fill")
            let passwordVisibleIcon = UIImage(systemName: "eye.fill")
            passwordVisibilityBtn.setImage(passwordInvisibleIcon, for: .normal)
            passwordVisibilityBtn.setImage(passwordVisibleIcon, for: .selected)
            passwordVisibilityBtn.tintColor = .gray
            passwordVisibilityBtn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
            self.passwordTextField.rightView = passwordVisibilityBtn
            self.passwordTextField.rightViewMode = .always
            self.passwordTextField.isSecureTextEntry = true
        }
        do {//set dismiss keyboard
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(dismissTap)
        }
        do {//adjust login button style
            self.loginBtn.layer.borderWidth = 2
            self.loginBtn.layer.cornerRadius = 30
            self.loginBtn.layer.borderColor = UIColor(red: 1, green: 0.625, blue: 0.625, alpha: 1).cgColor
        }
        do {// warning label setup
            self.warningLabel.text = ""
        }
        do {//set google signup button
            self.googleSigninButton.layer.borderWidth = 2
            self.googleSigninButton.layer.cornerRadius = 30
            self.googleSigninButton.layer.borderColor = UIColor(red: 1, green: 0.625, blue: 0.625, alpha: 1).cgColor
            self.googleSigninButton.layer.backgroundColor = UIColor.white.cgColor
            self.googleSigninButton.setImage(UIImage(named: "GoogleLogo"), for: .normal)
        }
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        self.warningLabel.text = ""
        
        self.darkenedImageView.showLoading()

        if (self.emailTextField.hasText && self.passwordTextField.hasText &&
            self.userAccount.isValidEmail(testStr: self.emailTextField.text!) && self.userAccount.isPasswordSecure(password: self.passwordTextField.text!) == nil) {
            userAccount.loginUser(email: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { result in
                switch result {
                case .success:
                    self.performSegue(withIdentifier: "LoginToMain", sender: sender)
                case .failure(let authError):
                    switch authError {
                    case .userNotFound:
                        self.presentAlert(title: "New User?", message: "Press Confirm to register.", authError: .userNotFound)
                    case .wrongPassword:
                        self.presentAlert(title: "Login Failed", message: "User not found or password does not match.", authError: .wrongPassword)
                    case .invalidEmail:
                        self.presentAlert(title: "Login Failed", message: "Email invalid.", authError: .invalidEmail)
                    default:
                        self.presentAlert(title: "Unknown Error", message: "", authError: .unknownError(""))
                    }
                }

                self.darkenedImageView.hideLoading()
            })
        } else {
            self.darkenedImageView.hideLoading()
            self.warningLabel.text = "Please choose a login method or sign up!"
        }
    }
    
    
    @IBAction func googleSignInBtnTapped(_ sender: UIButton) {
        self.darkenedImageView.showLoading()
        self.userAccount.signupOrSigninByGoogle(ViewToPresent: self, completion: { result in
            switch result {
            case .success:
                self.darkenedImageView.hideLoading()
                self.performSegue(withIdentifier: "LoginToMain", sender: sender)
            case .failure(let authError):
                self.darkenedImageView.hideLoading()
                self.presentAlert(title: "Unknown Error", message: "", authError: authError)
            }
        })
    }
    
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry.toggle()
        sender.isSelected = !sender.isSelected
    }
    
    //for dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.warningLabel.text = ""
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.warningLabel.text = ""
        if textField == self.emailTextField {
            if (textField.text != nil && self.userAccount.isValidEmail(testStr: textField.text!) == false) {
                self.warningLabel.text = "Email format not valid."
            } else {
                self.warningLabel.text = ""
            }
        } else {
            if let passwordText = textField.text {
                if let passwordWarning = self.userAccount.isPasswordSecure(password: passwordText) {
                    self.warningLabel.text = passwordWarning
                } else {
                    self.warningLabel.text = ""
                }
            }
        }
    }
    
    //If textfield keyboard return key is pressed, retrieve keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func presentAlert(title: String, message: String, authError: AuthError) {
        let loginAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        switch authError {
            case .userNotFound:
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in

                    self.darkenedImageView.showLoading()
                    self.userAccount.signupByEmailPassword(email: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { signupError in
                        switch signupError {
                            case .failure(_):
                                self.darkenedImageView.hideLoading()
                                //create new alert
                                let signupAlert = UIAlertController(title: "Register Failed", message: "Unable to register. Please try again.", preferredStyle: .alert)
                                signupAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                                if !signupAlert.isBeingPresented {
                                    self.present(signupAlert, animated: true, completion: nil)
                                }
                            case .success(_):
                                self.darkenedImageView.hideLoading()
                            self.performSegue(withIdentifier: "LoginToMain", sender: self)
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                        }
                    })
                }
                loginAlert.addAction(confirmAction)
                
                // Add a Cancel action
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }
                loginAlert.addAction(cancelAction)

            default:
                let confirmAction = UIAlertAction(title: "Confirm", style: .default){ _ in
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }
                loginAlert.addAction(confirmAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }
                loginAlert.addAction(cancelAction)
            }
        
        if !loginAlert.isBeingPresented {
            present(loginAlert, animated: true, completion: nil)
            
        }
    }
    
}
