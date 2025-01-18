//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var cart: Cart
    @EnvironmentObject var userSession: UserSession
    @StateObject private var dataFetcher: DataFetcher
    
    init(context: NSManagedObjectContext) {
        _dataFetcher = StateObject(wrappedValue: DataFetcher(context: context))
    }
    
    var body: some View {
            NavigationView {
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
                    
                    OrdersView(userSession: userSession)
                        .tabItem {
                            Label("Orders", systemImage: "list.bullet.rectangle")
                        }
                        .environmentObject(dataFetcher)
                }
                .onAppear {
                    dataFetcher.loadData()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: logout) {
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }

        private func logout() {
            userSession.userId = nil
            cart.clearCart()
        }
    }
