//
//  DataPublisher.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/20/26.
//
import Foundation

class DataPublisher {
    let baseUrl = AppConfig.backendBaseURL
    var deviceToken: String?
    
    func post(_ jsonData: Data, to path: String) async throws {
        // build request, send, check response
        guard let url = URL(string: baseUrl + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // 3. Execute with Async/Await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        print("Status Code: \(httpResponse.statusCode)")
        print("Response: \(String(data: data, encoding: .utf8) ?? "")")
    }
}
