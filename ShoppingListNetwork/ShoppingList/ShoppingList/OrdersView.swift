//
//  OrdersView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import SwiftUI
import CoreData

struct OrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.date, ascending: true)],
        animation: .default
    ) private var orders: FetchedResults<Order>
    
    var body: some View {
        NavigationView {
            List {
                if orders.isEmpty {
                    Text("No orders available.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(orders, id: \.self) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Orders")
            .refreshable {
                refreshOrders()
            }
        }
    }
    
    private func refreshOrders() {
        let dataFetcher = DataFetcher(context: viewContext)
        dataFetcher.loadOrders()
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
