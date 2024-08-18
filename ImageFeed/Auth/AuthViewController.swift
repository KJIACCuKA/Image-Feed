import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private lazy var logoUnsplash: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "LogoUnsplash")
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var loginButton: UIButton = {
        let element = UIButton(type: .system)
        element.backgroundColor = .ypWhite
        element.setTitle("Войти", for: .normal)
        element.setTitleColor(.ypBlack, for: .normal)
        element.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        element.layer.cornerRadius = 16
        element.layer.masksToBounds = true
        element.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setView()
        setupConstraints()
        configureBackButton()
    }
    
    private func setView() {
        view.addSubview(logoUnsplash)
        view.addSubview(loginButton)
    }
    
    @objc private func didTapLoginButton() {
        let webViewController = WebViewViewController()
        webViewController.delegate = self
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoUnsplash.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoUnsplash.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoUnsplash.widthAnchor.constraint(equalToConstant: 60),
            logoUnsplash.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
}
