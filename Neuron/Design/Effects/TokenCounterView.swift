//
//  TokenCounterView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI

struct TokenCounterView: View {
    let currentTokens: Int
    let maxTokens: Int
    let percent: CGFloat
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var tokenColor: Color {
        if percent < 0.5 {
            return .green
        } else if percent < 0.8 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Progress-Indicator
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(tokenColor)
                    .frame(width: max(2, percent * UIScreen.main.bounds.width * 0.8), height: 4)
                    .cornerRadius(2)
            }
            
            // Token-Zähler
            HStack {
                Text("\(currentTokens) / \(maxTokens) tokens")
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Spacer()
                
                Text(formattedPercentage)
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundColor(tokenColor)
            }
        }
        .padding(.top, 4)
        .animation(.easeIn(duration: 0.3), value: percent)
    }
    
    private var formattedPercentage: String {
        let percentage = Int(percent * 100)
        return "\(percentage)%"
    }
}

extension View {
    func tokenCounter(currentTokens: Int, maxTokens: Int, percent: CGFloat) -> some View {
        overlay(
            TokenCounterView(
                currentTokens: currentTokens,
                maxTokens: maxTokens,
                percent: percent
            )
            .padding(),
            alignment: .bottom
        )
    }
}

struct TokenCounterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TokenCounterView(currentTokens: 250, maxTokens: 4096, percent: 0.1)
            TokenCounterView(currentTokens: 1500, maxTokens: 4096, percent: 0.35)
            TokenCounterView(currentTokens: 3000, maxTokens: 4096, percent: 0.75)
            TokenCounterView(currentTokens: 4000, maxTokens: 4096, percent: 0.95)
        }
        .padding()
        .environmentObject(ThemeManager())
    }
}
