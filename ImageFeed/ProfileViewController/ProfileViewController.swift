import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var animationLayers = Set<CALayer>()

    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var favoriteStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var userPhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "UserPhotoDefault")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Logout"), for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekat_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "Избранное"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypBlue
        label.text = "0"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var spacer: UIView = {
        let element = UIView()
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var noPhotoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NoPhoto")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        
        favoriteStackView.addArrangedSubview(favoriteLabel)
        favoriteStackView.addArrangedSubview(notificationLabel)
        favoriteStackView.addArrangedSubview(spacer)
        
        view.addSubview(noPhotoImage)
        
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
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            notificationLabel.widthAnchor.constraint(equalToConstant: 40),
            notificationLabel.heightAnchor.constraint(equalToConstant: 22),
            
            noPhotoImage.topAnchor.constraint(equalTo: favoriteStackView.bottomAnchor, constant: 110),
            noPhotoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPhotoImage.widthAnchor.constraint(equalToConstant: 100),
            noPhotoImage.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
