import Foundation
import SwiftyJSON

// MARK: - Get Issue
// https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-issues/#api-rest-api-2-issue-issueidorkey-get

extension SwiftyJIRA {
    /// Gets information about a specific issue
    /// - Parameters:
    ///   - issueIdOrKey: The ID or key of the issue
    ///   - fields: A list of fields to return for the issue. Default is all fields.
    ///   - expand: A list of the parameters to expand.
    /// - Returns: A response containing both raw JSON and parsed JIRAIssue
    public func getIssue(
        issueIdOrKey: String,
        fields: [String]? = nil,
        expand: [String]? = nil
    ) async throws -> JIRAResponse<JIRAIssue> {
        var queryItems: [URLQueryItem] = []
        
        if let fields = fields {
            queryItems.append(URLQueryItem(name: "fields", value: fields.joined(separator: ",")))
        }
        
        if let expand = expand {
            queryItems.append(URLQueryItem(name: "expand", value: expand.joined(separator: ",")))
        }
        
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let json = try await makeRequest(path: path, queryItems: queryItems.isEmpty ? nil : queryItems)
        let issue = try JIRAIssue(json: json)
        return JIRAResponse(raw: json, parsed: issue)
    }
    
    /// Gets a specific issue with changelog information
    /// - Parameter issueIdOrKey: The ID or key of the issue
    /// - Returns: A response containing both raw JSON and parsed JIRAIssue with changelog
    public func getIssueWithChangelog(issueIdOrKey: String) async throws -> JIRAResponse<JIRAIssue> {
        return try await getIssue(issueIdOrKey: issueIdOrKey, expand: ["changelog"])
    }
    
    /// Gets specific fields for an issue, handling the case where requested fields may not exist
    /// - Parameters:
    ///   - issueIdOrKey: The ID or key of the issue
    ///   - fieldKeys: Array of field keys to retrieve
    /// - Returns: A response containing the requested fields
    public func getIssueFields(
        issueIdOrKey: String,
        fieldKeys: [String]
    ) async throws -> JIRAResponse<JIRAIssue> {
        // Always request id and key along with the requested fields
        var allFields = fieldKeys
        if !allFields.contains("id") {
            allFields.append("id")
        }
        if !allFields.contains("key") {
            allFields.append("key")
        }
        
        return try await getIssue(issueIdOrKey: issueIdOrKey, fields: allFields)
    }
}