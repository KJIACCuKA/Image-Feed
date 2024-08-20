import UIKit

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String
    let defaultBaseURL: URL

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "4fOOKt0scYT_ke4SWfEQPvSGRCFx9k7Vu1oRKfG3zxo",
            secretKey: "Lk4UqcoKT3VS8WN84twE1yfWFR5IbbQctQ1t0d65nlA",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(staticString: "https://api.unsplash.com/")
        )
    }
}
