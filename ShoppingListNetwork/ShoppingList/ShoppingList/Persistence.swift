//
//  Persistence.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static let inMemory: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
    
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
    }
}
