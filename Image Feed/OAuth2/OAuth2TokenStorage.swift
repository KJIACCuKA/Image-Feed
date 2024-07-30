import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    let tokenK = "token"
    var token: String? {
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenK)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenK)
            guard isSuccess else {
                fatalError("Невозможно сохранить token")
            }
        }
        get {
            KeychainWrapper.standard.string(forKey: tokenK)
        }
    }
    
    static func deleteToken() {
        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
    }
}
