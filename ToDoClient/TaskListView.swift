//
//  TaskListView.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingNewTaskSheet = false
    @State private var searchQuery: String = ""
    @State private var selectedOrder: String = "asc"
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search tasks by name", text: $searchQuery, onCommit: {
                    viewModel.searchTasks(byName: searchQuery)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                // Сортировка
                Picker("Sort by", selection: $selectedOrder) {
                    Text("Ascending").tag("asc")
                    Text("Descending").tag("desc")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedOrder) { newOrder in
                    viewModel.fetchSortedTasks(order: newOrder)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading tasks...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.tasks) { task in
                        NavigationLink(destination: TaskDetailView(taskID: task.id)) {
                            TaskRow(task: task)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .onAppear {
                viewModel.fetchTasks()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingNewTaskSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskView(viewModel: viewModel)
            }
            .refreshable {
                viewModel.fetchTasks()
            }
        }
        
    }
    
}
