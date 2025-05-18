# SwiftyJIRA

A lightweight Swift package for interacting with the JIRA API.

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
