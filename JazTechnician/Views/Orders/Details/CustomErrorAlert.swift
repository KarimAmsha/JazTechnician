//
//  CustomErrorAlert.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct CustomErrorAlert: View {
    let message: String
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
                .shadow(radius: 2)

            Text("حدث خطأ")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.red)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button(action: { onClose?() }) {
                Text("إغلاق")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(8)
                    .shadow(radius: 1)
            }
        }
        .padding(30)
        .background(.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.10), radius: 22, x: 0, y: 6)
        .frame(maxWidth: 320)
        .transition(.scale.combined(with: .opacity))
    }
}
