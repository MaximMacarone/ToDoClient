import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://192.168.31.145:8080"
    
    private init() {}
    
    func login(username: String, password: String) async throws -> String {
        let url = URL(string: "\(baseURL)/login")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let credentials = "\(username):\(password)"
        let encodedCredentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.loginFailed
        }
        
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid response")
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        saveToken(token: tokenResponse.value)
        
        return tokenResponse.value
    }
    
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "bearerToken")
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "bearerToken")
    }
}

struct TokenResponse: Codable {
    let id: String
    let value: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
}

enum NetworkError: Error {
    case authenticationFailed
    case fetchError
    case registrationFailed
    case loginFailed
    case taskCreationFailed
    case taskDeleteFailed
    case taskEditFailed
}

extension NetworkService {
    func fetchTasks() async throws -> [TaskModel] {
        let url = URL(string: "\(baseURL)/tasks")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.fetchError
        }
        
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid response")
        
        let tasks = try JSONDecoder().decode([TaskModel].self, from: data)
        return tasks
    }
}

extension NetworkService {
    func register(username: String, password: String, passwordConfirmation: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/users")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: String] = ["username": username, "password": password, "passwordConfirmation": passwordConfirmation]
        request.httpBody = try? JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.registrationFailed
        }
        
        if httpResponse.statusCode == 200 {
            return true
        } else {
            throw NetworkError.registrationFailed
        }
    }
}

extension NetworkService {
    
    func fetchTaskDetails(taskID: String) async throws -> TaskDetail {
        let urlString = "\(baseURL)/tasks/\(taskID)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.fetchError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.fetchError
        }
        
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid response")
        
        let taskDetail = try JSONDecoder().decode(TaskDetail.self, from: data)
        return taskDetail
    }
    
    func postComment(forTaskId taskId: String, content: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let body: [String: String] = [
            "content": content,
            "taskId": taskId
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.fetchError
        }
        
        return true
    }
}

extension NetworkService {
    func createTask(title: String, description: String, status: TaskStatus) async throws {
        let url = URL(string: "\(baseURL)/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let requestBody: [String: String] = [
            "title": title,
            "description": description,
            "status": status.rawValue
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.taskCreationFailed
        }
        
        print("Task created successfully: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
    func deleteTask(taskID: String) async throws {
        let url = URL(string: "\(baseURL)/tasks/\(taskID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.taskDeleteFailed
        }
    }
    
    func editTask(taskID: String, title: String, description: String, status: TaskStatus) async throws {
        let url = URL(string: "\(baseURL)/tasks/\(taskID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        
        let requestBody: [String: String] = [
            "title": title,
            "description": description,
            "status": status.rawValue
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.taskEditFailed
        }
    }
    
    func fetchSortedTasks(order: String) async throws -> [TaskModel] {
        guard let url = URL(string: "\(baseURL)/tasks/sort?order=\(order)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([TaskModel].self, from: data)
    }
    
    func searchTasks(byTitle title: String) async throws -> [TaskModel] {
        guard let url = URL(string: "\(baseURL)/tasks/search?title=\(title)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.authenticationFailed
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([TaskModel].self, from: data)
    }
    
}
