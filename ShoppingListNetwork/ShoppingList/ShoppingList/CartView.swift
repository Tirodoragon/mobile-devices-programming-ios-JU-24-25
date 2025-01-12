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
                        ForEach(cart.products.keys.sorted(by: { $0.name ?? "" < $1.name ?? "" }), id: \.self) { product in
                            HStack {
                                if let imageName = product.imageName,
                                   let cachedImage = ImageCache.shared.loadImage(named: imageName) {
                                    Image(uiImage: cachedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(product.name ?? "Unknown Product")
                                        .font(.headline)
                                    Text("Price: \(formatPrice(product.price))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Subtotal: \(formatPrice(product.price * Double(cart.products[product] ?? 0)))")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        cart.removeFromCart(product: product)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Text("\(cart.products[product] ?? 0)")
                                        .font(.body)
                                        .frame(width: 30, alignment: .center)
                                    
                                    Button(action: {
                                        cart.addToCart(product: product)
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.green)
                                    }
                                    .buttonStyle(.plain)
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
        cart.products.reduce(0) { total, pair in
            let (product, quantity) = pair
            return total + (product.price * Double(quantity))
        }
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
        for product in mockProducts.prefix(2) {
            cart.addToCart(product: product)
            cart.addToCart(product: product)
        }
    }
    
    return CartView()
        .environmentObject(cart)
}
