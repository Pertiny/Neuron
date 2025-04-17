import SwiftUI

struct SettingsContainerView: View {
    @EnvironmentObject private var navigationModel: NavigationModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .classic
    
    @State private var selectedTab = 0
    
    var body: some View {
        let theme = selectedTheme
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Einstellungen")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Balance-Element für die Zentrierung
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, UIApplication.shared.firstSafeAreaTop + 16)
                .padding(.bottom, 16)
                
                // MARK: - Tab Selector
                HStack(spacing: 0) {
                    ForEach(["Allgemein", "Chat", "API"], id: \.self) { tab in
                        Button {
                            withAnimation {
                                selectedTab = ["Allgemein", "Chat", "API"].firstIndex(of: tab) ?? 0
                            }
                        } label: {
                            Text(tab)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(getTabTextColor(for: tab))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(getTabBackground(for: tab))
                        }
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                
                // MARK: - Content
                TabView(selection: $selectedTab) {
                    GeneralSettingsView()
                        .tag(0)
                    
                    ChatSettingsView()
                        .tag(1)
                    
                    APISettingsView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getTabTextColor(for tab: String) -> Color {
        let index = ["Allgemein", "Chat", "API"].firstIndex(of: tab) ?? 0
        return selectedTab == index ? .white : .gray
    }
    
    private func getTabBackground(for tab: String) -> Color {
        let index = ["Allgemein", "Chat", "API"].firstIndex(of: tab) ?? 0
        return selectedTab == index ? Color.gray.opacity(0.4) : .clear
    }
}
