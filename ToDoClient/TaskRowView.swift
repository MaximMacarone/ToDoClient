import SwiftUI

struct TaskRow: View {
    let task: TaskModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Status: \(task.status)")
                .font(.caption)
                .foregroundColor(task.status == "inProgress" ? .orange : .green)
        }
        .padding(.vertical, 8)
    }
}
