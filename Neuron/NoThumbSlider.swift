import SwiftUI

struct NoThumbSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * (value - range.lowerBound) / (range.upperBound - range.lowerBound))), height: 8)
                    .cornerRadius(4)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * (gesture.location.x / geometry.size.width)
                        value = round(max(range.lowerBound, min(range.upperBound, newValue)) / step) * step
                    }
            )
            .overlay(
                Text("\(value, specifier: step < 1 ? "%.2f" : "%.0f")")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 12),
                alignment: .top
            )
        }
    }
}
