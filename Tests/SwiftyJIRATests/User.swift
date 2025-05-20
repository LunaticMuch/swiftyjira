import XCTest
@testable import SwiftyJIRA
import SwiftyJSON

class SwiftyJIRAUserTests: SwiftyJIRABaseTests {
    
    let userJSON = """
    {
        "accountId": "123456789",
        "displayName": "Test User",
        "emailAddress": "test@example.com",
        "active": true,
        "timeZone": "GMT",
        "avatarUrls": {
            "16x16": "https://example.com/avatar/small.png",
            "24x24": "https://example.com/avatar/medium.png",
            "32x32": "https://example.com/avatar/medium.png",
            "48x48": "https://example.com/avatar/large.png"
        }
    }
    """
    
    func testGetUserByAccountId() async {
        let accountId = "123456789"
        let path = "rest/api/2/user"
        let queryItems = [URLQueryItem(name: "accountId", value: accountId)]
        
        guard var components = URLComponents(string: "https://jira.example.com/\(path)") else {
            XCTFail("Failed to create URL components")
            return
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            XCTFail("Failed to create URL")
            return
        }
        
        let jsonData = userJSON.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getUser(accountId: accountId)
            XCTAssertEqual(response.parsed.accountId, "123456789")
            XCTAssertEqual(response.parsed.displayName, "Test User")
            XCTAssertEqual(response.parsed.emailAddress, "test@example.com")
            XCTAssertEqual(response.parsed.active, true)
            XCTAssertEqual(response.raw["accountId"].string, "123456789")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetUserByUsername() async {
        let username = "testuser"
        let path = "rest/api/2/user"
        let queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard var components = URLComponents(string: "https://jira.example.com/\(path)") else {
            XCTFail("Failed to create URL components")
            return
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            XCTFail("Failed to create URL")
            return
        }
        
        let jsonData = userJSON.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getUserByUsername(username: username)
            XCTAssertEqual(response.parsed.accountId, "123456789")
            XCTAssertEqual(response.parsed.displayName, "Test User")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetUserByEmail() async {
        let email = "test@example.com"
        let path = "rest/api/2/user"
        let queryItems = [URLQueryItem(name: "emailAddress", value: email)]
        
        guard var components = URLComponents(string: "https://jira.example.com/\(path)") else {
            XCTFail("Failed to create URL components")
            return
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            XCTFail("Failed to create URL")
            return
        }
        
        let jsonData = userJSON.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getUserByEmail(email: email)
            XCTAssertEqual(response.parsed.accountId, "123456789")
            XCTAssertEqual(response.parsed.emailAddress, "test@example.com")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetCurrentUser() async {
        let path = "rest/api/2/myself"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        let jsonData = userJSON.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getCurrentUser()
            XCTAssertEqual(response.parsed.accountId, "123456789")
            XCTAssertEqual(response.parsed.displayName, "Test User")
            XCTAssertEqual(response.raw["displayName"].string, "Test User")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testUserInitFromInvalidJSON() {
        let invalidJSON = JSON(["invalid": "data"])
        
        XCTAssertThrowsError(try JIRAUser(json: invalidJSON)) { error in
            XCTAssertTrue(error is SwiftyJIRA.JIRAError)
        }
    }
}