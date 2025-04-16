import Foundation
import Combine

class APIManager: ObservableObject {
    @Published var consumedTokens: Int = 0
    @Published var totalCost: Double = 0.0

    private let costPer1000TokensEuro: Double = 0.0015
    private let network = NetworkMonitor.shared

    private var openAIOrgID: String {
        UserDefaults.standard.string(forKey: "openAIOrgID") ?? ""
    }

    // MARK: - GPT Anfrage
    func sendRequest(
        prompt: String,
        apiKey: String,
        maxTokens: Int = 1000,
        temperature: Double = 0.7,
        completion: @escaping (String?) -> Void
    ) {
        guard network.isConnected else {
            print("[x] Kein Internet – Anfrage abgebrochen.")
            completion("[Netzwerkfehler] Keine Verbindung.")
            return
        }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("[Systemfehler] Ungültige Anfrage-URL.")
            return
        }

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens,
            "temperature": temperature
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !openAIOrgID.isEmpty {
            request.setValue(openAIOrgID, forHTTPHeaderField: "OpenAI-Organization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion("[Systemfehler] Anfrage konnte nicht vorbereitet werden.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[!] Netzwerkfehler: \(error.localizedDescription)")
                    completion("[Systemfehler] Netzwerkfehler.")
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    completion("[Systemfehler] Ungültige Antwort.")
                    return
                }

                if let data = data {
                    let bodyString = String(data: data, encoding: .utf8) ?? "nil"
                    print("[i] Antwort (Status \(http.statusCode)):\n\(bodyString)")
                }

                switch http.statusCode {
                case 200:
                    break
                case 401:
                    completion("[Fehler] API-Key ungültig oder nicht freigegeben.")
                    return
                case 403:
                    completion("[Fehler] Zugriff auf Modell verweigert.")
                    return
                case 429:
                    completion("[Fehler] Zu viele Anfragen. Warte kurz.")
                    return
                default:
                    completion("[Fehler] HTTP \(http.statusCode)")
                    return
                }

                guard let data = data else {
                    completion("[Systemfehler] Keine Antwort.")
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let usage = json["usage"] as? [String: Any],
                       let totalTokens = usage["total_tokens"] as? Int {
                        self.consumedTokens += totalTokens
                        let cost = (Double(totalTokens) / 1000.0) * self.costPer1000TokensEuro
                        self.totalCost += cost
                    }

                    if let choices = json["choices"] as? [[String: Any]],
                       let first = choices.first,
                       let message = first["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        completion(content)
                        return
                    }

                    completion("[Systemfehler] Antwort unvollständig.")
                } else {
                    completion("[Systemfehler] Antwort unlesbar.")
                }
            }
        }.resume()
    }

    // MARK: - Key Validierung
    func validateKey(_ key: String, debug: Bool = false, completion: @escaping (Bool) -> Void) {
        guard network.isConnected else {
            print("[x] Kein Internet – Key-Test abgebrochen.")
            completion(false)
            return
        }

        if debug {
            print("[🔍] Starte Key-Debugging...")
            print("→ Key Prefix: \(key.prefix(20))...")
        }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            if debug { print("[x] Ungültige URL") }
            completion(false)
            return
        }

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": "Sag Hallo"]],
            "max_tokens": 1
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !openAIOrgID.isEmpty {
            request.setValue(openAIOrgID, forHTTPHeaderField: "OpenAI-Organization")
            if debug { print("→ Sende mit Org-ID: \(openAIOrgID)") }
        }
        request.timeoutInterval = 10

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            if debug { print("[x] JSON Fehler: \(error.localizedDescription)") }
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    if debug { print("[!] Netzwerkfehler: \(error.localizedDescription)") }
                    completion(false)
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    if debug { print("[x] Kein HTTP-Response.") }
                    completion(false)
                    return
                }

                if debug {
                    print("[i] Statuscode: \(http.statusCode)")
                    if let data = data {
                        let raw = String(data: data, encoding: .utf8) ?? "nil"
                        print("[i] Antwort:\n\(raw)")
                    }
                }

                completion(http.statusCode == 200)
            }
        }.resume()
    }

    // MARK: - Verfügbare Modelle
    func fetchAvailableModels(apiKey: String, completion: @escaping ([String]) -> Void) {
        guard network.isConnected else {
            print("[x] Kein Internet – Modellliste wird nicht geladen.")
            completion([])
            return
        }

        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard
                    error == nil,
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let modelList = json["data"] as? [[String: Any]]
                else {
                    print("[x] Modellabfrage fehlgeschlagen: \(error?.localizedDescription ?? "Unbekannt")")
                    completion([])
                    return
                }

                let ids = modelList.compactMap { $0["id"] as? String }
                    .filter { $0.contains("gpt") }
                    .sorted()

                print("[i] Verfügbare Modelle vom Server: \(ids)")
                completion(ids)
            }
        }.resume()
    }
}
