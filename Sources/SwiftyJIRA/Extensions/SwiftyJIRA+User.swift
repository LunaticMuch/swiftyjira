import Foundation
import SwiftyJSON

// MARK: - Get User
// https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-users/#api-rest-api-2-user-get

extension SwiftyJIRA {
    /// Gets information about a user by their account ID
    /// - Parameter accountId: The user's account ID
    /// - Returns: A JIRAUser object containing the user's information
    public func getUser(accountId: String) async throws -> JIRAUser {
        let queryItems = [URLQueryItem(name: "accountId", value: accountId)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        return try JIRAUser(json: json)
    }
    
    /// Gets information about a user by their username
    /// - Parameter username: The user's username
    /// - Returns: A JIRAUser object containing the user's information
    public func getUserByUsername(username: String) async throws -> JIRAUser {
        let queryItems = [URLQueryItem(name: "username", value: username)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        return try JIRAUser(json: json)
    }
    
    /// Gets information about a user by their email address
    /// - Parameter email: The user's email address
    /// - Returns: A JIRAUser object containing the user's information
    public func getUserByEmail(email: String) async throws -> JIRAUser {
        let queryItems = [URLQueryItem(name: "emailAddress", value: email)]
        let json = try await makeRequest(path: "rest/api/2/user", queryItems: queryItems)
        return try JIRAUser(json: json)
    }
    
    /// Gets the current user's information
    /// - Returns: A JIRAUser object containing the current user's information
    public func getCurrentUser() async throws -> JIRAUser {
        // This endpoint doesn't need query parameters
        let json = try await makeRequest(path: "rest/api/2/myself")
        return try JIRAUser(json: json)
    }
}