//
//  OrderStatusStepperView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct OrderStatusStepperView: View {
    let status: OrderStatus

    var body: some View {
        let current = currentStep(for: status)
        VStack(alignment: .leading, spacing: 0) {
            Text("حالة الطلب")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            HStack(alignment: .center, spacing: 10) {
                // النقاط/الأعمدة
                VStack {
                    ForEach(OrderStep.allCases.indices, id: \.self) { i in
                        VStack(spacing: 0) {
                            Circle()
                                .fill(i <= current ? OrderStep.allCases[i].color : Color.grayE6E6E6())
                                .frame(width: 13, height: 13)
                            if i < OrderStep.allCases.count - 1 {
                                Rectangle()
                                    .fill(Color.grayEFEFEF())
                                    .frame(width: 2, height: 32)
                            }
                        }
                        .frame(width: 13)
                    }
                }
                // التكسيت والأيقونة
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(OrderStep.allCases.indices, id: \.self) { i in
                        let step = OrderStep.allCases[i]
                        let isActive = i <= current
                        HStack(spacing: 5) {
                            if isActive {
                                Text(step.emoji)
                                    .font(.system(size: 18))
                            } else {
                                Image(systemName: step.icon)
                                    .foregroundColor(.grayA1A1A1())
                            }
                            Text(step.label)
                                .customFont(weight: isActive ? .semiBold : .regular, size: 14)
                                .foregroundColor(isActive ? step.color : .grayA1A1A1())
                        }
                    }
                }
                .padding(.leading, 4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color.white)
            .cornerRadius(14)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color.white)
        .cornerRadius(14)
        .onAppear {
            print("sttttt \(status)")
        }
    }
}

