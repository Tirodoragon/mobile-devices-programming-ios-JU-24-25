//
//  LoginView.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/19/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FacebookLogin

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
                
                Button(action: loginWithFacebook) {
                    Text("Log in with Facebook")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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
                   let userId = json["userId"] as? String {
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
            let googleUserId = user.userID ?? "0"
            let token = user.accessToken.tokenString
            
            let loginData: [String: Any] = [
                "username": email,
                "oauth_id": googleUserId,
                "token": token
            ]
            sendLoginRequest(data: loginData)
            
            DispatchQueue.main.async {
                userSession.userId = googleUserId
                userSession.username = email
            }
        }
    }
    
    private func loginWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
            if let error = error {
                errorMessage = "Facebook login failed: \(error.localizedDescription)"
                return
            }
            
            guard let result = result, !result.isCancelled else {
                errorMessage = "Facebook login was cancelled."
                return
            }
            
            if let token = result.token?.tokenString {
                let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"], tokenString: token, version: nil, httpMethod: .get)
                request.start { _, response, error in
                    if let error = error {
                        errorMessage = "Failed to fetch Facebook user data: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let userInfo = response as? [String: Any] else {
                        errorMessage = "Failed to parse Facebook user data."
                        return
                    }
                    
                    let email = userInfo["email"] as? String ?? "Unknown Email"
                    let facebookUserId = userInfo["id"] as? String ?? "Unknown ID"
                    
                    let loginData: [String: Any] = [
                        "username": email,
                        "oauth_id": facebookUserId,
                        "token": token
                    ]
                    sendLoginRequest(data: loginData)
                    
                    DispatchQueue.main.async {
                        userSession.userId = facebookUserId
                        userSession.username = email
                    }
                }
            }
        }
    }
    
    private func sendLoginRequest(data: [String: Any]) {
        guard let url = URL(string: "http://127.0.0.1:5000/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: data) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { responseData, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to connect to the server: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid server response."
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    guard let responseData = responseData else {
                        errorMessage = "No data received from server."
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                            if let userId = json["userId"] as? String {
                                userSession.userId = userId
                            }
                            userSession.username = json["username"] as? String ?? "Unknown"
                            errorMessage = ""	
                        } else {
                            errorMessage = "Failed to parse server response."
                        }
                    } catch {
                        errorMessage = "JSON decoding error: \(error.localizedDescription)"
                    }
                } else if httpResponse.statusCode == 409 {
                    errorMessage = "User already exists (for registration scenarios)."
                } else {
                    errorMessage = "Login failed. Server responded with code: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
}
