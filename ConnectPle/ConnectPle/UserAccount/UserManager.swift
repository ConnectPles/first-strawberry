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

class UserManager {
    //make current class static
    static let sharedInstance = UserManager()
    
    private var userAuth: User?
    private var userProfile: UserProfile?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    
    init() {
        Auth.auth().addStateDidChangeListener{ Auth, User in
            if let userAuth = User {
                print("logged in: " + userAuth.uid)
                self.userAuth = userAuth
            }
            else {
                print("User logged out.")
            }
        }
    }
    
    
    public func loginUser(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: ({ authResult, error in
            if error == nil && authResult != nil {
                //load existing user profile
                self.userProfile = UserProfile(uid: authResult!.user.uid, dataPath: DATA_PATH, completion: { result in
                    if result {
                        completion(.success(()))
                    } else {
                        completion(.failure(.unknownError("ERROR: Login: User profile not found")))
                    }
                })
            } else {
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.userNotFound.rawValue:
                        completion(.failure(.userNotFound))
                    case AuthErrorCode.wrongPassword.rawValue:
                        completion(.failure(.wrongPassword))
                    default:
                        print("Error: \(error.localizedDescription)")
                        completion(.failure(.unknownError(error.localizedDescription)))
                    }
                }
            }
        }))
    }
    
    
    private func loginUser(credential: AuthCredential, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Auth.auth().signIn(with: credential, completion: { authResult, authError in
            if authError == nil && authResult != nil {
                if let additionalUserInfo = authResult!.additionalUserInfo {
                    if additionalUserInfo.isNewUser {
                        //initialize new user profile
                        self.userProfile = UserProfile(
                            firstName: String("Fur" + authResult!.user.uid.prefix(5)), lastName: "Pup",
                            uid: authResult!.user.uid, dataPath: DATA_PATH, completion: { result in
                                if result {
                                    completion(.success(()))
                                } else {
                                    completion(.failure(.unknownError("ERROR: Login: User profile not found")))
                                }
                            }
                        )
                    } else {
                        //load existing user profile
                        self.userProfile = UserProfile(uid: authResult!.user.uid, dataPath: DATA_PATH, completion: { result in
                            if result {
                                completion(.success(()))
                            } else {
                                completion(.failure(.unknownError("ERROR: Login: User profile not found")))
                            }
                        })
                    }
                }
            } else {
                if let error = authError as NSError? {
                    switch error.code {
                    case AuthErrorCode.userNotFound.rawValue:
                        completion(.failure(.userNotFound))
                    case AuthErrorCode.wrongPassword.rawValue:
                        completion(.failure(.wrongPassword))
                    default:
                        print("Error: \(error.localizedDescription)")
                        completion(.failure(.unknownError(error.localizedDescription)))
                    }
                }
            }
            
        })
    }
    
    
    //logout user
    public func logoutUser(completion: @escaping (Bool) -> Void) {
            do {
                try Auth.auth().signOut()
                //unload existing user profile
                self.userProfile = nil
                completion(true)
            } catch let signOutError as NSError{
                print("Error signing out: %@", signOutError)
                completion(false)
            }
    }
    
//    
//    private func loadUserAccount (completion: @escaping (Bool) -> Void) {
//        if let userAuth = self.userAuth {
//            self.UserAccountRef!.child(userAuth.uid).observeSingleEvent(of: .value, with: { snapshot in
//                if snapshot.exists() {
//                    do {
//                        let userData = try JSONSerialization.data(withJSONObject: snapshot.value!)
//                        print("json result: \(userData)")
//                        self.userProfile = try self.decoder.decode(UserModel.self, from: userData)
//                        print("SUCCESS: UserAccount is loaded.")
//                        completion(true)
//                    } catch {
//                        print("ERROR: UserAccount parsing error: \(error)")
//                        completion(false)
//                    }
//                } else {
//                    print("ERROR: userAccount node not exist.")
//                    completion(false)
//                }
//            })
//        }
//        else {
//            onAuthUserLoaded.append(completion)
//        }
//    }
    
    public func signupByEmailPassword(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil && authResult != nil {
                //initialize new user profile
                self.userProfile = UserProfile(
                    firstName: String("Fur" + authResult!.user.uid.prefix(5)), lastName: "Pup",
                    uid: authResult!.user.uid, dataPath: DATA_PATH, completion: { result in
                        if result {
                            completion(.success(()))
                        } else {
                            completion(.failure(.unknownError("ERROR: Login: User profile not found")))
                        }
                    }
                )
            } else {
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        completion(.failure(.emailAlreadyInUse))
                    case AuthErrorCode.invalidEmail.rawValue:
                        completion(.failure(.invalidEmail))
                    default:
                        print("Error: \(error.localizedDescription)")
                        completion(.failure(.unknownError(error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    
    public func signupByGoogle(ViewToPresent: UIViewController, completion: @escaping (Result<Void, AuthError>) -> Void) {
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: ViewToPresent) { result, error in
                if error == nil && result != nil {
                    if let user = result?.user, let idToken = user.idToken?.tokenString {
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                        self.loginUser(credential: credential, completion: { loginResult in
                            completion(loginResult)
                        })
                    } else {
                        print("ERROR: GIDSignIn user not found.")
                        completion(.failure(.unknownError(error!.localizedDescription)))
                    }
                } else {
                    print("ERROR: GIDSignIn error: \(String(describing: error))")
                    completion(.failure(.unknownError(error!.localizedDescription)))
                }
            }
        } else {
            print("ERROR: Database ID not found.")
            completion(.failure(.unknownError("Database ID not found.")))
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