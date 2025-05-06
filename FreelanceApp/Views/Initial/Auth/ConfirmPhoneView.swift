//
//  ConfirmPhoneView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct ConfirmPhoneView: View {
    @State private var code: [String] = ["", "", "", ""]
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(spacing: 24) {
            RegistrationStepHeader(
                title: "تأكيد رقم الهاتف",
                subtitle: "قم بإدخال رمز التفعيل المرسل الى رقم هاتفك"
            )

            Text("+970 594 0700 68")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(0..<4) { index in
                    TextField("", text: $code[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: index)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))
                        .onChange(of: code[index]) { newValue in
                            if newValue.count == 1 && index < 3 {
                                focusedField = index + 1
                            }
                        }
                }
            }

            HStack {
                Button("طلب رمز جديد") {}
                    .foregroundColor(Color.gray)
                Spacer()
                Text("0:59 لم تستلم رمزًا؟")
                    .foregroundColor(.gray)
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ConfirmPhoneView()
}
