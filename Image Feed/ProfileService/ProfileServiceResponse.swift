import Foundation

struct ProfileServiceResponseBody: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?

    enum CodingKeys: String, CodingKey {

        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case profileImage = "profile_image"
    }

    struct Social: Codable {
        let instagramUsername: String?
        let portfolioURL: String?
        let twitterUsername: String?

        enum CodingKeys: String, CodingKey {
            case instagramUsername = "instagram_username"
            case portfolioURL = "portfolio_url"
            case twitterUsername = "twitter_username"
        }
    }

    struct ProfileImage: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }

    struct Badge: Codable {
        let title: String
        let primary: Bool
        let slug: String
        let link: String
    }

    struct Links: Codable {
        let selfLink: String
        let html: String
        let photos: String
        let likes: String
        let portfolio: String

        enum CodingKeys: String, CodingKey {
            case selfLink = "self"
            case html
            case photos
            case likes
            case portfolio
        }
    }
}
