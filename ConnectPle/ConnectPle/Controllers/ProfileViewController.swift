//
//  ProfileViewController.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/14/24.
//

import UIKit

class ProfileViewController: UIViewController {

    
    
    let userAccount = UserManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        userAccount.logoutUser(completion: { result in
            if result {
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.present(UIAlertController(title: "Logout error", message: "Failed to log out", preferredStyle: .alert), animated: true)
            }
        })
    }
    
}
