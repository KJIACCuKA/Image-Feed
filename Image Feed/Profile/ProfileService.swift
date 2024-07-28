import UIKit

final class ProfileService {
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
    }
}

struct ProfileResult: Codable {
    var first_name: String
    var last_name: String
}


struct Profile {
    var username: String
    var name = "\(first_name) \(last_name)"
}
