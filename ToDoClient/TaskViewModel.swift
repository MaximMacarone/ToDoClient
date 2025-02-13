//
//  TaskViewModel.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchTasks() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedTasks = try await NetworkService.shared.fetchTasks()
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func createNewTask(title: String, description: String, status: TaskStatus) {
        Task {
            do {
                try await NetworkService.shared.createTask(title: title, description: description, status: status)
                fetchTasks()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to create a new task"
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchSortedTasks(order: String) {
        isLoading = true
        Task {
            do {
                let sortedTasks = try await NetworkService.shared.fetchSortedTasks(order: order)
                DispatchQueue.main.async {
                    self.tasks = sortedTasks
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch sorted tasks"
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchTasks(byName name: String) {
        isLoading = true
        Task {
            do {
                let searchedTasks = try await NetworkService.shared.searchTasks(byTitle: name)
                DispatchQueue.main.async {
                    self.tasks = searchedTasks
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to search tasks"
                    self.isLoading = false
                }
            }
        }
    }
}
