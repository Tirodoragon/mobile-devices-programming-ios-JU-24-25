//
//  OrdersView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import SwiftUI
import CoreData

struct OrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSession: UserSession

    private var localOrders: FetchRequest<Order>

    @State private var serverOrders: [Order] = []
    @State private var isLoading: Bool = false

    init(userSession: UserSession) {
        if let userId = userSession.userId, userSession.isOAuthUser {
            localOrders = FetchRequest<Order>(
                entity: Order.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \Order.date, ascending: false)],
                predicate: NSPredicate(format: "customerId == %d", userId)
            )
        } else {
            localOrders = FetchRequest<Order>(
                entity: Order.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \Order.date, ascending: false)],
                predicate: nil
            )
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if filteredOrders.isEmpty {
                    Text("No orders available.")
                        .foregroundColor(.gray)
                } else {
                    List(filteredOrders, id: \.self) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Orders")
            .refreshable {
                if !userSession.isOAuthUser {
                    refreshOrders()
                }
            }
            .onAppear {
                if !userSession.isOAuthUser {
                    refreshOrders()
                }
            }
        }
    }

    private var filteredOrders: [Order] {
        if userSession.isOAuthUser {
            return Array(localOrders.wrappedValue)
        } else {
            guard let userId = userSession.userId else { return [] }
            return serverOrders.filter { $0.customerId == userId }
        }
    }

    private func refreshOrders() {
        guard !userSession.isOAuthUser, let userId = userSession.userId else {
            return
        }

        isLoading = true
        let dataFetcher = DataFetcher(context: viewContext)

        dataFetcher.loadOrders { fetchedOrders in
            DispatchQueue.main.async {
                self.serverOrders = fetchedOrders
                    .filter { $0.customerId == userId }
                    .sorted(by: { $0.date ?? Date() > $1.date ?? Date() })
                self.isLoading = false
            }
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(formatDate(order.date))")
                .font(.headline)
            Text("Total: $\(String(format: "%.2f", order.totalPrice))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            renderProductsAndQuantities()
        }
        .padding(.vertical, 5)
    }

    private func renderProductsAndQuantities() -> some View {
        Group {
            if let productsSet = order.products?.allObjects as? [Product],
               let quantities = order.quantities as? [Int64] {
                let sortedProducts = productsSet.sorted { $0.id < $1.id }
                let pairs = zip(sortedProducts, quantities)

                ForEach(Array(pairs), id: \.0.id) { product, quantity in
                    Text("\(product.name ?? "Unknown Product") - Quantity: \(quantity)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Error loading products or quantities.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
}
