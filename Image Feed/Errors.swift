import UIKit

enum AuthServiceErrors: Error {
    case invalidRequest
    case invalidResponse
    case invalidUrl
}

enum ProfileServiceErrors: Error {
    case invalidBaseURL
    case invalidURL
    case tokenError
    case invalidRequest
    case fetchProfileError
}
enum ProfileImageServiceErrors: Error {
    case invalidBaseURL
    case invalidURL
    case tokenError
    case invalidRequest
    case fetchProfileError
}
