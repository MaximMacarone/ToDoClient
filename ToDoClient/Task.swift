import Foundation

enum TaskStatus: String, Codable {
    case inProgress
    case completed
}

struct TaskModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let status: String
    let user: User
    let createdAt: String
}

struct TaskIDResponse: Codable, Identifiable {
    let id: String
}

struct Comment: Identifiable, Codable {
    let id: String
    let content: String
    let userID: String
}

struct TaskDetail: Codable {
    let id: String
    let title: String
    let description: String
    let status: String
    let createdAt: String
    let comments: [Comment]
}

struct User: Codable, Identifiable {
    let id: String
}
