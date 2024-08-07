import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
    
    init(result photo: PhotoResult) {
        self.id = photo.id
        self.size = CGSize(width: photo.width, height: photo.height)
        self.createdAt = photo.createdAt
        self.welcomeDescription = photo.description ?? ""
        self.thumbImageURL = photo.urls?.thumb ?? ""
        self.largeImageURL = photo.urls?.full ?? ""
        self.fullImageURL = photo.urls?.full ?? ""
        self.isLiked = photo.isLiked ?? false
    }
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let height: Int
    let width: Int
    let description: String?
    let isLiked: Bool?
    let urls: URLResult?
}

struct URLResult: Codable {
    let full: String
    let thumb: String
}

final class ImageListService {
    
    init() {}
    static let shared = ImageListService()

    private (set) var photos: [Photo] = []
    
    private var task: URLSessionTask?
    private let session = URLSession.shared
    private var pageNumber: Int = 1
    private var lastLoadedPage: Int?
    private let perPage: Int = 10
    private let tokenStorage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    func makePhotosNextPageRequest(page: Int, perPage: Int) throws -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL else {
            throw ImageListErrors.invalidBaseURL
        }
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw ImageListErrors.invalidURL
        }
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        
        guard let url = components.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(tokenStorage)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = try? makePhotosNextPageRequest(page: nextPage, perPage: perPage) else {
            return
        }
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                let newPhoto = photoResult.map { Photo(result: $0) }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhoto)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                }
            case .failure(let error):
                print("[ImagesListService]: AuthServiceError - \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
