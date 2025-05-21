import XCTest
@testable import SwiftyJIRA
import SwiftyJSON

class SwiftyJIRAIssueTests: SwiftyJIRABaseTests {
    
    // Test JSON for issue with minimal fields (just id and key)
    let issueMinimalJSON = """
    {
        "id": "10000",
        "key": "PROJ-123"
    }
    """
    
    // Test JSON for issue with partial fields
    let issuePartialJSON = """
    {
        "id": "10000",
        "key": "PROJ-123",
        "fields": {
            "summary": "Test Issue"
        }
    }
    """
    
    // Test JSON for issue with all common fields
    let issueFullJSON = """
    {
        "id": "10000",
        "key": "PROJ-123",
        "fields": {
            "summary": "Test Issue",
            "description": "This is a test issue",
            "issuetype": {
                "id": "10001",
                "name": "Bug",
                "description": "A software defect",
                "iconUrl": "https://example.com/bug.png"
            },
            "project": {
                "id": "10100",
                "key": "PROJ",
                "name": "Test Project"
            },
            "status": {
                "id": "10002",
                "name": "In Progress",
                "statusCategory": {
                    "id": 4,
                    "key": "inprogress",
                    "name": "In Progress"
                }
            },
            "priority": {
                "id": "3",
                "name": "Medium",
                "iconUrl": "https://example.com/medium.png"
            },
            "creator": {
                "accountId": "creator123",
                "displayName": "Creator User",
                "emailAddress": "creator@example.com",
                "active": true,
                "avatarUrls": {
                    "16x16": "https://example.com/avatar/small.png",
                    "24x24": "https://example.com/avatar/medium.png",
                    "32x32": "https://example.com/avatar/medium.png",
                    "48x48": "https://example.com/avatar/large.png"
                }
            },
            "assignee": {
                "accountId": "assignee123",
                "displayName": "Assignee User",
                "emailAddress": "assignee@example.com",
                "active": true,
                "avatarUrls": {
                    "16x16": "https://example.com/avatar/small.png",
                    "24x24": "https://example.com/avatar/medium.png",
                    "32x32": "https://example.com/avatar/medium.png",
                    "48x48": "https://example.com/avatar/large.png"
                }
            },
            "created": "2022-01-01T12:00:00.000Z",
            "updated": "2022-01-02T12:00:00.000Z"
        }
    }
    """
    
    // Test JSON for issue with changelog
    let issueWithChangelogJSON = """
    {
        "id": "10000",
        "key": "PROJ-123",
        "fields": {
            "summary": "Test Issue"
        },
        "changelog": {
            "startAt": 0,
            "maxResults": 10,
            "total": 1,
            "histories": [
                {
                    "id": "10001",
                    "author": {
                        "accountId": "user123",
                        "displayName": "Change User",
                        "active": true,
                        "avatarUrls": {
                            "16x16": "https://example.com/avatar/small.png",
                            "48x48": "https://example.com/avatar/large.png"
                        }
                    },
                    "created": "2022-01-02T10:00:00.000Z",
                    "items": [
                        {
                            "field": "status",
                            "fieldtype": "jira",
                            "from": "10001",
                            "fromString": "To Do",
                            "to": "10002",
                            "toString": "In Progress"
                        }
                    ]
                }
            ]
        }
    }
    """
    
    // Test error JSON response
    let errorJSON = """
    {
        "errorMessages": ["Issue does not exist or you do not have permission to see it."],
        "errors": {}
    }
    """
    
    // MARK: - Test Basic Issue Fetching
    
    func testGetIssueWithFullFields() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        // Mock the response with full JSON
        MockURLProtocol.mockHTTPResponse(for: url, responseData: issueFullJSON.data(using: .utf8)!)
        
