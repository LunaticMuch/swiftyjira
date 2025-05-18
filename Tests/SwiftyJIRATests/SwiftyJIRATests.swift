import XCTest
@testable import SwiftyJIRA
import SwiftyJSON

// Mock URLProtocol for intercepting network requests
class MockURLProtocol: URLProtocol {
    static var mockResponses = [URL: (data: Data, response: HTTPURLResponse, error: Error?)]()
    
    static func mockHTTPResponse(for url: URL, responseData: Data, statusCode: Int = 200) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        mockResponses[url] = (responseData, response, nil)
    }
    
    static func mockHTTPError(for url: URL, error: Error) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        mockResponses[url] = (Data(), response, error)
    }
    
    static func reset() {
        mockResponses.removeAll()
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return mockResponses.keys.contains { $0.absoluteString == url.absoluteString }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url,
              let (data, response, error) = MockURLProtocol.mockResponses.first(where: { $0.key.absoluteString == url.absoluteString })?.value else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
            return
        }
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}

class SwiftyJIRATests: XCTestCase {
    var jira: SwiftyJIRA!
    
    override func setUp() {
        super.setUp()
        // Register our mock protocol
        URLProtocol.registerClass(MockURLProtocol.self)
        
        try? jira = SwiftyJIRA(baseURL: "https://jira.example.com", authToken: "mock-token")
    }
    
    override func tearDown() {
        MockURLProtocol.reset()
        URLProtocol.unregisterClass(MockURLProtocol.self)
        jira = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(jira)
        
        // Test initialization with invalid URL
        XCTAssertThrowsError(try SwiftyJIRA(baseURL: "", authToken: "token")) { error in
            XCTAssertEqual(error as? SwiftyJIRA.JIRAError, .invalidURL)
        }
    }
    
    func testMakeRequest() async {
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
            let result = try await jira.makeRequest(path: path)
            XCTAssertEqual(result["baseUrl"].string, "https://jira.example.com")
            XCTAssertEqual(result["version"].string, "8.5.0")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testMakeRequestWithError() async {
        let path = "rest/api/2/error"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        // Mock an error response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: Data(), statusCode: 404)
        
        do {
            _ = try await jira.makeRequest(path: path)
            XCTFail("Request should fail with error")
        } catch let error as SwiftyJIRA.JIRAError {
            switch error {
            case .serverError(let statusCode):
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
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
            XCTAssertEqual(serverInfo.buildDate, "2022-01-01T00:00:00.000Z")
            XCTAssertEqual(serverInfo.serverTime, "2022-01-02T00:00:00.000Z")
            XCTAssertEqual(serverInfo.scmInfo, "git@github.com:example/jira.git")
            XCTAssertEqual(serverInfo.serverTitle, "Example JIRA")
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