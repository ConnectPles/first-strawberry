//
//  CommunityAccount.swift
//  CSCI401-Proj7
//
//  Created by Nolan Chen on 9/25/23.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

import UIKit.UIViewController

class UserAccount {
    //make current class static
    static let sharedInstance = UserAccount()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let UserAccountRef: DatabaseReference?
    
    init() {
        self.UserAccountRef = Database.database().reference().child("UserAccounts")

        Auth.auth().addStateDidChangeListener{ Auth, User in
            if let user = User {
                print("logged in:" + user.uid)
            }
            else {
                print("User logged out.")
            }
            
        }
    }

    
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    private func containsOnlyAlphanumerics(_ string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics
        return string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
    }
    
    func containsOnlyLettersAndSpaces(_ string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
       return string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
   }
    
    public func getUnauthenticatedUsersNames(callback: @escaping ([String]?) -> Void) {
        UserAccountRef?.observeSingleEvent(of: .value, with: { snapshot in
            var unauthenticatedUserNames: [String] = []
            
            guard let value = snapshot.value as? [String: Any] else {
                callback(nil)
                return
            }
            
            for (_, userData) in value {
                guard let userDataDict = userData as? [String: Any],
                    let isAuthenticated = userDataDict["isAuthenticated"] as? Bool,
                    !isAuthenticated,
                    let firstName = userDataDict["firstName"] as? String else {
                    // Skip users who are authenticated or do not have a first name
                    continue
                }
                
                unauthenticatedUserNames.append(firstName)
            }
            
            callback(unauthenticatedUserNames)
        }) { error in
            print("Error fetching unauthenticated users: \(error.localizedDescription)")
            callback(nil)
        }
    }


}
