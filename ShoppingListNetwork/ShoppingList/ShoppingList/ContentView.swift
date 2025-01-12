//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var cart: Cart
    @StateObject private var dataFetcher: DataFetcher
    
    init(context: NSManagedObjectContext) {
        _dataFetcher = StateObject(wrappedValue: DataFetcher(context: context))
    }
    
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
        .onAppear {
            dataFetcher.loadData()
        }
    }
}

#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
        .environmentObject(Cart())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

