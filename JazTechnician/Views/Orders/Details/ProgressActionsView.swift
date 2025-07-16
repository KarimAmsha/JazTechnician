//
//  ProgressActionsView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct ProgressActionsView: View {
    @ObservedObject var viewModel: OrderViewModel
    let orderID: String
    @Binding var newExtraServices: [SubCategory]
    @Binding var showError: Bool
    @Binding var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            if !newExtraServices.isEmpty {
                Button("حفظ الخدمات الإضافية") {
                    let ids = newExtraServices.compactMap { $0.id }
                    viewModel.updateOrderStatus(orderId: orderID, status: "updated", extraServiceIDs: ids, onSuccess: {
                        viewModel.getOrderDetails(orderId: orderID) {}
                        newExtraServices.removeAll()
                    }, onError: { msg in
                        errorMessage = msg
                        showError = true
                    })
                }
                .buttonStyle(ActionButtonStyle(color: .primary()))
            }

            Button("إنهاء الطلب ✅") {
                viewModel.updateOrderStatus(orderId: orderID, status: "prefinished", onSuccess: {
                    viewModel.getOrderDetails(orderId: orderID) {}
                }, onError: { msg in
                    errorMessage = msg
                    showError = true
                })
            }
            .buttonStyle(ActionButtonStyle(color: .successNormal()))
        }
    }
}

