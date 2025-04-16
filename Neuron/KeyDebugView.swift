import SwiftUI

struct KeyDebugView: View {
    @State private var result: String = "Noch nicht getestet."
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("openAIOrgID") private var orgID: String = ""

    @StateObject private var apiManager = APIManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("API-Key Debug")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Button("Key testen") {
                    result = "⏳ Test läuft..."

                    apiManager.validateKey(apiKey, debug: true) { success in
                        result += "\n\n✅ Ergebnis: \(success ? "GÜLTIG" : "UNGÜLTIG")"
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 8)

                Text(result)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)

                Spacer()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}