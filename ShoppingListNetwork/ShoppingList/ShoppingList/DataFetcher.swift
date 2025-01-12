//
//  DataFetcher.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import Foundation

class DataFetcher: ObservableObject {
    @Published var categories: [Dictionary<String, Any>] = []
    @Published var products: [Dictionary<String, Any>] = []
    
    func loadData() {
        APIClient.shared.fetchJSON(from: "/categories") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self.categories = categories
                    print("Fetched Categories:")
                    for category in categories {
                        let id = category["id"] as? Int ?? -1
                        let name = category["name"] as? String ?? "Unknown Name"
                        let description = category["descriptionText"] as? String ?? "Unknown Description"
                        let icon = category["iconName"] as? String ?? "Unknown Icon"
                        
                        print("""
                            ID: \(id)
                            Name: \(name)
                            Description: \(description)
                            Icon: \(icon)
                        
                        """)
                    }
                case .failure(let error):
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }
        }
        
        APIClient.shared.fetchJSON(from: "/products") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self.products = products
                    print("Fetched Products:")
                    for product in products {
                        let id = product["id"] as? Int ?? -1
                        let name = product["name"] as? String ?? "Unknown Name"
                        let description = product["descriptionText"] as? String ?? "Unknown Description"
                        let image = product["imageName"] as? String ?? "Unknown Image"
                        let price = product["price"] as? Double ?? -1.0
                        let categoryId = product["categoryId"] as? Int ?? -1
                        
                        print("""
                            ID: \(id)
                            Name: \(name)
                            Description: \(description)
                            Image: \(image)
                            Price: \(price)
                            Category ID: \(categoryId)
                        
                        """)                    }
                case .failure(let error):
                    print("Failed to fetch products: \(error.localizedDescription)")
                }
            }
        }
    }
}
