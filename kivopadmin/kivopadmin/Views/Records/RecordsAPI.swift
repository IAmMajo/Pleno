// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



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
