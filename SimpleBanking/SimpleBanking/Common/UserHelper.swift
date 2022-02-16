//
//  UserHelper.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 10/02/22.
//

import Foundation

final class UserHelper: NSObject {
    static private let userLoginToken: String  = "user.loginToken"
    static private let userLoginState: String = "user.loginState"
    static private let userName: String = "user.name"
    static private let userAccountNo: String = "user.accountNo"
    
    static var userLoginTokenData: String {
        get {
            return UserDefaults.standard.string(forKey: userLoginToken) ?? ""
        }
    }
    
    static var userNameData: String {
        get {
            return UserDefaults.standard.string(forKey: userName) ?? ""
        }
    }
    
    static var userAccountNoData: String {
        get {
            return UserDefaults.standard.string(forKey: userAccountNo) ?? ""
        }
    }
    
    static func saveLoginState(tokenData: String, userNameData: String, userAccountNoData: String) {
        UserDefaults.standard.set(true, forKey: userLoginState)
        UserDefaults.standard.set(tokenData, forKey: userLoginToken)
        UserDefaults.standard.set(userNameData, forKey: userName)
        UserDefaults.standard.set(userAccountNoData, forKey: userAccountNo)
    }
    
    static func removeLoginState() {
        UserDefaults.standard.removeObject(forKey: userLoginState)
        UserDefaults.standard.removeObject(forKey: userLoginToken)
        UserDefaults.standard.removeObject(forKey: userName)
        UserDefaults.standard.removeObject(forKey: userAccountNo)
    }
    
    static func isUserLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: userLoginState)
    }
}
