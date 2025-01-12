//
//  Persistence.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ShoppingList")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        loadFixturesIfNeeded(context: container.viewContext)
    }
    
    private func loadFixturesIfNeeded(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let count = (try? context.count(for: fetchRequest)) ?? 0
        if count == 0 {
            let electronics = Category(context: context)
            electronics.name = "Electronics"
            electronics.descriptionText = "Devices and gadgets"
            electronics.iconName = "electronics_icon"
            
            let homeAppliances = Category(context: context)
            homeAppliances.name = "Home Appliances"
            homeAppliances.descriptionText = "Essential home devices"
            homeAppliances.iconName = "home_icon"
            
            let laptop = Product(context: context)
            laptop.name = "Laptop"
            laptop.descriptionText = "High-performance laptop with 16GB RAM"
            laptop.price = 3499.99
            laptop.imageName = "laptop_image"
            laptop.id = UUID()
            laptop.category = electronics
            
            let refrigerator = Product(context: context)
            refrigerator.name = "Refrigerator"
            refrigerator.descriptionText = "Energy-efficient refrigerator with No Frost technology"
            refrigerator.price = 2499.00
            refrigerator.imageName = "fridge_image"
            refrigerator.id = UUID()
            refrigerator.category = homeAppliances
            
            let smartphone = Product(context: context)
            smartphone.name = "Smartphone"
            smartphone.descriptionText = "OLED display smartphone with a 108 MP camera"
            smartphone.price = 2999.99
            smartphone.imageName = "smartphone_image"
            smartphone.id = UUID()
            smartphone.category = electronics
            
            do {
                try context.save()
                print("Fixtures loaded successfully!")
            } catch {
                let nsError = error as NSError
                fatalError("Failed to load fixtures: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
