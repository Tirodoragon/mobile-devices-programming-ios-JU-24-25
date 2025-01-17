//
//  CategoryListView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import SwiftUI
import CoreData

struct CategoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataFetcher: DataFetcher
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            if dataFetcher.isLoading {
                ProgressView("Loading categories...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(categories) { category in
                    NavigationLink(destination: ProductListView(category: category)) {
                        HStack {
                            if let iconName = category.iconName,
                               let cachedImage = ImageCache.shared.loadImage(named: iconName) {
                                    Image(uiImage: cachedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 75, height: 75)
                                        .cornerRadius(5)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75, height: 75)
                                    .cornerRadius(5)
                            }

                            VStack(alignment: .leading) {
                                Text(category.name ?? "Unknown Category")
                                    .font(.headline)
                                if let description = category.descriptionText, !description.isEmpty {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Categories")
            }
        }
        .onAppear {
            if categories.isEmpty {
                dataFetcher.loadData()
            }
        }
    }
}
