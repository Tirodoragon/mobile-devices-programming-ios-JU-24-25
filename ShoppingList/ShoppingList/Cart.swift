//
//  Cart.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import Combine

class Cart: ObservableObject {
    @Published var products: [Product: Int] = [:]
    
    func addToCart(product: Product) {
        if let currentQuantity = products[product] {
            products[product] = currentQuantity + 1
        } else {
            products[product] = 1
        }
    }
    
    func removeFromCart(product: Product) {
        if let currentQuantity = products[product], currentQuantity > 1 {
            products[product] = currentQuantity - 1
        } else {
            products[product] = nil
        }
    }
    
    func clearCart() {
        products.removeAll()
    }
    
    func totalPrice() -> Double {
        products.reduce(0) { $0 + ($1.key.price * Double($1.value)) }
    }
}
