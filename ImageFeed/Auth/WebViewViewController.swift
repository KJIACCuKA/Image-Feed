import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    private struct WebConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let code = "code"
        static let authorizedPath = "/oauth/authorize/native"
    }
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private lazy var webView: WKWebView = {
        let element = WKWebView()
        element.navigationDelegate = self
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var progressView: UIProgressView = {
        let element = UIProgressView()
        element.progressTintColor = .ypBlack
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setView()
        setupConstraints()
        loadAuthView()
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in
            self?.updateProgress()
        }
    }
    
    private func setView() {
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebConstants.unsplashAuthorizeURLString) else {
            print("Failed to create URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to create URL from URLComponents")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == WebConstants.authorizedPath,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == WebConstants.code }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
