import Foundation
import SwiftyJSON

public struct JIRAUser: Codable {
    public let accountId: String
    public let displayName: String
    public let emailAddress: String?
    public let active: Bool
    public let timeZone: String?
    public let avatarUrls: AvatarUrls
    
    public struct AvatarUrls: Codable {
        public let small: String
        public let medium: String
        public let large: String
        
        public init(json: JSON) throws {
            guard let small = json["16x16"].string,
                  let medium = json["32x32"].string,
                  let large = json["48x48"].string
            else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 1002,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode AvatarUrls"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }
            self.small = small
            self.medium = medium
            self.large = large
        }
    }
    
    public init(json: JSON) throws {
        guard let accountId = json["accountId"].string,
              let displayName = json["displayName"].string,
              let active = json["active"].bool
        else {
            let error = NSError(
                domain: "SwiftyJIRA",
                code: 1003,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode JIRAUser"]
            )
            throw SwiftyJIRA.JIRAError.decodingError(error)
        }
        
        self.accountId = accountId
        self.displayName = displayName
        self.emailAddress = json["emailAddress"].string
        self.active = active
        self.timeZone = json["timeZone"].string
        
        guard let avatarUrlsJson = json["avatarUrls"].dictionary else {
            let error = NSError(
                domain: "SwiftyJIRA",
                code: 1004,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode avatarUrls"]
            )
            throw SwiftyJIRA.JIRAError.decodingError(error)
        }
        
        let avatarUrlsJsonObj = JSON(avatarUrlsJson)
        self.avatarUrls = try AvatarUrls(json: avatarUrlsJsonObj)
    }
}