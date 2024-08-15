import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private init() { }
    
    private let urlSession = URLSession.shared
    private var lastLoadedPage: Int?
    private var isFetchingPhotos = false
    private (set) var photos: [Photo] = []
    
    private let perPage = 10

    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isFetchingPhotos else { return }
        isFetchingPhotos = true

        let nextPage = (lastLoadedPage ?? 0) + 1
        var urlComponents = URLComponents(string: "\(Constants.defaultBaseURL)photos")
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = urlComponents?.url else {
            completion(.failure(NetworkError.invalidRequest))
            isFetchingPhotos = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["newPhotos": newPhotos])
                    completion(.success(newPhotos))
                case .failure(let error):
                    completion(.failure(error))
                }
                self.isFetchingPhotos = false
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let method = isLike ? "POST" : "DELETE"
        guard let url = URL(string: "\(Constants.defaultBaseURL)photos/\(photoId)/like") else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = isLike
                    self.photos[index] = photo
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["photo": photo])
                }
                
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func clearImages() {
            photos.removeAll()
        }
}
