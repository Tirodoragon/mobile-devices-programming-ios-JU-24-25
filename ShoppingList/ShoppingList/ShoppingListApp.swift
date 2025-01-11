//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI

@main
struct ShoppingListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
