//
//  PaidOrdersView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import SwiftUI
import CoreData

struct PaidOrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSession: UserSession
    
    @FetchRequest(
        entity: PaidOrder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PaidOrder.order?.date, ascending: false)],
        predicate: nil
    ) private var allPaidOrders: FetchedResults<PaidOrder>
    
    @State private var filteredOrders: [Order] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if filteredOrders.isEmpty {
                    Text("No paid orders available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredOrders, id: \.id) { order in
                        PaidOrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Paid Orders")
            .onAppear {
                refreshPaidOrders()
            }
        }
    }
    
    private func refreshPaidOrders() {
        isLoading = true
        guard let userId = userSession.userId else {
            filteredOrders = []
            print("Debug: No user logged in.")
            isLoading = false
            return
        }
                
        viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<PaidOrder> = PaidOrder.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PaidOrder.order?.date, ascending: false)]
            
            do {
                let fetchedPaidOrders = try viewContext.fetch(fetchRequest)
                
                filteredOrders = fetchedPaidOrders
                    .compactMap { $0.order }
                    .filter { $0.customerId == userId }
                
                
            } catch {
                print("Error fetching PaidOrders: \(error.localizedDescription)")
                filteredOrders = []
            }
        }
        
        isLoading = false
    }
}

struct PaidOrderRow: View {
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
