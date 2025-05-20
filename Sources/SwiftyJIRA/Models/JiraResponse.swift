import Foundation
import SwiftyJSON

public struct JIRAResponse<T> {
    /// The raw JSON response from the JIRA API
    public let raw: JSON
    
    /// The parsed object from the JSON response
    public let parsed: T
}