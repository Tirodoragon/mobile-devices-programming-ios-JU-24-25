//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import SwiftUI

@main
struct ShoppingListApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var cart = Cart()
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView(context: persistenceController.container.viewContext)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(cart)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
