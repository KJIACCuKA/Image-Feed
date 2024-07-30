import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let logoImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "AuthLogo")
        return img
    }()
    
    private let loginButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor(named: "blackYP"), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackButton()
        setupViews()
        setupConstraints()
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

     }

    private func setUpBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward 1")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Backward 1")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "blackYP")
    }
    
    @objc private func didTapLoginButton() {
        let viewController = WebViewViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }

    func setupViews() {
        view.backgroundColor = UIColor(named: "blackYP")
        [logoImageView,
        loginButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

extension AuthViewController: WebViewControllerDelegate {
    
    func webViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
