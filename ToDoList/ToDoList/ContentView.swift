//
//  ContentView.swift
//  ToDoList
//
//  Created by Tirodoragon on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    let tasks = ["Prepare a presentation for class", "Create a character model in Blender", "Create a level in Unity"]
    
    var body: some View {
        NavigationView {
            List(tasks, id: \.self) { task in
                Text(task)
            }
            .navigationTitle("To-Do List")
        }
    }
}

#Preview {
    ContentView()
}
