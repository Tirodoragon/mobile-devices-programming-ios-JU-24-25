//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Label("Products", systemImage: "bag")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Cart())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
