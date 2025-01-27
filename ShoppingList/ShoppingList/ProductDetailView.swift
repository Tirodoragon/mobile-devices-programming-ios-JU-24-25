//
//  ProductDetailView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI
import CoreData

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        VStack(spacing: 20) {
            if let imageName = product.imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(product.name ?? "Unknown Product")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(String(format: "$%.2f", product.price))
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(product.descriptionText ?? "No description available")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                cart.addToCart(product: product)
            }) {
                Text("Add to Cart")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .navigationTitle(product.name ?? "Product Details")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
    fetchRequest.fetchLimit = 1
    
    guard let product = try? context.fetch(fetchRequest).first else {
        fatalError("No products found in preview context.")
    }
    
    return ProductDetailView(product: product)
        .environmentObject(Cart())
        .environment(\.managedObjectContext, context)
}
