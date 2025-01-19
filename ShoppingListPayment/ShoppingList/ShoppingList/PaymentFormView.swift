//
//  PaymentFormView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import SwiftUI
import CoreData

struct PaymentFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var orderId: Int64
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var isProcessing: Bool = false
    @State private var paymentStatus: String = ""
    @State private var paymentId: Int64 = 0
    @State private var showValidationMessage: Bool = false
    var onPaymentCompletion: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Credit Card Payment")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Card Number")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Enter card number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Expiry Date (MM/YY)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter expiry date", text: $expiryDate)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CVV")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter CVV", text: $cvv)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                }
                
                if showValidationMessage {
                    Text("Please fill in all fields to proceed with payment.")
                        .foregroundColor(.red)
                }
                
                if !paymentStatus.isEmpty {
                    Text(paymentStatus)
                        .foregroundColor(paymentStatus == "Payment Successful!" ? .green : .red)
                }
                
                if isProcessing {
                    ProgressView("Processing...")
                } else {
                    Button(action: validateAndProcessPayment) {
                        Text("Pay Now")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Payment")
            .padding()
            .onChange(of: paymentStatus) { oldValue, newValue in
                if newValue == "Payment Successful!" {
                    onPaymentCompletion()
                }
            }
        }
        .interactiveDismissDisabled(isProcessing)
    }
    
    private func validateAndProcessPayment() {
        if cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty {
            showValidationMessage = true
            paymentStatus = ""
        } else {
            showValidationMessage = false
            processPayment()
        }
    }
    
    private func processPayment() {
        isProcessing = true
        paymentStatus = ""
        paymentId = getNextAvailableId()
        
        let paymentData: [String: Any] = [
            "orderId": orderId,
            "paymentDate": ISO8601DateFormatter().string(from: Date()),
            "status": "pending",
            "method": "credit_card",
            "cardNumber": cardNumber,
            "expiryDate": expiryDate,
            "cvv": cvv,
            "paymentId": paymentId
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/pay") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: paymentData) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false
                if let error = error {
                    paymentStatus = "Payment failed: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    paymentStatus = "Payment failed: Invalid server response."
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if let status = json["status"] as? String, status == "completed" {
                        paymentStatus = "Payment Successful!"
                        savePaymentToCoreData(paymentId: paymentId)
                        onPaymentCompletion()
                    } else {
                        paymentStatus = "Payment failed: \(json["message"] as? String ?? "Unknown error.")"
                    }
                } else {
                    paymentStatus = "Payment failed: \(json["error"] as? String ?? json["message"] as? String ?? "Unknown error.")"
                }
            }
        }.resume()
    }
    
    private func savePaymentToCoreData(paymentId: Int64) {
        let payment = Payment(context: viewContext)
        payment.id = paymentId
        payment.method = "credit_card"
        payment.paymentDate = Date()
        payment.status = "completed"
        
        if let order = fetchOrderById(orderId: orderId) {
            order.payment = payment
            payment.order = order
            
            let paidOrder = PaidOrder(context: viewContext)
            paidOrder.id = paymentId
            paidOrder.order = order
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving payment to CoreData: \(error.localizedDescription)")
        }
    }
    
    private func getNextAvailableId() -> Int64 {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.propertiesToFetch = ["id"]
        
        do {
            let payments = try viewContext.fetch(fetchRequest)

            if payments.isEmpty {
                return 1
            } else {
                let usedIds = payments.compactMap { $0.id }.sorted()
                return (usedIds.last ?? 0) + 1
            }
        } catch {
            print("Failed to fetch payments: \(error)")
            return 1
        }
    }
        
    private func fetchOrderById(orderId: Int64) -> Order? {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", orderId)
        
        do {
            return try viewContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching order by ID: \(error.localizedDescription)")
            return nil
        }
    }
}
