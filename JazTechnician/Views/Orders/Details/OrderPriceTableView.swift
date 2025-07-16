//
//  OrderPriceTableView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct OrderPriceTableView: View {
    let order: OrderBody

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("تفاصيل الأسعار")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .padding(.bottom, 4)
            if let price = order.price {
                row("السعر الأساسي:", String(format: "%.2f ر.س", price))
            }
            if let tax = order.tax {
                row("الضريبة:", String(format: "%.2f ر.س", tax))
            }
            if let discount = order.totalDiscount, discount > 0 {
                row("الخصم:", String(format: "-%.2f ر.س", discount), .successNormal())
            }
            Divider()
            row(
                "الإجمالي النهائي:",
                String(format: "%.2f ر.س", order.netTotal ?? order.total ?? order.price ?? 0),
                .primary(),
                true
            )
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
