//
//  StartedActionsView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct StartedActionsView: View {
    @ObservedObject var viewModel: OrderViewModel
    let orderID: String
    @Binding var showError: Bool
    @Binding var errorMessage: String?

    var body: some View {
        Button("الطلب قيد التنفيذ ⏳") {
            viewModel.updateOrderStatus(orderId: orderID, status: "progress", onSuccess: {
                viewModel.getOrderDetails(orderId: orderID) {}
            }, onError: { msg in
                errorMessage = msg
                showError = true
            })
        }
        .buttonStyle(ActionButtonStyle(color: .primary()))
    }
}

