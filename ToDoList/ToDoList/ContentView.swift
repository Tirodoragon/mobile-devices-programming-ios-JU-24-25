//
//  ContentView.swift
//  ToDoList
//
//  Created by Tirodoragon on 1/10/25.
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
                ForEach($tasks) { $task in
                    NavigationLink(destination: TaskDetailView(task: $task)) {
                        HStack {
                            Image(task.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                            Text(task.title)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("To-Do List")
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
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
