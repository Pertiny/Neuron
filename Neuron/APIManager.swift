import Foundation
import Combine

class APIManager: ObservableObject {
    @Published var consumedTokens: Int = 0
    @Published var totalCost: Double = 0.0
    
    private let costPer1000TokensEuro: Double = 0.0015
    
    /// Durch die "= 1000" und "= 0.7" ist es möglich,
    /// die Parameter wegzulassen, wenn man sie nicht explizit setzen will.
    func sendRequest(
        prompt: String,
        apiKey: String,
        maxTokens: Int = 1000,      // <-- Default-Wert
        temperature: Double = 0.7,  // <-- Default-Wert
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens,
            "temperature": temperature
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if
                        let usage = json["usage"] as? [String: Any],
                        let totalTokens = usage["total_tokens"] as? Int
                    {
                        DispatchQueue.main.async {
                            self.consumedTokens += totalTokens
                            let newCost = (Double(totalTokens) / 1000.0) * self.costPer1000TokensEuro
                            self.totalCost += newCost
                        }
                    }
                    
                    if
                        let choices = json["choices"] as? [[String: Any]],
                        let firstChoice = choices.first,
                        let message = firstChoice["message"] as? [String: Any],
                        let content = message["content"] as? String
                    {
                        completion(content)
                        return
                    }
                }
                completion(nil)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
