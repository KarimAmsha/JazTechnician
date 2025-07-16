//
//  CancelOrderSheet.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct CancelOrderSheet: View {
    @Binding var note: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("سبب إلغاء الطلب")
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.dangerNormal())
                    .padding(.top, 10)

                ZStack(alignment: .topLeading) {
                    if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("اكتب سبب الإلغاء هنا...")
                            .customFont(weight: .regular, size: 13)
                            .foregroundColor(.grayA1A1A1())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    TextEditor(text: $note)
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                        .frame(minHeight: 90, maxHeight: 120)
                        .padding(4)
                        .background(Color.grayF5F5F5())
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.grayEFEFEF(), lineWidth: 1)
                        )
                }
                .padding(.top, 6)

                HStack(spacing: 14) {
                    Button("إلغاء", action: onCancel)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.primaryDark())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.grayEFEFEF())
                        .cornerRadius(10)

                    Button("تأكيد الإلغاء", action: onConfirm)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dangerNormal())
                        .cornerRadius(10)
                        .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding(.bottom, 6)

                Spacer(minLength: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .navigationBarHidden(true)
        }
    }
}
