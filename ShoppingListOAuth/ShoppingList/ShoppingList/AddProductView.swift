//
//  AddProductView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/17/25.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var dataFetcher: DataFetcher
    
    let category: Category
    
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var price: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isSaving: Bool = false
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    TextField("Description", text: $descriptionText)
                        .textInputAutocapitalization(.sentences)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Image")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                            .onTapGesture {
                                showImagePicker = true
                            }
                    } else {
                        Button("Select Image") {
                            showImagePicker = true
                        }
                    }
                }
                
                if isSaving {
                    ProgressView("Saving...")
                        .frame(maxWidth: .infinity)
                } else {
                    Button(action: saveProduct) {
                        Text("Save Product")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveProduct() {
        guard !name.isEmpty, !price.isEmpty, let priceValue = Double(price), let selectedImage = selectedImage else {
            return
        }
        
        isSaving = true
        
        let newProductData: [String: Any] = [
            "name": name,
            "descriptionText": descriptionText,
            "price": priceValue,
            "categoryId": category.id
        ]
        
        uploadProduct(newProductData: newProductData, image: selectedImage)
    }
    
    private func uploadProduct(newProductData: [String: Any], image: UIImage) {
        guard let url = URL(string: "http://127.0.0.1:5000/products") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageName = "\(UUID().uuidString).png"
        let imageData = image.jpegData(compressionQuality: 0.8)!
        
        var body = Data()
        
        for (key, value) in newProductData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload product: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isSaving = false
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.dataFetcher.loadProducts {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("Unexpected server response: \(String(describing: response))")
                    self.isSaving = false
                }
            }
        }.resume()
    }
}
