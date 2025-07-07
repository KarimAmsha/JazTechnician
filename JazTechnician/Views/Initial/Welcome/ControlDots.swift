//
//  ControlDots.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct ControlDots: View {
    let numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Capsule()
                    .fill(page == currentPage ? Color.primary() : Color.gray999999())
                    .frame(width: 20, height: 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
    }
}
