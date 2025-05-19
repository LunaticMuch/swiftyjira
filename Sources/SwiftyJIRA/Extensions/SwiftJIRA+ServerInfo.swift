import Foundation
import SwiftyJSON

// MARK: - ServerInfo
// https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-server-info/#api-group-server-info

extension SwiftyJIRA {
    public func getServerInfo() async throws -> ServerInfo {
        let json: JSON = try await makeRequest(path: "rest/api/2/serverInfo")
        return try ServerInfo(json: json)
    }
}
