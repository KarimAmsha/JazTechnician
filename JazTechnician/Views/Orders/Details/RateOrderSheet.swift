//
//  RateOrderSheet.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct RateOrderSheet: View {
    let orderId: String
    var onRate: (Int, String) -> Void
    var onCancel: () -> Void

    @State private var rating: Int = 5
    @State private var comment: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 22) {
                Text("قيّم الطلب")
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.primaryDark())
                    .padding(.top, 10)

                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(star <= rating ? .yellowFFB020() : .grayDCDCDC())
                            .font(.system(size: 32))
                            .onTapGesture { rating = star }
                    }
                }

                ZStack(alignment: .topLeading) {
                    if comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("أضف تعليقًا (اختياري)")
                            .customFont(weight: .regular, size: 13)
                            .foregroundColor(.grayA1A1A1())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    TextEditor(text: $comment)
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                        .frame(minHeight: 70, maxHeight: 100)
                        .padding(4)
                        .background(Color.grayF5F5F5())
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.grayEFEFEF(), lineWidth: 1)
                        )
                }

                HStack(spacing: 14) {
                    Button("إلغاء", action: onCancel)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.dangerNormal())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dangerLight())
                        .cornerRadius(10)

                    Button("إرسال التقييم") {
                        onRate(rating, comment)
                    }
                    .customFont(weight: .medium, size: 15)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.successNormal())
                    .cornerRadius(10)
                }
                .padding(.bottom, 6)
                Spacer(minLength: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .navigationBarHidden(true)
        }
    }
}

