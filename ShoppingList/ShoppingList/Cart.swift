//
//  Cart.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import Combine

class Cart: ObservableObject {
    @Published var products: [Product] = []
    
    func addToCart(product: Product) {
        if !products.contains(where: { $0.id == product.id }) {
            products.append(product)
        }
    }
    
    func removeFromCart(product: Product) {
        products.removeAll { $0.id == product.id }
    }
    
    func clearCart() {
        products.removeAll()
    }
}
