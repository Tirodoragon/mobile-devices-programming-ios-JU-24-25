//
//  PaymentFormView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/23/25.
//

import SwiftUI
import CoreData
import StripePaymentSheet

struct PaymentFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var orderId: Int64
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var isProcessing: Bool = false
    @State private var paymentId: Int64 = 0
    @State private var showValidationMessage: Bool = false
    @ObservedObject var model = MyBackendModel()
    var onPaymentCompletion: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let paymentSheet = model.paymentSheet {
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
                    
                    if !model.paymentStatus.isEmpty {
                        Text(model.paymentStatus)
                            .foregroundColor(model.paymentStatus == "Payment Successful!" ? .green : .red)
                    }
                    
                    if isProcessing {
                        ProgressView("Processing...")
                    } else {
                        Button(action: validateAndProcessPayment) {
                            Text("Pay with Card")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    PaymentSheet.PaymentButton(
                        paymentSheet: paymentSheet,
                        onCompletion: model.onPaymentCompletion
                    ) {
                        Text("Pay with Stripe")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 84/255, green: 51/255, blue: 255/255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
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
                } else {
                    ProgressView("Loading payment...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                model.preparePaymentSheet(paymentId: paymentId, orderId: orderId, viewContext: viewContext)
            }
            .navigationTitle("Payment")
            .padding()
            .onChange(of: model.paymentStatus) { oldValue, newValue in
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
            model.paymentStatus = ""
        } else {
            showValidationMessage = false
            processPayment()
        }
    }
    
    private func processPayment() {
        isProcessing = true
        model.paymentStatus = ""
        paymentId = CoreDataHelper.getNextAvailableId(viewContext: viewContext)
        let method = "credit_card"
        let paymentData: [String: Any] = [
            "orderId": orderId,
            "paymentDate": ISO8601DateFormatter().string(from: Date()),
            "status": "pending",
            "method": method,
            "cardNumber": cardNumber,
            "expiryDate": expiryDate,
            "cvv": cvv,
            "paymentId": paymentId
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/pay_with_card") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: paymentData) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false
                if let error = error {
                    model.paymentStatus = "Card payment failed: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    model.paymentStatus = "Card payment failed: Invalid server response."
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if let status = json["status"] as? String, status == "completed" {
                        model.paymentStatus = "Payment Successful!"
                        CoreDataHelper.savePaymentToCoreData(paymentId: paymentId, orderId: orderId, viewContext: viewContext, method: method)
                        onPaymentCompletion()
                    } else {
                        model.paymentStatus = "Card payment failed: \(json["message"] as? String ?? "Unknown error.")"
                    }
                } else {
                    model.paymentStatus = "Card payment failed: \(json["error"] as? String ?? json["message"] as? String ?? "Unknown error.")"
                }
            }
        }.resume()
    }
}

class CoreDataHelper {
    static func savePaymentToCoreData(paymentId: Int64, orderId: Int64, viewContext: NSManagedObjectContext, method: String) {
        let payment = Payment(context: viewContext)
        payment.id = paymentId
        payment.method = method
        payment.paymentDate = Date()
        payment.status = "completed"
        
        if let order = fetchOrderById(orderId: orderId, viewContext: viewContext) {
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
    
    static func getNextAvailableId(viewContext: NSManagedObjectContext) -> Int64 {
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
    
    static func fetchOrderById(orderId: Int64, viewContext: NSManagedObjectContext) -> Order? {
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

class MyBackendModel: ObservableObject {
    let backendCheckoutUrl = URL(string: "http://127.0.0.1:5000/payment-sheet")!
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var paymentStatus: String = ""
    
    private var viewContext: NSManagedObjectContext?
    private var orderId: Int64?
    
    func preparePaymentSheet(paymentId: Int64, orderId: Int64, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.orderId = orderId
        
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        
        var orderTotal: Double = 0.0
        if let order = CoreDataHelper.fetchOrderById(orderId: orderId, viewContext: viewContext) {
            orderTotal = order.totalPrice
        }
        
        let paymentData: [String: Any] = [
            "orderTotal": orderTotal
        ]
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: paymentData) else { return }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerId = json["customer"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String,
                  let self = self else {
                return
            }
            
            STPAPIClient.shared.publishableKey = publishableKey
            var configuration = PaymentSheet.Configuration()
            configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
            configuration.returnURL = "shopping-list://stripe-redirect"
            
            DispatchQueue.main.async {
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            }
        })
        task.resume()
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        DispatchQueue.main.async {
            self.paymentResult = result
            
            switch result {
            case .completed:
                guard let viewContext = self.viewContext else {
                    self.paymentStatus = "Error: View context not available."
                    return
                }
                let paymentId = CoreDataHelper.getNextAvailableId(viewContext: viewContext)
                let method = "stripe"
                let paymentData: [String: Any] = [
                    "orderId": self.orderId ?? 0,
                    "paymentDate": ISO8601DateFormatter().string(from: Date()),
                    "status": "pending",
                    "method": method,
                    "paymentId": paymentId
                ]
                
                guard let url = URL(string: "http://127.0.0.1:5000/pay_with_stripe") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                guard let httpBody = try? JSONSerialization.data(withJSONObject: paymentData) else { return }
                request.httpBody = httpBody
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.paymentStatus = "Stripe payment failed: \(error.localizedDescription)"
                            return
                        }
                        
                        guard let httpResponse = response as? HTTPURLResponse,
                              let data = data,
                              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            self.paymentStatus = "Stripe payment failed: Invalid server response."
                            return
                        }
                        
                        if httpResponse.statusCode == 200 {
                            if let status = json["status"] as? String, status == "completed" {
                                CoreDataHelper.savePaymentToCoreData(paymentId: paymentId, orderId: self.orderId!, viewContext: viewContext, method: method)
                                self.paymentStatus = "Payment Successful!"
                            } else {
                                self.paymentStatus = "Stripe payment failed: \(json["message"] as? String ?? "Unknown Error.")"
                            }
                        } else {
                            self.paymentStatus = "Stripe payment failed: \(json["error"] as? String ?? json["message"] as? String ?? "Unknown Error.")"
                        }
                    }
                }.resume()
            case .failed(let error):
                self.paymentStatus = "Stripe payment failed: \(error.localizedDescription)"
            case .canceled:
                self.paymentStatus = "Stripe payment canceled"
            }
        }
    }
}
