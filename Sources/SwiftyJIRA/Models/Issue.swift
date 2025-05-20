import Foundation
import SwiftyJSON

public struct JIRAIssue: Codable {
    public let id: String
    public let key: String
    public let fields: IssueFields
    public let changelog: Changelog?

    public struct IssueFields: Codable {
        // Only summary is required in the base model
        public let summary: String?
        public let description: String?
        public let issuetype: IssueType?
        public let project: Project?
        public let status: Status?
        public let priority: Priority?
        public let creator: JIRAUser?
        public let assignee: JIRAUser?
        public let reporter: JIRAUser?
        public let created: String?
        public let updated: String?
        public let duedate: String?

        // Store the raw data for any additional fields
        public let rawData: JSON

        public init(json: JSON) {
            // Store raw data for any field access not defined in the model
            self.rawData = json

            self.summary = json["summary"].string
            self.description = json["description"].string

            if let issueTypeJson = json["issuetype"].dictionary {
                self.issuetype = try? IssueType(json: JSON(issueTypeJson))
            } else {
                self.issuetype = nil
            }

            if let projectJson = json["project"].dictionary {
                self.project = try? Project(json: JSON(projectJson))
            } else {
                self.project = nil
            }

            if let statusJson = json["status"].dictionary {
                self.status = try? Status(json: JSON(statusJson))
            } else {
                self.status = nil
            }

            if let priorityJson = json["priority"].dictionary {
                self.priority = try? Priority(json: JSON(priorityJson))
            } else {
                self.priority = nil
            }

            if let creatorJson = json["creator"].dictionary {
                self.creator = try? JIRAUser(json: JSON(creatorJson))
            } else {
                self.creator = nil
            }

            if let assigneeJson = json["assignee"].dictionary {
                self.assignee = try? JIRAUser(json: JSON(assigneeJson))
            } else {
                self.assignee = nil
            }

            if let reporterJson = json["reporter"].dictionary {
                self.reporter = try? JIRAUser(json: JSON(reporterJson))
            } else {
                self.reporter = nil
            }

            self.created = json["created"].string
            self.updated = json["updated"].string
            self.duedate = json["duedate"].string
        }

        // Helper function to access custom fields or other fields not in the model
        public func getField(_ fieldName: String) -> JSON {
            return rawData[fieldName]
        }
    }

    public struct IssueType: Codable {
        public let id: String
        public let name: String?
        public let description: String?
        public let iconUrl: String?

        public init(json: JSON) throws {
            guard let id = json["id"].string else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 2005,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode issue type"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }

            self.id = id
            self.name = json["name"].string
            self.description = json["description"].string
            self.iconUrl = json["iconUrl"].string
        }
    }

    // Similar updates for Project, Status, etc. - making non-id fields optional

    public struct Project: Codable {
        public let id: String
        public let key: String?
        public let name: String?

        public init(json: JSON) throws {
            guard let id = json["id"].string else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 2006,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode project"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }

            self.id = id
            self.key = json["key"].string
            self.name = json["name"].string
        }
    }

    public struct Status: Codable {
        public let id: String
        public let name: String?
        public let statusCategory: StatusCategory?

        public init(json: JSON) throws {
            guard let id = json["id"].string else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 2007,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode status"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }

            self.id = id
            self.name = json["name"].string

            if let statusCategoryJson = json["statusCategory"].dictionary {
                self.statusCategory = try? StatusCategory(json: JSON(statusCategoryJson))
            } else {
                self.statusCategory = nil
            }
        }
    }

    public struct StatusCategory: Codable {
        public let id: Int
        public let key: String?
        public let name: String?

        public init(json: JSON) throws {
            guard let id = json["id"].int else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 2008,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode status category"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }

            self.id = id
            self.key = json["key"].string
            self.name = json["name"].string
        }
    }

    public struct Priority: Codable {
        public let id: String
        public let name: String?
        public let iconUrl: String?

        public init(json: JSON) throws {
            guard let id = json["id"].string else {
                let error = NSError(
                    domain: "SwiftyJIRA",
                    code: 2009,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode priority"]
                )
                throw SwiftyJIRA.JIRAError.decodingError(error)
            }

            self.id = id
            self.name = json["name"].string
            self.iconUrl = json["iconUrl"].string
        }
    }

    // Keep changelog as is
    public struct Changelog: Codable {
        public let startAt: Int?
        public let maxResults: Int?
        public let total: Int?
        public let histories: [History]

        public init(json: JSON) throws {
            self.startAt = json["startAt"].int
            self.maxResults = json["maxResults"].int
            self.total = json["total"].int

            var histories: [History] = []
            if let historiesArray = json["histories"].array {
                for historyJson in historiesArray {
                    if let history = try? History(json: historyJson) {
                        histories.append(history)
                    }
                }
            }
            self.histories = histories
        }

        public struct History: Codable {
            public let id: String
            public let author: JIRAUser?
            public let created: String?
            public let items: [HistoryItem]

            public init(json: JSON) throws {
                guard let id = json["id"].string else {
                    let error = NSError(
                        domain: "SwiftyJIRA",
                        code: 2011,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to decode history"]
                    )
                    throw SwiftyJIRA.JIRAError.decodingError(error)
                }

                self.id = id
                self.created = json["created"].string

                if let authorJson = json["author"].dictionary {
                    self.author = try? JIRAUser(json: JSON(authorJson))
                } else {
                    self.author = nil
                }

                var items: [HistoryItem] = []
                if let itemsArray = json["items"].array {
                    for itemJson in itemsArray {
                        if let item = try? HistoryItem(json: itemJson) {
                            items.append(item)
                        }
                    }
                }
                self.items = items
            }
        }

        public struct HistoryItem: Codable {
            public let field: String
            public let fieldtype: String?
            public let from: String?
            public let fromString: String?
            public let to: String?
            public let toString: String?

            public init(json: JSON) throws {
                guard let field = json["field"].string else {
                    let error = NSError(
                        domain: "SwiftyJIRA",
                        code: 2012,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to decode history item"]
                    )
                    throw SwiftyJIRA.JIRAError.decodingError(error)
                }

                self.field = field
                self.fieldtype = json["fieldtype"].string
                self.from = json["from"].string
                self.fromString = json["fromString"].string
                self.to = json["to"].string
                self.toString = json["toString"].string
            }
        }
    }

    public init(json: JSON) throws {
        guard let id = json["id"].string,
            let key = json["key"].string
        else {
            let error = NSError(
                domain: "SwiftyJIRA",
                code: 2000,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode issue"]
            )
            throw SwiftyJIRA.JIRAError.decodingError(error)
        }

        self.id = id
        self.key = key

        // If fields is missing or empty, create an empty fields object
        let fieldsJson = json["fields"].dictionary ?? [:]
        self.fields = IssueFields(json: JSON(fieldsJson))

        if let changelogJson = json["changelog"].dictionary {
            self.changelog = try? Changelog(json: JSON(changelogJson))
        } else {
            self.changelog = nil
        }
    }
}
