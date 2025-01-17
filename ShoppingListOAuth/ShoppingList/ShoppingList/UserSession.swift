//
//  UserSession.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import Foundation

class UserSession: ObservableObject {
    @Published var userId: Int? = nil
    @Published var username: String? = nil

    func login(userId: Int, username: String) {
        self.userId = userId
        self.username = username
    }

    func logout() {
        self.userId = nil
        self.username = nil
    }
}
