import UIKit

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    public let urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = authTokenRequest(code: code) else { return }
        
        object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension OAuth2Service {
    
    private func authTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com") else { return nil }
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: url)
    }
    
    private func object(for request: URLRequest,
                        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        let decoder = JSONDecoder()
        return request.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            completion(response)
            return
        }
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}


enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
}

extension URLRequest {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200...299:
                    print("DEBUG:", "Received success HTTP status code: \(statusCode)")
                    fulfillCompletion(.success(data))
                case 400:
                    print("ERROR:", "Bad request \(statusCode)")
                    fulfillCompletion(.failure(NetworkError.badRequest))
                case 401:
                    print("ERROR:", "Unauthorized \(statusCode) - Invalid Access Token")
                    fulfillCompletion(.failure(NetworkError.unauthorized))
                case 403:
                    print("ERROR:", "Forbidden \(statusCode)")
                    fulfillCompletion(.failure(NetworkError.forbidden))
                case 404:
                    print("ERROR:", "Not Found \(statusCode)")
                    fulfillCompletion(.failure(NetworkError.notFound))
                    
                case 500, 503:
                    print("ERROR:", "Internal Server Error \(statusCode)")
                    fulfillCompletion(.failure(NetworkError.serverError))
                default:
                    print("ERROR:", "HTTP status code: \(statusCode)")
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("ERROR:", error.localizedDescription)
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("ERROR: Unknown error")
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
    }
}
