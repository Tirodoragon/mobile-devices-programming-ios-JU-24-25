//
//  ProductDetailView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import SwiftUI
import CoreData

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: Cart
    
    var body: some View {
        VStack(spacing: 20) {
            if let imageName = product.imageName, let cachedImage = ImageCache.shared.loadImage(named: imageName) {
                Image(uiImage: cachedImage)
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
            
            VStack(spacing: 10) {
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
    }
}
