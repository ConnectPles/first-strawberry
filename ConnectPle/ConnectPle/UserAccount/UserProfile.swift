//
//  UserManager.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/10/24.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import UIKit.UIImage
import Kingfisher

class UserProfile {
    private let UID: String
    private let dataPath: String
    private var localUserProfile: UserModel? {
        didSet {
            previousLocalUserProfile = oldValue
        }
    }
    private var previousLocalUserProfile: UserModel?

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let userAccountRef: DatabaseReference?
    
    //constructor for existing user
    init(uid: String, dataPath: String, completion: @escaping ((Bool) -> Void)) {
        self.UID = uid
        self.dataPath = dataPath
        self.userAccountRef = Database.database().reference().child(dataPath)
        self.setupDatabaseListener(completion: { result in completion(result) })

    }
    
    //constructor for newly registered user
    init(firstName: String, lastName: String, uid: String, dataPath: String, completion: @escaping ((Bool) -> Void)) {
        self.UID = uid
        self.dataPath = dataPath
        self.userAccountRef = Database.database().reference().child(dataPath)
        
        let newUserProfile = UserModel(firstName: firstName, lastName: lastName)
        self.updateUser(newUserProfile: newUserProfile, completion: { updateResult in
            if updateResult {
                self.setupDatabaseListener(completion: { listenerResult in completion(listenerResult) })
            } else {
                print("New User Profile setup failed.")
                completion(false)
            }
        })
    }
    
    func getFirstName() -> String {
        return self.localUserProfile!.getFirstName()
    }
    func getLastName() -> String {
        return self.localUserProfile!.getLastName()
    }
    func updateName(newFirstName: String?, newLastName: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userProfile = self.localUserProfile else { return }
        userProfile.updateName(firstName: newFirstName, lastName: newLastName)
        updateUser(newUserProfile: userProfile, completion: { result in
            completion(result)
        })
    }
    
    func getList() -> [String: MenuItem] {
        return self.localUserProfile!.getMenuList()
    }
    func getItem(itemKey: String) -> MenuItem? {
        return self.localUserProfile!.getMenuItem(itemKey)
    }
    func addItem(itemName: String, rate: Int, imageURL: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userProfile = self.localUserProfile else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }

        if userProfile.addMenuItem(itemName: itemName, rate: rate, imageURL: imageURL) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userProfile, completion: { result in
            completion(result)
        })
    }
    func removeItem(itemName: String, completion: @escaping ((Bool) -> Void)) {
        guard let userProfile = self.localUserProfile else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }
        if userProfile.removeMenuItem(itemName: itemName) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userProfile, completion: { result in
            completion(result)
        })
    }
    func updateItem(itemName: String, newRate: Int?, newImageURL: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userProfile = self.localUserProfile else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }
        if userProfile.updateMenuItem(itemName: itemName, newRate: newRate, newImageURL: newImageURL) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userProfile, completion: { result in
            completion(result)
        })
    }
    
    private func updateUser(newUserProfile: UserModel, completion: @escaping ((Bool) -> Void)) {
        // Update local data immediately
        updateLocalData(newUserProfile: newUserProfile)
        
        // Update remote database
        updateRemoteDatabase(newUserProfile: newUserProfile, completion: { result in
            completion(result)
        })
    }
    
    private func setupDatabaseListener(completion: @escaping ((Bool) -> Void)) {
        self.userAccountRef!.child(self.UID).observe(.value, with: { snapshot in
            if snapshot.exists() == false {
                print("User Profile not yet created")
                completion(false)
                return
            }
            completion(true)
            let userDict = snapshot.value as! [String: Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: .prettyPrinted)
                let remoteUser = try self.decoder.decode(UserModel.self, from: jsonData)

                // Update local data model
                self.localUserProfile = remoteUser
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        })
    }
    
    private func updateRemoteDatabase(newUserProfile: UserModel, completion: @escaping ((Bool) -> Void)) {
        do {
            let userData = try JSONEncoder().encode(newUserProfile)
            let userDict = try JSONSerialization.jsonObject(with: userData, options: .allowFragments) as? [String: Any]
            self.userAccountRef!.child(self.UID).setValue(userDict) { error, _ in
                if let error = error {
                    print("Update failed: \(error.localizedDescription)")
                    // Optionally, revert local changes if the remote update fails
                    self.revertLocalChanges()
                    completion(false)
                } else {
                    print("User Profile Update successful")
                    completion(true)
                }
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func updateLocalData(newUserProfile: UserModel) {
        self.localUserProfile = newUserProfile
    }
    
    private func revertLocalChanges() {
        if let previousUser = previousLocalUserProfile {
            localUserProfile = previousUser
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("ERROR uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("ERROR getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    
    func downloadImage(imageURL: String?, completion: @escaping ((UIImage?) -> Void)) {
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            if imageURL == "" {
                completion(nil)
                print("ERROR downloading image: Image url is empty.")
                return
            }
            // Using Kingfisher to download the image
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    completion(value.image)
                case .failure(let error):
                    print("ERROR downloading image: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else {
            print("ERROR downloading image: Invalid URL string")
            completion(nil)
            return
        }
    }
}
