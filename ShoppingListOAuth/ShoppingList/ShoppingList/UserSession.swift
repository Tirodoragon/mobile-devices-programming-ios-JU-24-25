//
//  UserSession.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import Foundation
import CoreData

class UserSession: ObservableObject {
    @Published var userId: Int? = nil
    @Published var username: String? = nil
    @Published var isGoogleUser: Bool = false
    
    func login(userId: Int, username: String, isGoogleUser: Bool = false) {
        self.userId = userId
        self.username = username
        self.isGoogleUser = isGoogleUser
    }

    func logout(viewContext: NSManagedObjectContext) {
        if isGoogleUser {
            deleteLocalOrders(for: userId, context: viewContext)
        }
        self.userId = nil
        self.username = nil
        self.isGoogleUser = false
    }
    
    private func deleteLocalOrders(for userId: Int?, context: NSManagedObjectContext) {
        guard let userId = userId else { return }
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "customerId == %d", userId)
        
        do {
            let orders = try context.fetch(fetchRequest)
            for order in orders {
                context.delete(order)
            }
            try context.save()
        } catch {
            print("Failed to delete local orders: \(error.localizedDescription)")
        }
    }
}
