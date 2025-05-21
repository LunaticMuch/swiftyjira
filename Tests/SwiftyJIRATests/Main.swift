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

// Base test class with common setup/teardown logic
class SwiftyJIRABaseTests: XCTestCase {
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
}

// Core functionality tests
class SwiftyJIRACoreTests: SwiftyJIRABaseTests {
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
            "buildNumber": 12345
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
}