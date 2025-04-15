import SwiftUI

struct ContentView: View {
    @StateObject private var apiManager = APIManager()
    @AppStorage("apiKey") private var apiKey: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Neuron")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("Minimalistischer GPT-Client")
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API-Key")
                            .foregroundColor(.white)
                        
                        TextField("Gib hier deinen ChatGPT-API-Key ein", text: $apiKey)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                    }
                    
                    Text("Verbrauchte Tokens: \(apiManager.consumedTokens)")
                        .foregroundColor(.white)
                    
                    let costString = String(format: "%.2f", apiManager.totalCost)
                        .replacingOccurrences(of: ".", with: ",")
                    Text("Aktuelle Kosten: \(costString) €")
                        .foregroundColor(.white)
                    
                    Button(action: {
                        apiManager.sendRequest(
                            prompt: "Hallo, wie geht's?",
                            apiKey: apiKey
                        ) { response in
                            print("Antwort: \(response ?? "Keine Antwort")")
                        }
                    }) {
                        Text("Testanfrage senden")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    NavigationLink(destination: HistoryView()) {
                        Text("History")
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
