//
//  ConfirmationCodeSection.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct ConfirmationCodeSection: View {
    let order: OrderBody
    @ObservedObject var viewModel: OrderViewModel
    let orderID: String

    @State private var confirmationCode = ""
    @Binding var errorMessage: String?
    @Binding var showError: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("أدخل كود التأكيد")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())

            HStack {
                TextField("الكود", text: $confirmationCode)
                    .keyboardType(.numberPad)
                    .customFont(weight: .medium, size: 15)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.grayF5F5F5())
                    .cornerRadius(8)

                Button("تأكيد الكود") {
                    // هنا ينفذ تحقق الكود مع الباك اند
                    viewModel.confirmUpdateCode(orderId: orderID, code: confirmationCode, onSuccess: {
                        viewModel.getOrderDetails(orderId: orderID) {}
                    }, onError: { msg in
                        errorMessage = msg
                        showError = true
                    })
                }
                .disabled(confirmationCode.isEmpty)
                .buttonStyle(ActionButtonStyle(color: .successNormal()))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 8)
    }
}

