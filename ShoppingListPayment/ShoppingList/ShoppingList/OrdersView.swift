//
//  OrdersView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import SwiftUI
import CoreData

struct OrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSession: UserSession

    @FetchRequest(
        entity: Order.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.date, ascending: false)],
        predicate: nil
    ) private var localOrders: FetchedResults<Order>

    @State private var serverOrders: [Order] = []
    @State private var isLoading: Bool = false
    @State private var paidOrders: Set<Int64> = []
    @State private var selectedOrderId: Int64? = nil
    @State private var showPaymentForm = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if filteredOrders.isEmpty {
                    Text("No orders available.")
                        .foregroundColor(.gray)
                } else {
                    List(filteredOrders, id: \Order.id) { order in
                        OrderRow(
                            order: order,
                            isPaid: paidOrders.contains(order.id),
                            onPay: {
                                selectedOrderId = order.id
                            }
                        )
                    }
                }
            }
            .navigationTitle("Orders")
            .refreshable {
                refreshOrders()
            }
            .onAppear {
                refreshOrders()
            }
            .fullScreenCover(isPresented: $showPaymentForm, onDismiss: {
                selectedOrderId = nil
            }) {
                if let orderId = selectedOrderId {
                    PaymentFormView(orderId: .constant(orderId), onPaymentCompletion: {
                        paidOrders.insert(orderId)
                        selectedOrderId = nil
                        showPaymentForm = false
                    })
                } else {
                    Text("Error: No Order Selected")
                }
            }
            .onChange(of: selectedOrderId) {
                showPaymentForm = selectedOrderId != nil
            }
        }
    }

    private var filteredOrders: [Order] {
        guard let userId = userSession.userId else { return [] }
        return serverOrders.filter { $0.customerId == userId }
    }

    private func refreshOrders() {
        guard let userId = userSession.userId else {
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
    let isPaid: Bool
    let onPay: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(formatDate(order.date))")
                .font(.headline)
            Text("Total: $\(String(format: "%.2f", order.totalPrice))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            renderProductsAndQuantities()
            if !isPaid {
                Button(action: onPay) {
                    Text("Pay Now")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            } else {
                Text("Paid")
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
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
