//
//  Constants.swift
//  ConnectPle
//
//  Created by Nolan Chen on 3/20/24.
//

import Foundation

let INDEX_VERTICAL_LABEL_BEGIN_POSITION = CGPoint(x: 40, y: 40)
let INDEX_VERTICAL_LABEL_END_POSITION = CGPoint(x: 40, y: 200)
let DATA_PATH = "UserAccounts"


enum AuthError: Error {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case userNotFound
    case wrongPassword
    case unknownError(String)
}
