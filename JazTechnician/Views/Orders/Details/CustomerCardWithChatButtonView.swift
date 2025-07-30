//
//  CustomerCardWithChatButtonView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 16.07.2025.
//

import SwiftUI

struct CustomerCardWithChatButtonView: View {
    let customer: User
    let orderStatus: OrderStatus
    let onChat: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                // صورة العميل
                if let urlString = customer.image, let url = URL(string: urlString) {
                    AsyncImage(url: url) { img in
                        img.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.grayA1A1A1())
                    }
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.grayA1A1A1())
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                // معلومات العميل
                VStack(alignment: .leading, spacing: 4) {
                    Text(customer.full_name ?? "العميل")
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.primaryDark())
                    if let phone = customer.phone_number {
                        Text(phone)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.grayA1A1A1())
                    }
                    if let rate = customer.rate {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellowFFB020())
                                .font(.system(size: 13))
                            Text(String(format: "%.1f", rate))
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.grayA1A1A1())
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary().opacity(0.10), lineWidth: 1)
            )

            // زر المحادثة إذا كانت حالة الطلب تسمح
            if [.accepted, .way, .started, .finished].contains(orderStatus) {
                Button(action: onChat) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("محادثة مع العميل")
                            .customFont(weight: .medium, size: 14)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary())
                    .background(Color.primaryLight())
                    .cornerRadius(14)
                }
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
        .transition(.opacity)
    }
}