        do {
            let response = try await jira.getIssue(issueIdOrKey: issueIdOrKey)
            
            // Test raw JSON
            XCTAssertEqual(response.raw["id"].string, "10000")
            XCTAssertEqual(response.raw["key"].string, "PROJ-123")
            
            // Test parsed issue with all fields
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            XCTAssertEqual(response.parsed.fields.summary, "Test Issue")
            XCTAssertEqual(response.parsed.fields.description, "This is a test issue")
            XCTAssertEqual(response.parsed.fields.issuetype?.name, "Bug")
            XCTAssertEqual(response.parsed.fields.project?.key, "PROJ")
            XCTAssertEqual(response.parsed.fields.status?.name, "In Progress")
            XCTAssertEqual(response.parsed.fields.priority?.name, "Medium")
            XCTAssertEqual(response.parsed.fields.creator?.displayName, "Creator User")
            XCTAssertEqual(response.parsed.fields.assignee?.displayName, "Assignee User")
            XCTAssertEqual(response.parsed.fields.created, "2022-01-01T12:00:00.000Z")
            XCTAssertEqual(response.parsed.fields.updated, "2022-01-02T12:00:00.000Z")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetIssueWithMinimalFields() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        // Mock the response with minimal JSON
        MockURLProtocol.mockHTTPResponse(for: url, responseData: issueMinimalJSON.data(using: .utf8)!)
        
        do {
            let response = try await jira.getIssue(issueIdOrKey: issueIdOrKey)
            
            // Test parsed issue with minimal fields
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            
            // Check that other fields are nil or have default values
            XCTAssertNil(response.parsed.fields.summary)
            XCTAssertNil(response.parsed.fields.description)
            XCTAssertNil(response.parsed.fields.issuetype)
            XCTAssertNil(response.parsed.fields.project)
            XCTAssertNil(response.parsed.fields.status)
            XCTAssertNil(response.parsed.fields.priority)
            XCTAssertNil(response.parsed.fields.assignee)
            XCTAssertNil(response.parsed.fields.creator)
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetIssueWithPartialFields() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        // Mock the response with partial JSON
        MockURLProtocol.mockHTTPResponse(for: url, responseData: issuePartialJSON.data(using: .utf8)!)
        
        do {
            let response = try await jira.getIssue(issueIdOrKey: issueIdOrKey)
            
            // Test parsed issue with partial fields
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            XCTAssertEqual(response.parsed.fields.summary, "Test Issue")
            
            // Check that other fields are nil
            XCTAssertNil(response.parsed.fields.description)
            XCTAssertNil(response.parsed.fields.issuetype)
            XCTAssertNil(response.parsed.fields.project)
            XCTAssertNil(response.parsed.fields.status)
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    // MARK: - Test Specific Fields
    
    func testGetIssueWithSpecificFields() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let fields = ["summary", "status"]
        
        // Create the URL with the fields parameter
        var components = URLComponents(string: "https://jira.example.com/\(path)")!
        components.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
        let url = components.url!
        
        // Create a response with only the requested fields
        let jsonData = """
        {
            "id": "10000",
            "key": "PROJ-123",
            "fields": {
                "summary": "Test Issue",
                "status": {
                    "id": "10002",
                    "name": "In Progress",
                    "statusCategory": {
                        "id": 4,
                        "key": "inprogress",
                        "name": "In Progress"
                    }
                }
            }
        }
        """.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getIssue(issueIdOrKey: issueIdOrKey, fields: fields)
            
            // Verify the selected fields are parsed
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            XCTAssertEqual(response.parsed.fields.summary, "Test Issue")
            XCTAssertEqual(response.parsed.fields.status?.name, "In Progress")
            
            // Other fields should be nil
            XCTAssertNil(response.parsed.fields.description)
            XCTAssertNil(response.parsed.fields.assignee)
            XCTAssertNil(response.parsed.fields.project)
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    func testGetIssueWithNonexistentFields() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let fields = ["summary", "nonexistentField"]
        
        // Create the URL with the fields parameter
        var components = URLComponents(string: "https://jira.example.com/\(path)")!
        components.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
        let url = components.url!
        
        // Create a response with only the existing requested fields
        let jsonData = """
        {
            "id": "10000",
            "key": "PROJ-123",
            "fields": {
                "summary": "Test Issue"
            }
        }
        """.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getIssue(issueIdOrKey: issueIdOrKey, fields: fields)
            
            // Verify the issue still parses correctly
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            XCTAssertEqual(response.parsed.fields.summary, "Test Issue")
            
            // Verify we can access nonexistent field from raw data
            XCTAssertTrue(response.raw["fields"]["nonexistentField"].isEmpty)
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    // MARK: - Test Changelog
    
    func testGetIssueWithChangelog() async {
        let issueIdOrKey = "PROJ-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        
        // Create the URL with the expand parameter
        var components = URLComponents(string: "https://jira.example.com/\(path)")!
        components.queryItems = [URLQueryItem(name: "expand", value: "changelog")]
        let url = components.url!
        
        let jsonData = issueWithChangelogJSON.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            let response = try await jira.getIssueWithChangelog(issueIdOrKey: issueIdOrKey)
            
            // Test that issue data is correctly parsed
            XCTAssertEqual(response.parsed.id, "10000")
            XCTAssertEqual(response.parsed.key, "PROJ-123")
            
            // Test that changelog is included
            XCTAssertNotNil(response.parsed.changelog)
            XCTAssertEqual(response.parsed.changelog?.histories.count, 1)
            XCTAssertEqual(response.parsed.changelog?.histories[0].id, "10001")
            XCTAssertEqual(response.parsed.changelog?.histories[0].author?.displayName, "Change User")
            XCTAssertEqual(response.parsed.changelog?.histories[0].items.count, 1)
            XCTAssertEqual(response.parsed.changelog?.histories[0].items[0].field, "status")
            XCTAssertEqual(response.parsed.changelog?.histories[0].items[0].fromString, "To Do")
            XCTAssertEqual(response.parsed.changelog?.histories[0].items[0].toString, "In Progress")
        } catch {
            XCTFail("Request should not fail: \(error)")
        }
    }
    
    // MARK: - Test Error Handling
    
    func testInvalidIssueResponse() async {
        let issueIdOrKey = "INVALID-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        let jsonData = errorJSON.data(using: .utf8)!
        
        // Mock a 404 response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData, statusCode: 404)
        
        do {
            _ = try await jira.getIssue(issueIdOrKey: issueIdOrKey)
            XCTFail("Request should fail")
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
    
    func testMalformedIssueJSON() async {
        let issueIdOrKey = "MALFORMED-123"
        let path = "rest/api/2/issue/\(issueIdOrKey)"
        let url = URL(string: "https://jira.example.com/\(path)")!
        
        // Malformed JSON without required id/key fields
        let jsonData = """
        {
            "fields": {
                "summary": "Test Issue"
            }
        }
        """.data(using: .utf8)!
        
        // Mock the response
        MockURLProtocol.mockHTTPResponse(for: url, responseData: jsonData)
        
        do {
            _ = try await jira.getIssue(issueIdOrKey: issueIdOrKey)
            XCTFail("Request should fail with decoding error")
        } catch let error as SwiftyJIRA.JIRAError {
            switch error {
            case .decodingError:
                // Expected error
                break
            default:
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}