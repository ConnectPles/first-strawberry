//
//  User.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/7/24.
//

import Foundation
class UserModel: Codable {

    private var firstName: String
    private var lastName: String
    private var menuList: [String: MenuItem]
    
    init(firstName: String, lastName: String, menuList: [String: MenuItem] = ["PLACE_HOLDER":MenuItem(rate: -1, imageURL: "")]) {
        self.firstName = firstName
        self.lastName = lastName
        self.menuList = menuList
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case menuList
    }
    
    // Encode properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(menuList, forKey: .menuList)
    }
    
    // Decode properties
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        menuList = try container.decode([String: MenuItem].self, forKey: .menuList)
    }
    
    func getFirstName() -> String {
        return self.firstName
    }
    func getLastName() -> String {
        return self.lastName
    }
    
    func updateName(firstName: String?, lastName: String?) {
        self.firstName = firstName ?? self.firstName
        self.lastName = lastName ?? self.lastName
    }
    
    func addMenuItem(itemName: String, rate: Int, imageURL: String?) -> Bool {
        if menuList.keys.contains(itemName) {
            print("ERROR: Item \(itemName) existed.")
            return false
        }
        menuList[itemName] = MenuItem(rate: rate, imageURL: imageURL ?? "DEFAULT")
        return true
    }
    
    func removeMenuItem(itemName: String) -> Bool {
        if menuList.keys.contains(itemName) == false {
            print("ERROR: Item \(itemName) not exist.")
            return false
        }
        menuList.removeValue(forKey: itemName)
        return true
    }
    
    func updateMenuItem(itemName: String, newRate: Int?, newImageURL: String?) -> Bool {
        if menuList.keys.contains(itemName) == false {
            print("ERROR: Item \(itemName) not exist!")
            return false
        }
        menuList[itemName]!.setNewImageURL(newImageURL: newImageURL)
        menuList[itemName]!.setRate(newRate: newRate)
        return true
    }
    
    func getMenuItem(_ itemKey: String) -> MenuItem? {
        return menuList[itemKey]
    }
    
    func getMenuList() -> [String: MenuItem] {
        return menuList
    }
    
}
