//
//  ProductListView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/16/25.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    let category: Category
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cart: Cart
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default
    ) private var products: FetchedResults<Product>
    
    var body: some View {
        List(filteredProducts, id: \.self) { product in
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
                        Text(String(format: "%.2f", product.price))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle(category.name ?? "Products")
    }
    
    private var filteredProducts: [Product] {
        products.filter { $0.category == category }
    }
}
