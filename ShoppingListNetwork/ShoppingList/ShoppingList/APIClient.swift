//
//  APIClient.swift
//  ShoppingList
//
//  Created by Tirodoragon on 1/15/25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://127.0.0.1:5000"
    
    private init() {}
    
    func fetchJSON(from endpoint: String, completion: @escaping (Result<[Dictionary<String, Any>], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, Any>] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func postJSON(to endpoint: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
