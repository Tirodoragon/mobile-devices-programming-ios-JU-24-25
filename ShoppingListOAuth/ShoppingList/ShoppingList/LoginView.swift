//
//  LoginView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/18/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var navigateToRegister: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if isLoading {
                    ProgressView()
                } else {
                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                GoogleSignInButton {
                    handleGoogleSignIn()
                }
                .frame(height: 50)
                .padding(.horizontal)

                Button(action: {
                    navigateToRegister = true
                }) {
                    Text("Don't have an account? Register here")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
            }
        }
    }

    private func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required."
            return
        }

        isLoading = true
        errorMessage = ""

        let url = URL(string: "http://127.0.0.1:5000/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: Any] = ["username": username, "password": password]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: loginData) else {
            errorMessage = "Failed to encode login data."
            isLoading = false
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Failed to connect to the server: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Invalid username or password."
                    return
                }

                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userId = json["userId"] as? Int {
                    userSession.userId = userId
                    userSession.username = username
                } else {
                    errorMessage = "Failed to parse server response."
                }
            }
        }.resume()
    }

    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                return
            }

            guard let signInResult = signInResult else {
                errorMessage = "Google Sign-In failed: No result."
                return
            }

            let user = signInResult.user
            let email = user.profile?.email ?? "Unknown Email"
            userSession.userId = Int.random(in: 1000...9999)
            userSession.username = email
            userSession.isGoogleUser = true
        }
    }
}
