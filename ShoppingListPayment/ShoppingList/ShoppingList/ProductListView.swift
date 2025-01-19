//
//  ProductListView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    let category: Category
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cart: Cart
    @EnvironmentObject var userSession: UserSession
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default
    ) private var products: FetchedResults<Product>
    
    @State private var isShowingAddProductView = false
    
    var body: some View {
        NavigationView {
            List(filteredProducts, id: \.self) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    HStack {
                        if let imageName = product.imageName,
                           let cachedImage = ImageCache.shared.loadImage(named: imageName) {
                            Image(uiImage: cachedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(product.name ?? "Unknown Product")
                                .font(.headline)
                            Text(String(format: "$%.2f", product.price))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle(category.name ?? "Products")
            .toolbar {
                if userSession.userId == "1" {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddProductView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddProductView) {
                AddProductView(category: category)
            }
        }
    }
    
    private var filteredProducts: [Product] {
        products.filter { $0.category == category }
    }
}
