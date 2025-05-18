import Foundation
import SwiftyJSON

public class SwiftyJIRA {
    private let baseURL: URL
    private let authToken: String
    public init(baseURL: String, authToken: String) throws {
        guard let url: URL = URL(string: baseURL) else {
            throw JIRAError.invalidURL
        }
        self.baseURL = url
        self.authToken = authToken
    }

    public func makeRequest(path: String) async throws -> JSON {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw JIRAError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw JIRAError.serverError(statusCode: httpResponse.statusCode)
        }

        // Parse with SwiftyJSON
        let json = try JSON(data: data)
        return json
    }

    public enum JIRAError: Error, Equatable {
        case invalidURL
        case invalidResponse
        case serverError(statusCode: Int)
        case decodingError(Error)
        
        public static func == (lhs: JIRAError, rhs: JIRAError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidURL, .invalidURL):
                return true
            case (.invalidResponse, .invalidResponse):
                return true
            case let (.serverError(lhsCode), .serverError(rhsCode)):
                return lhsCode == rhsCode
            case let (.decodingError(lhsError), .decodingError(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }

    // ServerInfo endpoint implementation
    public func getServerInfo() async throws -> ServerInfo {
        let json: JSON = try await makeRequest(path: "rest/api/2/serverInfo")
        return try ServerInfo(json: json)
    }
}
