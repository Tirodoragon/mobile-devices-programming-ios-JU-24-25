//
//  CartView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI
import CoreData

struct CartView: View {
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        NavigationView {
            VStack {
                if cart.products.isEmpty {
                    Text("Your cart is empty.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(cart.products, id: \.self) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.name ?? "Unknown Product")
                                        .font(.headline)
                                    Text(String(format: "$%.2f", product.price))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Button(action: {
                                    cart.removeFromCart(product: product)
                                }) {
                                    Text("Remove")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                if !cart.products.isEmpty {
                    Text("Total: \(formatPrice(totalPrice))")
                        .font(.headline)
                        .padding(.top)
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if !cart.products.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear Cart") {
                            cart.clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var totalPrice: Double {
        cart.products.reduce(0) { $0 + $1.price }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: price)) ?? "$0.00"
    }
}

#Preview {
    let cart = Cart()
    let context = PersistenceController.preview.container.viewContext
    
    let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
    if let mockProducts = try? context.fetch(fetchRequest) {
        cart.products = Array(mockProducts.prefix(2))
    }
    
    return CartView()
        .environmentObject(cart)
}
