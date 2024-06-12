//
//  User.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/7/24.
//

import Foundation
class UserModel: Codable {

    var firstName: String
    var lastName: String
    var menuList: [String: MenuItem]
    
    init(firstName: String, lastName: String, menuList: [String: MenuItem]) {
        self.firstName = firstName
        self.lastName = lastName
        self.menuList = menuList
    }
    func addMenuItem(itemName: String, itemInfo: MenuItem) {
        menuList[itemName] = itemInfo
    }
}
