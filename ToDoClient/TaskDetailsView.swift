//
//  TaskDetailsView.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 09.12.2024.
//

import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    @State private var showEditSheet = false
    
    init(taskID: String) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(taskID: taskID))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let taskDetail = viewModel.taskDetail {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(taskDetail.title)
                            .font(.title2)
                            .padding(.bottom, 2)
                        Text(taskDetail.description)
                            .padding(.bottom, 8)
                        
                        HStack {
                            Button(action: {
                                showEditSheet.toggle()
                            }) {
                                Text("Edit")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    viewModel.deleteTask()
                                }
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        
                        Text("Comments:")
                            .font(.headline)
                        
                        ForEach(taskDetail.comments) { comment in
                            VStack(alignment: .leading) {
                                Text(comment.content)
                                    .padding(.bottom, 2)
                                Text("by \(comment.userID)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        
                        HStack {
                            TextField("Write a comment...", text: $viewModel.commentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Send") {
                                Task {
                                    await viewModel.sendComment()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding()
                }
            } else {
                Text("No task details")
            }
        }
        .navigationTitle("Task Details")
        .sheet(isPresented: $showEditSheet) {
            EditTaskView(viewModel: viewModel)
        }
    }
}
