//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import SwiftUI

@main
struct ShoppingListApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            if let _ = userSession.userId {
                ContentView(context: persistenceController.container.viewContext)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(Cart(userSession: userSession))
                    .environmentObject(userSession)
            } else {
                LoginView()
                    .environmentObject(userSession)
            }
        }
    }
}
