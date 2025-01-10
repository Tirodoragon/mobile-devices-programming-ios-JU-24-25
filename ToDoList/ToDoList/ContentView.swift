//
//  ContentView.swift
//  ToDoList
//
//  Created by Tirodoragon on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tasks = [
        ("Prepare a presentation for class", "presentation"),
        ("Create a character model in Blender", "blender"),
        ("Create a level in Unity", "unity")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks, id: \.0) { task, imageName in
                    HStack {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                        Text(task)
                    }
                    .padding(.vertical, 5)
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

#Preview {
    ContentView()
}
