//
//  NewTaskView.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import SwiftUI

struct NewTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var title: String = ""
    @State private var description: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Create Task") {
                        Task {
                            viewModel.createNewTask(title: title, description: description, status: .inProgress)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
