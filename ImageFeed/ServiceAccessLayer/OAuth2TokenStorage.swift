import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "AuthToken"
    
    private init() { }
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("Ошибка: не удалось сохранить токен в Keychain.")
                }
            } else {
                let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !removeSuccessful {
                    print("Ошибка: не удалось удалить токен из Keychain.")
                }
            }
        }
    }
}
