# SwiftyJIRA

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLunaticMuch%2Fswiftyjira%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/LunaticMuch/swiftyjira)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FLunaticMuch%2Fswiftyjira%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/LunaticMuch/swiftyjira)

A lightweight Swift package for interacting with the JIRA REST API v2. SwiftyJIRA provides a clean, strongly-typed interface to Atlassian's JIRA platform, making it easy to integrate JIRA functionality into your Swift applications.

## Installation

Add SwiftyJIRA to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/lunaticmuch/swiftyjira.git", from: "1.0.0")
]
```

## Usage

### Initialize the client

```swift
import SwiftyJIRA

do {
    let jira = try SwiftyJIRA(
        baseURL: "https://your-jira-instance.atlassian.net",
        authToken: "your-auth-token"
    )
    // Use the client...
} catch {
    print("Failed to initialize JIRA client: \(error)")
}
```

Please note that currently **only** token authentication is supported.

### Get server information

```swift
do {
    let serverInfo = try await jira.getServerInfo()
    print("JIRA version: \(serverInfo.version)")
    print("Server title: \(serverInfo.serverTitle)")
} catch {
    print("Failed to get server info: \(error)")
}
```

### Working with issues

```swift
// Get an issue by key
let issueKey = "PROJ-123"
do {
    let issueResponse = try await jira.getIssue(issueIdOrKey: issueKey)
    print("Issue: \(issueResponse.parsed.key)")
    print("Summary: \(issueResponse.parsed.fields.summary ?? "No summary")")

    if let assignee = issueResponse.parsed.fields.assignee {
        print("Assigned to: \(assignee.displayName)")
    }
} catch {
    print("Failed to get issue: \(error)")
}

// Get an issue with specific fields only
let fieldsToFetch = ["summary", "status", "assignee"]
let issueWithFields = try await jira.getIssue(
    issueIdOrKey: issueKey,
    fields: fieldsToFetch
)

// Get an issue with its changelog
let issueWithChangelog = try await jira.getIssueWithChangelog(issueIdOrKey: issueKey)
```

### Get User information

```swift
// Get current user
do {
    let userResponse = try await jira.getCurrentUser()
    print("Logged in as: \(userResponse.parsed.displayName)")

    // Access raw JSON if needed
    let rawEmail = userResponse.raw["emailAddress"].string
} catch {
    print("Failed to get current user: \(error)")
}

// Find a user by their account ID
let accountId = "5b10a2844c20165700ede21g"
let user = try await jira.getUser(accountId: accountId)
```

## Advanced Usage

### The `JIRAResponse` Structure

All API methods return a `JIRAResponse<T>` object containing both:

- `raw`: The raw JSON response from the API (using SwiftyJSON)
- `parsed`: A strongly-typed Swift object

This gives you flexibility to access structured data while still having access to the complete response:

```swift
let response = try await jira.getIssue(issueIdOrKey: "PROJ-123")

// Use the structured model
let summary = response.parsed.fields.summary

// Access the raw JSON for custom fields or other data not in the model
let customFieldValue = response.raw["fields"]["customfield_10001"].string
```

## Error Handling

```swift
do {
    let response = try await jira.getIssue(issueIdOrKey: "INVALID-KEY")
} catch let error as SwiftyJIRA.JIRAError {
    switch error {
    case .invalidURL:
        print("The URL is invalid")
    case .invalidResponse:
        print("The response could not be parsed")
    case .serverError(let statusCode):
        print("Server returned error \(statusCode)")
    case .decodingError(let underlyingError):
        print("Failed to decode: \(underlyingError.localizedDescription)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

## Features

- Simple authentication with Bearer token
- Asynchronous API using Swift's modern async/await
- Error handling with custom error types
- Type-safe responses
- No external network calls during testing

## Requirements

- Swift 5.5 or later
- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+

## Dependencies

- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - Used for JSON parsing

## License

MIT
