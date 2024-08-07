import Foundation

struct ProfileImage: Codable {
    let small: String
    let large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}
