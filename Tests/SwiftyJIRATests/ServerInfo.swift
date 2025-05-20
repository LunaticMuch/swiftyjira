import XCTest
@testable import SwiftyJIRA
import SwiftyJSON

class SwiftyJIRAServerInfoTests: SwiftyJIRABaseTests {
    func testGetServerInfo() async {
        let path = "rest/api/2/serverInfo"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        let jsonData = """
        {
            "baseUrl": "https://jira.example.com",
            "version": "8.5.0",
            "buildNumber": 12345,
            "buildDate": "2022-01-01T00:00:00.000Z",
            "serverTime": "2022-01-02T00:00:00.000Z",
            "scmInfo": "git@github.com:example/jira.git",
            "serverTitle": "Example JIRA"
        }
        """.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let serverInfo = try await jira.getServerInfo()
            XCTAssertEqual(serverInfo.baseUrl, "https://jira.example.com")
            XCTAssertEqual(serverInfo.version, "8.5.0")
            XCTAssertEqual(serverInfo.buildNumber, 12345)
            XCTAssertEqual(serverInfo.buildDate, "2022-01-01T00:00:00.000Z")
            XCTAssertEqual(serverInfo.serverTime, "2022-01-02T00:00:00.000Z")
            XCTAssertEqual(serverInfo.scmInfo, "git@github.com:example/jira.git")
            XCTAssertEqual(serverInfo.serverTitle, "Example JIRA")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetServerInfoWithInvalidResponse() async {
        let path = "rest/api/2/serverInfo"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        let jsonData = """
        {
            "invalidData": true
        }
        """.data(using: .utf8)!
        
        // Mock the response with invalid data
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            _ = try await jira.getServerInfo()
            XCTFail("Request should fail with decoding error")
        } catch {
            XCTAssertTrue(error is SwiftyJIRA.JIRAError)
        }
    }
    
    func testServerInfoInitFromJSON() {
        let jsonString = """
        {
            "baseUrl": "https://jira.example.com",
            "version": "8.5.0",
            "buildNumber": 12345,
            "buildDate": "2022-01-01T00:00:00.000Z",
            "serverTime": "2022-01-02T00:00:00.000Z",
            "scmInfo": "git@github.com:example/jira.git",
            "serverTitle": "Example JIRA"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let json = try! JSON(data: jsonData)
        
        do {
            let serverInfo = try ServerInfo(json: json)
            XCTAssertEqual(serverInfo.baseUrl, "https://jira.example.com")
            XCTAssertEqual(serverInfo.version, "8.5.0")
            XCTAssertEqual(serverInfo.buildNumber, 12345)
        } catch {
            XCTFail("Failed to create ServerInfo from JSON: \(error)")
        }
    }
    
    func testServerInfoInitFromInvalidJSON() {
        let invalidJSON = JSON(["invalid": "data"])
        
        XCTAssertThrowsError(try ServerInfo(json: invalidJSON)) { error in
            XCTAssertTrue(error is SwiftyJIRA.JIRAError)
        }
    }
}