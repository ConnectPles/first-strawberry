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
    
    init(firstName: String, lastName: String, menuList: [String: MenuItem] = ["PLACE_HOLDER":MenuItem(rate: -1, imageURL: "", description: "")]) {
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
    
    
    func getMenuItem(_ itemKey: String) -> MenuItem? {
        return menuList[itemKey]
    }
    
    func getMenuList() -> [String: MenuItem] {
        return menuList
    }
    
    func isMenuItemExist(itemName: String) -> Bool {
        return self.menuList[itemName] != nil
    }
    
    func addMenuItem(itemName: String, rate: Int, imageURL: String?, description: String?) -> Bool {
        if isMenuItemExist(itemName: itemName) {
            print("ERROR: Item \(itemName) existed.")
            return false
        }
        // check if DEFAULT ITEM exists, and remove if it does
        if isMenuItemExist(itemName: DEFAULT_MENUITEM) {
            _ = self.removeMenuItem(ByItemName: DEFAULT_MENUITEM)
        }
        menuList[itemName] = MenuItem(rate: rate, imageURL: imageURL ?? "DEFAULT", description: description ?? "")
        return true
    }
    
    func removeMenuItem(ByItemName itemName: String) -> Bool {
        if isMenuItemExist(itemName: itemName) == false {
            print("ERROR: Item \(itemName) not exist.")
            return false
        }
        menuList.removeValue(forKey: itemName)
        return true
    }
    
    func removeMenuItem(ByIndex index: Int) -> Bool {
        let names = Array(menuList.keys)
        if index < 0 || index >= names.count {
            return false
        } else {
            menuList.removeValue(forKey: names[index])
            return true
        }
        
    }
    
    func updateMenuItem(itemName: String, newRate: Int?, newImageURL: String?, newDescrption: String?) -> Bool {
        if isMenuItemExist(itemName: itemName) == false {
            print("ERROR: Item \(itemName) not exist!")
            return false
        }
        menuList[itemName]!.setNewImageURL(newImageURL: newImageURL)
        menuList[itemName]!.setRate(newRate: newRate)
        menuList[itemName]!.setDescription(newDescription: newDescrption)
        return true
    }
    
}
