//
//  Constants.swift
//  ConnectPle
//
//  Created by Nolan Chen on 3/20/24.
//

import Foundation
import UIKit

let INDEX_VERTICAL_LABEL_BEGIN_POSITION = CGPoint(x: 40, y: 40)
let INDEX_VERTICAL_LABEL_END_POSITION = CGPoint(x: 40, y: 200)
let DATA_PATH = "UserAccounts"
let INDEX_DELAY_SECONDS = 2.5
let THEME_COLOR = UIColor(red: 1.0, green: 0.624, blue: 0.624, alpha: 0.70) // Custom color using RGB
let DEFAULT_MENUITEM = "PLACE_HOLDER"
let USER_AUTH_TIMEOUT = 2.5 //in second

enum AuthError: Error {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case userNotFound
    case wrongPassword
    case unknownError(String)
}
