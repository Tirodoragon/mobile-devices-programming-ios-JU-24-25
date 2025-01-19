//
//  Cart.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import Combine
import Foundation

class Cart: ObservableObject {
    @Published var products: [Product: Int] = [:]
    private var userSession: UserSession
    
    init(userSession: UserSession) {
        self.userSession = userSession
    }
    
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
    
    func prepareOrderData() -> [String: Any]? {
        guard let customerId = userSession.userId else {
            print("Error: User is not logged in")
            return nil
        }
        
        let productIds = products.keys.map { $0.id }
        let quantities = products.values.map { Int64($0) }
        let totalPrice = self.totalPrice()
        
        return [
            "date": ISO8601DateFormatter().string(from: Date()),
            "totalPrice": totalPrice,
            "products": productIds,
            "quantities": quantities,
            "customerId": customerId
        ]
    }
}
