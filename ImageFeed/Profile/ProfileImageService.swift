import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() { }
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        if task != nil {
            task?.cancel()
        }
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.large
                completion(.success(userResult.profileImage.large))
            case .failure(let error):
                print("[ProfileImageService]: NetworkError - \(error.localizedDescription), username: \(username)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "\(AuthConfiguration.standard.defaultBaseURL)users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func clearImage() {
            avatarURL = nil
        }
}
