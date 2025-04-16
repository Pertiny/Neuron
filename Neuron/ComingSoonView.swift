//
//  ComingSoonView.swift
//  Neuron
//
//  Created by Jacques Zimmer on 16.04.25.
//


import SwiftUI

struct ComingSoonView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("\(title) – Coming Soon")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Text("<")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }
        }
    }
}