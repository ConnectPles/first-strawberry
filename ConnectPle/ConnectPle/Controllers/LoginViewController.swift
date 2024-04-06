//
//  LoginViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 3/5/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var textFieldWidth: CGFloat?
    var textFieldHeight: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        do {//Create username textfield
            self.textFieldWidth = self.view.frame.width / 3 * 2
            self.textFieldHeight = self.view.frame.height / 15
            
            let usernameTextFieldIcon = UIImage(systemName: "person.fill")
            let usernameTextFieldImageView = UIImageView(image: usernameTextFieldIcon)
            usernameTextFieldImageView.tintColor = .gray
            self.usernameTextField.leftView = usernameTextFieldImageView
            self.usernameTextField.leftViewMode = .always
            self.usernameTextField.borderStyle = .roundedRect
            self.usernameTextField.placeholder = "Username"
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
        do{//set dismiss keyboard
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
           view.addGestureRecognizer(dismissTap)
            
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry.toggle()
        sender.isSelected = !sender.isSelected
    }
    
    //for dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
//        alarmLabel.text = ""
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
//        alarmLabel.text = ""
    }
    
    //If textfield keyboard return key is pressed, retrieve keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
