import UIKit

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200...299:
                    print("DEBUG:", "Received success HTTP status code: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.success(data))
                case 400:
                    print("ERROR:", "Bad request \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.badRequest))
                case 401:
                    print("ERROR:", "Unauthorized \(statusCode) - Invalid Access Token")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.unauthorized))
                case 403:
                    print("ERROR:", "Forbidden \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.forbidden))
                case 404:
                    print("ERROR:", "Not Found \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.notFound))
                    
                case 500, 503:
                    print("ERROR:", "Internal Server Error \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.serverError))
                default:
                    print("ERROR:", "HTTP status code: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("ERROR:", error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("ERROR: Unknown error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

