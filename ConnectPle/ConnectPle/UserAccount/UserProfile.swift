//
//  UserManager.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/10/24.
//

import Foundation
import FirebaseDatabase
import FirebaseCore

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
        
        let newUserProfile = UserModel(firstName: firstName, lastName: lastName, menuList: [:])
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
        return self.localUserProfile!.firstName
    }
    func getLastName() -> String {
        return self.localUserProfile!.lastName
    }
    func getList() -> [String: MenuItem] {
        return self.localUserProfile!.menuList
    }
    func updateMenuList(itemName: String, itemInfo: MenuItem) {
        guard let userProfile = self.localUserProfile else { return }
        userProfile.addMenuItem(itemName: itemName, itemInfo: itemInfo)
        updateUser(newUserProfile: userProfile, completion: {_ in})
    }
    func updateFirstName(newFirstName: String) {
        guard let userProfile = self.localUserProfile else { return }
        userProfile.firstName = newFirstName
        updateUser(newUserProfile: userProfile, completion: {_ in})
    }
    func updateLastName(newLastName: String) {
        guard let userProfile = self.localUserProfile else { return }
        userProfile.lastName = newLastName
        updateUser(newUserProfile: userProfile, completion: {_ in})
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
    
}
