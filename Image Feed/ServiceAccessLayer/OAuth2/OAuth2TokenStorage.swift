import UIKit

final class OAuth2TokenStorage {
    
    let tokenK = "token"
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: tokenK)
        }
        get {
            UserDefaults.standard.string(forKey: tokenK)
        }
    }
}
