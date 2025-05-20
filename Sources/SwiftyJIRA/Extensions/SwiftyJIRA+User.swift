import Foundation
import SwiftyJSON

// MARK: - Get User
// https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-users/#api-rest-api-2-user-get

extension SwiftyJIRA {
    /// Gets information about a user by their account ID
    /// - Parameter accountId: The user's account ID
    /// - Returns: A response containing both raw JSON and parsed JIRAUser
    public func getUser(accountId: String) async throws -> JIRAResponse<JIRAUser> {
        let queryItems = [URLQueryItem(name: "accountId", value: accountId)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        let user = try JIRAUser(json: json)
        return JIRAResponse(raw: json, parsed: user)
    }

    /// Gets information about a user by their username
    /// - Parameter username: The user's username
    /// - Returns: A response containing both raw JSON and parsed JIRAUser
    public func getUserByUsername(username: String) async throws -> JIRAResponse<JIRAUser> {
        let queryItems = [URLQueryItem(name: "username", value: username)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        let user = try JIRAUser(json: json)
        return JIRAResponse(raw: json, parsed: user)
    }

    /// Gets information about a user by their email address
    /// - Parameter email: The user's email address
    /// - Returns: A response containing both raw JSON and parsed JIRAUser
    public func getUserByEmail(email: String) async throws -> JIRAResponse<JIRAUser> {
        let queryItems = [URLQueryItem(name: "emailAddress", value: email)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        let user = try JIRAUser(json: json)
        return JIRAResponse(raw: json, parsed: user)
    }

    /// Gets the current user's information
    /// - Returns: A response containing both raw JSON and parsed JIRAUser
    public func getCurrentUser() async throws -> JIRAResponse<JIRAUser> {
        // This endpoint doesn't need query parameters
        let json = try await makeRequest(path: "rest/api/2/myself")
        let user = try JIRAUser(json: json)
        return JIRAResponse(raw: json, parsed: user)
    }
}
