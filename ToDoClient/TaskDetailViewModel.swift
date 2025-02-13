//
//  TaskDetailViewModel.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import Foundation

class TaskDetailViewModel: ObservableObject {
    @Published var taskDetail: TaskDetail?
    @Published var commentText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    let taskID: String
    
    init(taskID: String) {
        self.taskID = taskID
        Task {
            await fetchTask()
        }
    }
    
    func fetchTask() {
        isLoading = true
        Task {
            do {
                let fetchedTask = try await NetworkService.shared.fetchTaskDetails(taskID: taskID)
                DispatchQueue.main.async {
                    self.taskDetail = fetchedTask
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to fetch task details"
                }
            }
        }
    }
    
    // Handle sending a new comment
    func sendComment() {
        guard let taskDetail = taskDetail else {
            self.error = "No task selected"
            return
        }
        Task {
            do {
                // Attempt to send the comment
                try await NetworkService.shared.postComment(forTaskId: taskDetail.id, content: commentText)
                
                // Clear text and fetch updated task details
                DispatchQueue.main.async {
                    self.commentText = ""
                }
                
                fetchTask()
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to send comment: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func editTask(title: String, description: String, status: TaskStatus) {
        Task {
            do {
                try await NetworkService.shared.editTask(taskID: taskID, title: title, description: description, status: status)
                fetchTask()
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to edit task"
                }
            }
        }
    }
    
    func deleteTask() {
        Task {
            do {
                try await NetworkService.shared.deleteTask(taskID: taskID)
                DispatchQueue.main.async {
                    self.taskDetail = nil
                    self.error = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to delete task"
                }
            }
        }
    }
}
