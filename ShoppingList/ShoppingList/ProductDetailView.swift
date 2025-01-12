//
//  ProductDetailView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
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
        }
        .padding()
        .navigationTitle(product.name ?? "Product Details")
    }
}
