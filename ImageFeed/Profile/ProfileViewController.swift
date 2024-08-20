import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var animationLayers = Set<CALayer>()
    
    private lazy var mainStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .vertical
        element.spacing = 24
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var headerStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .horizontal
        element.alignment = .center
        element.distribution = .equalSpacing
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var infoStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .vertical
        element.spacing = 8
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var favoriteStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .horizontal
        element.spacing = 8
        element.alignment = .center
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var userPhoto: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "UserPhotoDefault")
        element.contentMode = .scaleAspectFill
        element.layer.cornerRadius = 35
        element.clipsToBounds = true
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var logoutButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(UIImage(named: "Logout"), for: .normal)
        element.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        element.accessibilityIdentifier = "Logout Button"
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var nameLabel: UILabel = {
        let element = UILabel()
        element.text = "Александр Крапивин"
        element.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        element.textColor = .white
        element.textAlignment = .left
        element.numberOfLines = 1
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var loginLabel: UILabel = {
        let element = UILabel()
        element.text = "@smoozmy"
        element.font = UIFont.systemFont(ofSize: 13)
        element.textColor = .gray
        element.textAlignment = .left
        element.numberOfLines = 1
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let element = UILabel()
        element.text = "Hello, World!"
        element.font = UIFont.systemFont(ofSize: 13)
        element.textColor = .white
        element.textAlignment = .left
        element.numberOfLines = 0
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var spacer: UIView = {
        let element = UIView()
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setView()
        setupConstraints()
        startLoadingAnimation()
        updateProfileDetails()
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard let avatarURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURL) else { return }
        
        userPhoto.kf.setImage(with: url, placeholder: UIImage(named: "UserPhotoDefault")) { [weak self] _ in
            self?.stopLoadingAnimation()
        }
    }
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        discriptionLabel.text = profile.bio
        stopLoadingAnimation()
    }
    
    private func startLoadingAnimation() {
        addGradientLayer(to: userPhoto, cornerRadius: 35)
        addGradientLayer(to: nameLabel)
        addGradientLayer(to: loginLabel)
        addGradientLayer(to: discriptionLabel)
    }
    
    private func stopLoadingAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    private func addGradientLayer(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0, 0.1, 0.3]
        gradientAnimation.toValue = [0, 0.8, 1]
        gradientAnimation.duration = 1.0
        gradientAnimation.repeatCount = .infinity
        
        gradient.add(gradientAnimation, forKey: "locationsChange")
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    private func setView() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(headerStackView)
        mainStackView.addArrangedSubview(infoStackView)
        mainStackView.addArrangedSubview(favoriteStackView)
        
        favoriteStackView.addArrangedSubview(spacer)
        
        headerStackView.addArrangedSubview(userPhoto)
        headerStackView.addArrangedSubview(logoutButton)
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(loginLabel)
        infoStackView.addArrangedSubview(discriptionLabel)
    }
    
    @objc private func didTapLogoutButton() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }
        confirmAction.accessibilityIdentifier = "Yes"
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            headerStackView.heightAnchor.constraint(equalToConstant: 70),
            
            userPhoto.widthAnchor.constraint(equalToConstant: 70),
            userPhoto.heightAnchor.constraint(equalToConstant: 70),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
