import UIKit
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        clearToken()
        clearCookies()
        clearProfileData()
        clearImagesData()
        goToSplachScreen()
    }
    
    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearProfileData() {
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearImage()
    }
    
    private func clearImagesData() {
        ImagesListService.shared.clearImages()
    }
    
    private func goToSplachScreen() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
        }
    }
}

