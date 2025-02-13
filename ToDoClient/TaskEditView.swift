//
//  TaskEditView.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var viewModel: TaskDetailViewModel
    @State private var title: String = ""
    @State private var description: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Save Changes") {
                        Task {
                            await viewModel.editTask(title: title, description: description, status: .inProgress)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .onAppear {
                self.title = viewModel.taskDetail?.title ?? ""
                self.description = viewModel.taskDetail?.description ?? ""
            }
        }
    }
}
