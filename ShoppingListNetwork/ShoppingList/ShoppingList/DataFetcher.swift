//
//  DataFetcher.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import Foundation
import CoreData
import UIKit

class DataFetcher: ObservableObject {
    @Published var categories: [Dictionary<String, Any>] = []
    @Published var products: [Dictionary<String, Any>] = []
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func loadData() {
        APIClient.shared.fetchJSON(from: "/categories") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self.saveCategories(categories)
                case .failure(let error):
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }
        }
        
        APIClient.shared.fetchJSON(from: "/products") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self.saveProducts(products)
                case .failure(let error):
                    print("Failed to fetch products: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveCategories(_ categories: [Dictionary<String, Any>]) {
        for category in categories {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", category["id"] as? Int64 ?? 0)
            
            if let existingCategory = (try? viewContext.fetch(fetchRequest))?.first {
                existingCategory.name = category["name"] as? String ?? "Unknown Name"
                existingCategory.descriptionText = category["descriptionText"] as? String ?? "Unknown Description"
                existingCategory.iconName = category["iconName"] as? String ?? "Unknown Icon"
            } else {
                let newCategory = Category(context: viewContext)
                newCategory.id = category["id"] as? Int64 ?? 0
                newCategory.name = category["name"] as? String ?? "Unknown Name"
                newCategory.descriptionText = category["descriptionText"] as? String ?? "Unknown Description"
                newCategory.iconName = category["iconName"] as? String ?? "Unknown Icon"
            }
            
            if let iconName = category["iconName"] as? String {
                let imageURL = "http://127.0.0.1:5000/\(iconName)"
                downloadImage(from: imageURL, name: iconName)
            }
        }
        saveContext()
    }
    
    private func saveProducts(_ products: [Dictionary<String, Any>]) {
        for product in products {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", product["id"] as? Int64 ?? 0)
            
            if let existingProduct = (try? viewContext.fetch(fetchRequest))?.first {
                existingProduct.name = product["name"] as? String ?? "Unknown Name"
                existingProduct.descriptionText = product["descriptionText"] as? String ?? "Unknown Description"
                existingProduct.imageName = product["imageName"] as? String ?? "Unknown Image"
                existingProduct.price = product["price"] as? Double ?? 0.0
                if let categoryId = product["categoryId"] as? Int64 {
                    existingProduct.category = fetchCategory(by: categoryId)
                }
            } else {
                let newProduct = Product(context: viewContext)
                newProduct.id = product["id"] as? Int64 ?? 0
                newProduct.name = product["name"] as? String ?? "Unknown Name"
                newProduct.descriptionText = product["descriptionText"] as? String ?? "Unknown Description"
                newProduct.imageName = product["imageName"] as? String ?? "Unknown Image"
                newProduct.price = product["price"] as? Double ?? 0.0
                if let categoryId = product["categoryId"] as? Int64 {
                    newProduct.category = fetchCategory(by: categoryId)
                }
            }

            if let imageName = product["imageName"] as? String {
                let imageURL = "http://127.0.0.1:5000/\(imageName)"
                downloadImage(from: imageURL, name: imageName)
            }
        }
        saveContext()
    }
    
    private func fetchCategory(by id: Int64) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        return try? viewContext.fetch(fetchRequest).first
    }
    
    private func downloadImage(from urlString: String, name: String) {
        guard let url = URL(string: urlString) else { return }
        
        let fileName = (name as NSString).lastPathComponent
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                ImageCache.shared.saveImage(image, withName: fileName)
            }
        }.resume()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
