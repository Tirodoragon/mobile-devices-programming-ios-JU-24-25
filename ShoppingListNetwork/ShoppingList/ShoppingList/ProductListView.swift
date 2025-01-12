//
//  ProductListView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cart: Cart
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    let categoryName = category.name ?? "Unknown Category"
                    let categoryDescription = category.descriptionText ?? ""
                    
                    let products = Array(category.products as? Set<Product> ?? [])
                        .sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
                    
                    Section(
                        header: VStack(alignment: .leading, spacing: 5) {
                            Text(categoryName)
                                .font(.headline)
                            if !categoryDescription.isEmpty {
                                Text(categoryDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    ) {
                        ForEach(products, id: \.self) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                VStack(alignment: .leading) {
                                    Text(product.name ?? "Unknown Product")
                                        .font(.body)
                                    Text(String(format: "$%.2f", product.price))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Products")
        }
    }
}

#Preview {
    ProductListView()
        .environmentObject(Cart())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
