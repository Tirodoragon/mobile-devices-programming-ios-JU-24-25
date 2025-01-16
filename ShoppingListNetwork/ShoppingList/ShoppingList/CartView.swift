//
//  CartView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/15/25.
//

import SwiftUI
import CoreData

struct CartView: View {
    @EnvironmentObject var cart: Cart
    @State private var isSubmittingOrder = false
    @State private var orderSubmissionSuccess: Bool? = nil
    @EnvironmentObject var dataFetcher: DataFetcher
    
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
                    
                    Button(action: submitOrder) {
                        Text("Place Order")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(isSubmittingOrder)
                }
                
                if let success = orderSubmissionSuccess {
                    Text(success ? "Order placed successfully!" : "Failed to place order. Please try again.")
                        .foregroundColor(success ? .green : .red)
                        .font(.headline)
                        .padding()
                        .transition(.opacity)
                        .onAppear() {
                            if !success {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    orderSubmissionSuccess = nil
                                }
                            }
                        }
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
            .onDisappear {
                orderSubmissionSuccess = nil
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
    
    private func submitOrder() {
        isSubmittingOrder = true
        orderSubmissionSuccess = nil
        
        let orderData = cart.prepareOrderData()
        APIClient.shared.postJSON(to: "/orders", data: orderData) { result in
            DispatchQueue.main.async {
                isSubmittingOrder = false
                switch result {
                case .success:
                    orderSubmissionSuccess = true
                    cart.clearCart()
                    dataFetcher.loadOrders()
                case .failure:
                    orderSubmissionSuccess = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        orderSubmissionSuccess = nil
                    }
                }
            }
        }
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
        .environmentObject(DataFetcher(context: context))
}
