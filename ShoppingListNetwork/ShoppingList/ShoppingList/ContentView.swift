//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/16/25.
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
            CategoryListView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
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
