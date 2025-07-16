//
//  ActionButtonStyle.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.13), value: configuration.isPressed)
    }
}
