import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case invalidRequest
}
