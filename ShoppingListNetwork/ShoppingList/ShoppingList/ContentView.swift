//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/15/25.
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
                .environmentObject(dataFetcher)
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .environmentObject(dataFetcher)
            
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.rectangle")
                }
                .environmentObject(dataFetcher)
        }
        .onAppear {
            dataFetcher.loadData()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ContentView(context: context)
        .environmentObject(Cart())
        .environmentObject(DataFetcher(context: context))
        .environment(\.managedObjectContext, context)
}
