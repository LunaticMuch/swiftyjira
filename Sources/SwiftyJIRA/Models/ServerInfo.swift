import Foundation
import SwiftyJSON

public struct ServerInfo: Codable {
    public let baseUrl: String
    public let version: String
    public let buildNumber: Int
    public let buildDate: String
    public let serverTime: String
    public let scmInfo: String
    public let serverTitle: String
    public init(json: JSON) throws {
        guard let baseUrl = json["baseUrl"].string,
              let version = json["version"].string,
              let buildNumber = json["buildNumber"].int,
              let buildDate = json["buildDate"].string,
              let serverTime = json["serverTime"].string,
              let scmInfo = json["scmInfo"].string,
              let serverTitle = json["serverTitle"].string
        else {
            let error = NSError(
                domain: "SwiftyJIRA",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode ServerInfo"]
            )
            throw SwiftyJIRA.JIRAError.decodingError(error)
        }
        self.baseUrl = baseUrl
        self.version = version
        self.buildNumber = buildNumber
        self.buildDate = buildDate
        self.serverTime = serverTime
        self.scmInfo = scmInfo
        self.serverTitle = serverTitle
    }
}

// For Codable conformance
extension ServerInfo {
    enum CodingKeys: String, CodingKey {
        case baseUrl, version, buildNumber, buildDate, serverTime, scmInfo, serverTitle
    }
}
