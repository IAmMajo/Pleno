// This file is licensed under the MIT-0 License.

import SwiftUI
import MarkdownUI
import MeetingServiceDTOs
import Foundation

class RecordsAPI {
    static func extendRecord(content: String, lang: String, updateHandler: @escaping (String) -> Void) async {
        await fetchAIResponse(endpoint: "extend-record/" + lang, content: content, updateHandler: updateHandler)
    }
    
    static func generateSocialMediaPost(content: String, lang: String, updateHandler: @escaping (String) -> Void) async {
        await fetchAIResponse(endpoint: "generate-social-media-post/" + lang, content: content, updateHandler: updateHandler)
    }
    
    private static func fetchAIResponse(endpoint: String, content: String, updateHandler: @escaping @Sendable (String) -> Void) async {
        guard let url = URL(string: "https://kivop.ipv64.net/ai/" + endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: String] = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        do {
            let (stream, response) = try await URLSession.shared.bytes(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
            
            for try await line in stream.lines {
                DispatchQueue.main.async {
                    updateHandler(line) // Muss synchron bleiben
                }
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunde Verzögerung für bessere Lesbarkeit
            }
        } catch {
            DispatchQueue.main.async {
                updateHandler("Fehler: \(error.localizedDescription)")
            }
        }
    }
}
