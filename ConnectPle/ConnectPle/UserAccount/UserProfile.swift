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
    private var localUserModel: UserModel? {
        didSet {
            previousLocalUserModel = oldValue
        }
    }
    private var previousLocalUserModel: UserModel?

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
        
        let newUserModel = UserModel(firstName: firstName, lastName: lastName)
        self.updateUser(newUserProfile: newUserModel, completion: { updateResult in
            if updateResult {
                self.setupDatabaseListener(completion: { listenerResult in completion(listenerResult) })
            } else {
                print("New User Profile setup failed.")
                completion(false)
            }
        })
    }
    
    //helper function to check if user already has profile
    static func ifUserProfileExist(dataPath: String, userId: String, completion: @escaping ((Bool) -> Void)) {
        Database.database().reference().child(dataPath).child(userId).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func getFirstName() -> String {
        return self.localUserModel!.getFirstName()
    }
    func getLastName() -> String {
        return self.localUserModel!.getLastName()
    }
    func updateName(newFirstName: String?, newLastName: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userProfile = self.localUserModel else { return }
        userProfile.updateName(firstName: newFirstName, lastName: newLastName)
        updateUser(newUserProfile: userProfile, completion: { result in
            completion(result)
        })
    }
    
    func getMenuListNames() -> [String] {
        return Array(self.localUserModel!.getMenuList().keys)
    }
    
    func getMenuListCount() -> Int {
        return self.localUserModel!.getMenuList().count
    }
    
    func getItemName(ByIndex index: Int) -> String? {
        let names = self.getMenuListNames()
        if index < 0 || index >= names.count {
            return nil
        }
        return names[index]
    }
    
    func getItemInfo(By itemName: String) -> MenuItem? {
        return self.localUserModel!.getMenuItem(itemName)
    }
    
    func addItem(itemName: String, rate: Int, imageURL: URL?, description: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userModel = self.localUserModel else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }

        if userModel.addMenuItem(itemName: itemName, rate: rate, imageURL: imageURL?.absoluteString, description: description) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userModel, completion: { result in
            completion(result)
        })
    }
    
    func removeItem(ByName itemName: String, completion: @escaping ((Bool) -> Void)) {
        guard let userModel = self.localUserModel else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }
        if userModel.removeMenuItem(ByItemName: itemName) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userModel, completion: { result in
            completion(result)
        })
    }
    
    func removeItem(ByIndex index: Int, completion: @escaping ((Bool) -> Void)) {
        guard let userModel = self.localUserModel else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }
        //if contains image, remove image first
        if let imageURL = userModel.getImageURL(ByIndex: index) {
            self.deleteImageFromFirebaseStorage(fromURL: imageURL, completion: { error in
                if error == nil {
                    if userModel.removeMenuItem(ByIndex: index) == false {
                        print("ERROR: remove item failed.")
                        completion(false)
                        return
                    }
                    self.updateUser(newUserProfile: userModel, completion: { result in
                        completion(result)
                    })
                } else {
                    print("ERROR delete images: \(String(describing: error))")
                    completion(false)
                }
            })
        }
//        if userModel.removeMenuItem(ByIndex: index) == false {
//            completion(false)
//            return
//        }
//        updateUser(newUserProfile: userModel, completion: { result in
//            completion(result)
//        })
    }
    
    func updateItem(itemName: String, newRate: Int?, newImageURL: URL?, newDescription: String?, completion: @escaping ((Bool) -> Void)) {
        guard let userModel = self.localUserModel else {
            print("ERROR: local userProfile not exist.")
            completion(false)
            return
        }
        if userModel.updateMenuItem(itemName: itemName, newRate: newRate, newImageURL: newImageURL?.absoluteString, newDescrption: newDescription) == false {
            completion(false)
            return
        }
        updateUser(newUserProfile: userModel, completion: { result in
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
            let userDict = snapshot.value as! [String: Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: .prettyPrinted)
                let remoteUser = try self.decoder.decode(UserModel.self, from: jsonData)
                // Update local data model
                self.localUserModel = remoteUser
                completion(true)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(false)
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
                    print("Remote Update: User Profile Update successful")
                    completion(true)
                }
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func updateLocalData(newUserProfile: UserModel) {
        self.localUserModel = newUserProfile
    }
    
    private func revertLocalChanges() {
        if let previousUser = previousLocalUserModel {
            localUserModel = previousUser
        }
    }
    
    func checkIfItemNameExists (itemName: String) -> Bool {
        return self.localUserModel!.isMenuItemExist(itemName: itemName)
    }
    
    func uploadImageToFirebaseStorage(image: UIImage?, completion: @escaping (String?, URL?) -> Void) {
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            completion(nil, nil)
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("ERROR uploading image: \(error.localizedDescription)")
                completion("Image Upload Failed", nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("ERROR getting download URL: \(error.localizedDescription)")
                    completion("Image URL Inaccessible", nil)
                    return
                }
                completion(nil, url)
            }
        }
    }
    
    func deleteImageFromFirebaseStorage(fromURL url: URL, completion: @escaping (String?) -> Void) {
        print(url.absoluteString)
        if url.absoluteString == DEFAULT_IMAGE_URL {
            print("Image is default.")
            completion(nil)
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: url.absoluteString)

        storageRef.delete() { error in
            if let error = error {
                let errorMessage = "Failed to delete image: \(error.localizedDescription)"
                print(errorMessage)
                completion(errorMessage)
            } else {
                print("Image successfully deleted")
                completion(nil)
            }
        }
    }
    
    
    func downloadImage(imageURL: URL?, completion: @escaping ((UIImage?) -> Void)) {
        if let imageURL = imageURL {
            // Using Kingfisher to download the image
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    completion(value.image)
                case .failure(let error):
                    print("ERROR downloading image: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else {
            print("ERROR downloading image: Invalid URL string \"\(String(describing: imageURL))\"")
            completion(nil)
            return
        }
    }
}
