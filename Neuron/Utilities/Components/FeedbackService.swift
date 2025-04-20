//
//  FeedbackService.swift
//  Neuron
//
//  Created by Jacques Zimmer on 18.04.25.
//


import SwiftUI
import UIKit
import UIKit.UIFeedbackGenerator

/// Ein zentraler Service für verschiedene Arten von Feedback im gesamten App
final class FeedbackService {
    // Singleton-Instanz
    static let shared = FeedbackService()
    
    // Verhindert direkte Initialisierung außerhalb dieser Klasse
    private init() {}
    
    // MARK: - Haptic Feedback
    
    /// Erzeugt Feedback für Erfolg
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Erzeugt Feedback für Fehler
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Erzeugt Feedback für Warnung
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Erzeugt taktiles Feedback mit angegebener Intensität
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1.0) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Erweiterte Feedback-Optionen
    
    /// Erzeugt Feedback für einen Button-Tap
    func buttonTap() {
        impact(style: .light)
    }
    
    /// Erzeugt Feedback für das erfolgreiche Senden einer Nachricht
    func messageSent() {
        impact(style: .medium)
    }
    
    /// Erzeugt Feedback für eine erhaltene Antwort
    func messageReceived() {
        impact(style: .soft, intensity: 0.8)
    }
    
    /// Erzeugt Feedback für Löschaktionen
    func delete() {
        impact(style: .rigid)
    }
    
    /// Erzeugt Feedback für App-Statusänderungen (z.B. Theme-Wechsel)
    func stateChange() {
        impact(style: .soft, intensity: 0.5)
    }
    
    /// Erzeugt Feedback für das Kopieren in die Zwischenablage
    func copy() {
        impact(style: .light)
    }
    
    /// Erzeugt ein dezentes Feedback während der Texteingabe
    /// (sollte für Token-Counting während der Eingabe verwendet werden)
    func textChange() {
        impact(style: .soft, intensity: 0.2)
    }
    
    /// Erzeugt Muster-Feedback für besondere Interaktionen
    func specialPattern() {
        // Kurze Verzögerung zwischen Impulsen für erkennbares Muster
        DispatchQueue.main.async {
            self.impact(style: .rigid, intensity: 0.6)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(style: .rigid, intensity: 0.3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.impact(style: .rigid, intensity: 0.6)
                }
            }
        }
    }
}

// MARK: - SwiftUI-Erweiterungen

extension View {
    /// Fügt einer View ein standardisiertes Tap-Feedback hinzu
    func withFeedback(type: FeedbackType = .buttonTap, action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            switch type {
            case .buttonTap:
                FeedbackService.shared.buttonTap()
            case .success:
                FeedbackService.shared.success()
            case .error:
                FeedbackService.shared.error()
            case .warning:
                FeedbackService.shared.warning()
            case .delete:
                FeedbackService.shared.delete()
            case .copy:
                FeedbackService.shared.copy()
            case .custom(let style, let intensity):
                FeedbackService.shared.impact(style: style, intensity: intensity)
            }
            
            action()
        }
    }
    
    /// Fügt einer View beim Erscheinen ein Feedback hinzu
    func withAppearFeedback(type: FeedbackType = .buttonTap) -> some View {
        self.onAppear {
            switch type {
            case .buttonTap:
                FeedbackService.shared.buttonTap()
            case .success:
                FeedbackService.shared.success()
            case .error:
                FeedbackService.shared.error()
            case .warning:
                FeedbackService.shared.warning()
            case .delete:
                FeedbackService.shared.delete()
            case .copy:
                FeedbackService.shared.copy()
            case .custom(let style, let intensity):
                FeedbackService.shared.impact(style: style, intensity: intensity)
            }
        }
    }
}

enum FeedbackType {
    case buttonTap
    case success
    case error
    case warning
    case delete
    case copy
    case custom(UIImpactFeedbackGenerator.FeedbackStyle, CGFloat)
}
