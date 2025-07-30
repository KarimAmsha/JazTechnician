//
//  OrderStatusButton.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct OrderStatusButton: View {
    let title: String
    let status: OrderStatus
    @Binding var selectedStatus: OrderStatus
    
    var body: some View {
        Button(action: {
            selectedStatus = status
        }) {
            Text(title)
                .customFont(weight: .medium, size: 15)
                .foregroundColor(selectedStatus == status ? .white : .primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(selectedStatus == status ? Color.blue068DA9() : Color(.systemGray5))
                .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
