//
//  AcceptedActionsView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//
import SwiftUI

struct AcceptedActionsView: View {
    @ObservedObject var viewModel: OrderViewModel
    let orderID: String
    @Binding var showCancelSheet: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            Button("بدء التوجه إلى العميل 🚗") {
                viewModel.updateOrderStatus(orderId: orderID, status: "way", onSuccess: {
                    viewModel.getOrderDetails(orderId: orderID) {}
                }, onError: { msg in
                    errorMessage = msg
                    showError = true
                })
            }
            .buttonStyle(ActionButtonStyle(color: .primary()))
            
            Button("إلغاء الطلب") {
                showCancelSheet = true
            }
            .buttonStyle(ActionButtonStyle(color: .dangerNormal()))
        }
    }
}
