//
//  TerminalEffect.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//

import SwiftUI

struct TerminalEffectModifier: ViewModifier {
    @State private var animationPhase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    ZStack {
                        // Leichte CRT-Scanlines
                        VStack(spacing: 2) {
                            ForEach(0..<Int(geo.size.height/2), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.black.opacity(0.07))
                                    .frame(height: 1)
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 1)
                            }
                        }
                        
                        // Subtiler Bildschirm-Flimmer
                        Rectangle()
                            .fill(Color.white.opacity(0.01))
                            .opacity(sin(animationPhase) > 0.7 ? 0.015 : 0)
                            .blendMode(.overlay)
                        
                        // Leichtes Vignette-Effekt
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.15)
                            ]),
                            center: .center,
                            startRadius: geo.size.width * 0.35,
                            endRadius: geo.size.width * 0.8
                        )
                        .blendMode(.multiply)
                    }
                    .allowsHitTesting(false)
                }
            )
            .onAppear {
                // Animation für Bildschirm-Flimmer
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    animationPhase = .pi * 2
                }
            }
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.terminalGreen)
    }
}

struct TerminalTextEffect: ViewModifier {
    @State private var isVisible = false
    let speed: Double
    
    init(speed: Double = 0.05) {
        self.speed = speed
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: speed)) {
                    isVisible = true
                }
            }
    }
}

struct TypewriterText: View {
    let text: String
    let speed: Double
    
    @State private var displayedText = ""
    @State private var index: String.Index?
    
    init(_ text: String, speed: Double = 0.05) {
        self.text = text
        self.speed = speed
    }
    
    var body: some View {
        Text(displayedText)
            .font(.system(.body, design: .monospaced))
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        index = text.startIndex
        displayedText = ""
        
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            guard let currentIndex = index, currentIndex < text.endIndex else {
                timer.invalidate()
                return
            }
            
            displayedText += String(text[currentIndex])
            self.index = text.index(after: currentIndex)
        }
    }
}

// Bedingte Anwendung des Terminal-Effekts
struct ConditionalTerminalEffectModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if isEnabled {
            content.modifier(TerminalEffectModifier())
        } else {
            content
        }
    }
}

// Praktische View-Extension für Anwendung des Terminal-Effekts
extension View {
    func terminalEffect() -> some View {
        modifier(TerminalEffectModifier())
    }
    
    func terminalTextEffect(speed: Double = 0.05) -> some View {
        modifier(TerminalTextEffect(speed: speed))
    }
    
    func conditionalTerminalEffect(isEnabled: Bool) -> some View {
        modifier(ConditionalTerminalEffectModifier(isEnabled: isEnabled))
    }
}

// Beispielanwendung in Vorschau
struct TerminalEffect_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Terminal Effect")
                .padding()
            
            TypewriterText("This text appears as if typed...")
                .padding()
            
            Text("Instant text with fade effect")
                .terminalTextEffect()
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .terminalEffect()
    }
}
