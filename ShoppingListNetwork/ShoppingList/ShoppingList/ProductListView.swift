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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default
    ) private var products: FetchedResults<Product>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    let categoryName = category.name ?? "Unknown Category"
                    let categoryDescription = category.descriptionText ?? ""
                    
                    let filteredProducts = products.filter { $0.category == category }
                    
                    Section(
                        header: HStack(spacing: 10) {
                            if let iconName = category.iconName,
                               let cachedImage = ImageCache.shared.loadImage(named: iconName) {
                                Image(uiImage: cachedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(categoryName)
                                    .font(.headline)
                                if !categoryDescription.isEmpty {
                                    Text(categoryDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    ) {
                        ForEach(filteredProducts, id: \.self) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                HStack {
                                    if let imageName = product.imageName,
                                       let cachedImage = ImageCache.shared.loadImage(named: imageName) {
                                        Image(uiImage: cachedImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                            .cornerRadius(8)
                                    }
                                    
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
