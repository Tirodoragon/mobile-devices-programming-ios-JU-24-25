//
//  UserSession.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import Foundation
import CoreData

class UserSession: ObservableObject {
    @Published var userId: String? = nil
    @Published var username: String? = nil
    
    func login(userId: String, username: String) {
        self.userId = userId
        self.username = username
    }

    func logout(viewContext: NSManagedObjectContext) {
        self.userId = nil
        self.username = nil
    }
}
