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
    
    private var userAuth: User?
    private var userModel: UserModel?
    // Completion handler array between authUser and userModel
    private var onAuthUserLoaded: [(Bool) -> Void] = []
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let UserAccountRef: DatabaseReference?
    
    init() {
        self.UserAccountRef = Database.database().reference().child("UserAccounts")

        Auth.auth().addStateDidChangeListener{ Auth, User in
            if let userAuth = User {
                print("logged in: " + userAuth.uid)
                self.userAuth = userAuth
                self.loadUserAccount(completion: {_ in})
            }
            else {
                print("User logged out.")
            }
        }
    }
    
    
    public func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: ({ authResult, error in
            if error == nil && authResult != nil {
                completion(true)
            } else {
                print("Login email user failed: \(error!)")
                completion(false)
            }
        }))
    }
    
    
    private func loginUser(credential: AuthCredential, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(with: credential, completion: { authResult, authError in
            if authError == nil && authResult != nil {
                completion(true)
            } else {
                print("Login credential user failed: \(authError!)")
                completion(false)
            }
        })
    }
    
    
    //logout user
    public func logoutUser(completion: @escaping (Bool) -> Void) {
            do {
                try Auth.auth().signOut()
                completion(true)
            } catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
                completion(false)
            }
        
        
    }
    
    
    private func loadUserAccount (completion: @escaping (Bool) -> Void) {
        if let userAuth = self.userAuth {
            self.UserAccountRef!.child(userAuth.uid).observeSingleEvent(of: .value, with: { snapshot in
                do {
                    let userData = try JSONSerialization.data(withJSONObject: snapshot.value!)
                    print("json result: \(userData)")
                    self.userModel = try self.decoder.decode(UserModel.self, from: userData)
                    print("SUCCESS: UserAccount is loaded.")
                    completion(true)
                } catch {
                    print("ERROR: UserAccount parsing error: \(error)")
                    completion(false)
                }
            })
        }
        else {
            onAuthUserLoaded.append(completion)
        }
    }
    
    
    public func signupByGoogle(ViewToPresent: UIViewController, completion: @escaping (Bool) -> Void) {
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: ViewToPresent) { result, error in
                if error == nil {
                    if let user = result?.user, let idToken = user.idToken?.tokenString {
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                        self.loginUser(credential: credential, completion: { loginResult in
                            completion(loginResult)
                        })
                    } else {
                        print("ERROR: GIDSignIn user not found.")
                        completion(false)
                    }
                } else {
                    print("ERROR: GIDSignIn error: \(String(describing: error))")
                    completion(false)
                }
            }
        } else {
            print("ERROR: Database ID not found.")
            completion(false)
        }
    }


    public func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    
    public func containsOnlyAlphanumerics(_ string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics
        return string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
    }
    
    
    public func containsOnlyLettersAndSpaces(_ string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
       return string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
   }
    
    
    public func compressAndConvertImage(image: UIImage, compressionQuality: Double = 0.8) -> String? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("Unable to compress image.")
            return nil
        }
        return imageData.base64EncodedString()
    }
    
    
    public func isPasswordSecure(password: String) -> String? {
        // Check for minimum length
        guard password.count >= 8 else {
            return "Password requires at least 8 characters."
        }
        
        // Define the patterns for the different criteria
        let patterns = [
            ".*[A-Z]+.*", // At least one uppercase letter
            ".*[a-z]+.*", // At least one lowercase letter
            ".*[0-9]+.*", // At least one digit
            ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]+.*" // At least one special character
        ]
        
        // Check each pattern using regular expression
        for pattern in patterns {
            if password.range(of: pattern, options: .regularExpression) == nil {
                switch pattern {
                case patterns[0]:
                    return "Password requires at least one uppercase letter."
                case patterns[1]:
                    return "Password requires at least one lowercase letter."
                case patterns[2]:
                    return "Password requires at least one digit."
                case patterns[3]:
                    return "Password requires at least one special character."
                default:
                    return "Password is not secure enough."
                }
            }
        }
        return nil
    }
    
    public func getUnauthenticatedUsersNames(callback: @escaping ([String]?) -> Void) {
//        UserAccountRef?.observeSingleEvent(of: .value, with: { snapshot in
//            var unauthenticatedUserNames: [String] = []
//            
//            guard let value = snapshot.value as? [String: Any] else {
//                callback(nil)
//                return
//            }
//            
//            for (_, userData) in value {
//                guard let userDataDict = userData as? [String: Any],
//                    let isAuthenticated = userDataDict["isAuthenticated"] as? Bool,
//                    !isAuthenticated,
//                    let firstName = userDataDict["firstName"] as? String else {
//                    // Skip users who are authenticated or do not have a first name
//                    continue
//                }
//                
//                unauthenticatedUserNames.append(firstName)
//            }
//            
//            callback(unauthenticatedUserNames)
//        }) { error in
//            print("Error fetching unauthenticated users: \(error.localizedDescription)")
//            callback(nil)
//        }
    }


}
