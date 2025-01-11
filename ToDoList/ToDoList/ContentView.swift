//
//  ContentView.swift
//  ToDoList
//
//  Created by Tirodoragon on 1/11/25.
//

import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var imageName: String
    var status: String
}

struct ContentView: View {
    @State private var tasks = [
        Task(title: "Prepare a presentation for class", imageName: "presentation", status: "To-Do"),
        Task(title: "Create a character model in Blender", imageName: "blender", status: "To-Do"),
        Task(title: "Create a level in Unity", imageName: "unity", status: "To-Do")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedTasks) { task in
                    NavigationLink(destination: TaskDetailView(task: binding(for: task))) {
                        HStack {
                            Image(task.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                            VStack(alignment: .leading) {
                                Text(task.title)
                                HStack {
                                    statusIcon(for: task.status)
                                    Text(task.status)
                                        .font(.subheadline)
                                        .foregroundColor(color(for: task.status))
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("To-Do List")
        }
    }
    
    private var sortedTasks: [Task] {
        tasks.sorted {
            if $0.statusPriority == $1.statusPriority {
                return $0.title < $1.title
            } else {
                return $0.statusPriority < $1.statusPriority
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func color(for status: String) -> Color {
        switch status {
        case "To-Do":
            return .gray
        case "In Progress":
            return .orange
        case "Done":
            return .green
        default:
            return .black
        }
    }
    
    private func statusIcon(for status: String) -> some View {
        switch status {
        case "To-Do":
            return Image(systemName: "circle")
        case "In Progress":
            return Image(systemName: "clock")
        case "Done":
            return Image(systemName: "checkmark.circle")
        default:
            return Image(systemName: "questionmark.circle")
        }
    }
    
    private func binding(for task: Task) -> Binding<Task> {
        guard let index = tasks.firstIndex(where: { $0.id == task.id}) else {
            fatalError("Task not found")
        }
        return $tasks[index]
    }
}

extension Task {
    var statusPriority: Int {
        switch status {
        case "To-Do":
            return 0
        case "In Progress":
            return 1
        case "Done":
            return 2
        default:
            return 3
        }
    }
}

struct TaskDetailView: View {
    @Binding var task: Task
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $task.title)
                Image(task.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            Section(header: Text("Status")) {
                Picker("Status", selection: $task.status) {
                    Text("To-Do").tag("To-Do")
                    Text("In Progress").tag("In Progress")
                    Text("Done").tag("Done")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Edit task status")
    }
}

#Preview {
    ContentView()
}
