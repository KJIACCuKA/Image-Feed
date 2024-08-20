import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "MainNoActive"),
            selectedImage: UIImage(named: "MainActive")
        )
        imagesListViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "ProfileNoActive"),
            selectedImage: UIImage(named: "ProfileActive")
        )
        profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        self.viewControllers = [
            imagesListViewController,
            profileViewController
        ]
        configureTabBarAppearance()
    }
    
    private func configureTabBarAppearance() {
        let tabBar = self.tabBar
        tabBar.barTintColor = .ypBlack
        tabBar.unselectedItemTintColor = .ypWhiteAlpha50
        tabBar.tintColor = .ypWhite
        tabBar.isTranslucent = false
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .ypBlack
            
            
            appearance.shadowColor = .ypBlack
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            }
        }
    }
}
