//
//  User.swift
//  ConnectPle
//
//  Created by Nolan Chen on 4/7/24.
//

import Foundation
class UserModel: Codable {

    let firstName: String
    let lastName: String
    let menuList: [String: MenuItem]
    struct MenuItem: Codable {
        let rate: Int
        let image: String
    }
    
    init(firstName: String, lastName: String, menuList: [String: MenuItem]) {
        self.firstName = firstName
        self.lastName = lastName
        self.menuList = menuList
    }
}
