//
//  ContentView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ProductListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

#Preview {
    ContentView()
}
