//
//  OrderNewTotalsTableView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct OrderNewTotalsTableView: View {
    let order: OrderBody

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("المجاميع الجديدة (بعد التحديث/التعديل)")
                .customFont(weight: .medium, size: 13)
                .foregroundColor(.purple)
                .padding(.bottom, 4)
            if let newTax = order.new_tax {
                row("الضريبة الجديدة:", String(format: "%.2f ر.س", newTax))
            }
            if let newTotal = order.new_total {
                row("الإجمالي الجديد:", String(format: "%.2f ر.س", newTotal), .purple, true)
            }
        }
        .padding()
        .background(Color.backgroundFEF3DE())
        .cornerRadius(12)
        .padding(.top, 12)
    }

    private func row(_ title: String, _ value: String, _ color: Color = .primaryDark(), _ bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.primaryDark())
            Spacer()
            Text(value)
                .customFont(weight: bold ? .semiBold : .medium, size: 13)
                .foregroundColor(color)
        }
    }
}

