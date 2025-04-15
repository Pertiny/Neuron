import SwiftUI

/// Ein eigener Slider, der nur einen weißen Track zeichnet, aber keinen Daumen.
/// Funktioniert ab iOS 15, rein per GeometryReader + DragGesture.
/// "value" liegt in "range" und springt in "step"-großen Schritten.
struct NoThumbSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var trackColor: Color = .white
    var backgroundColor: Color = Color.white.opacity(0.2)
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Hintergrund-Balken
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(height: geo.size.height)
                
                // Fortschrittsbalken
                RoundedRectangle(cornerRadius: 8)
                    .fill(trackColor)
                    .frame(
                        width: progressWidth(in: geo),
                        height: geo.size.height
                    )
            }
            .contentShape(Rectangle()) // Touch-Bereich
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let newValue = mappedValueFromDrag(drag, in: geo)
                        value = snapToStep(newValue)
                    }
            )
        }
    }
    
    // Breite des aktiven Track-Anteils
    private func progressWidth(in geo: GeometryProxy) -> CGFloat {
        let ratio = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
        return max(0, min(1, ratio)) * geo.size.width
    }
    
    // Wandelt die Drag-Position ins Range [lowerBound...upperBound]
    private func mappedValueFromDrag(_ drag: DragGesture.Value, in geo: GeometryProxy) -> Double {
        let xLocation = drag.location.x
        let sliderWidth = geo.size.width
        let percentage = max(0, min(1, xLocation / sliderWidth))
        
        let domain = range.upperBound - range.lowerBound
        let newValue = range.lowerBound + Double(percentage) * domain
        
        return newValue
    }
    
    // Rundet den Wert aufs nächstliegende Step (z. B. 0.1er Schritte)
    private func snapToStep(_ rawValue: Double) -> Double {
        let stepsCount = (rawValue / step).rounded()
        return stepsCount * step
    }
}
