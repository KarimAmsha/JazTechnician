//
//  OrderItemView.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct OrderItemView: View {
    let item: Order  // استخدم Order بدل OrderModel حسب تعريفك الجديد
    var onSelect: (() -> Void)? = nil

    var body: some View {
        Button(action: { onSelect?() }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    // صورة المستخدم (مثلاً العميل أو الفني حسب التطبيق)
                    if let imageUrl = item.user?.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        // عنوان الطلب أو نوع الخدمة
                        Text(item.title ?? "خدمة")
                            .font(.headline)
                            .foregroundColor(.primary)

                        // اسم القسم أو الخدمة
                        if let category = item.category?.title {
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // الحالة وستيب الحالة
                        HStack(spacing: 6) {
                            Text(OrderStatus(item.status ?? "new").displayTitle)
                                .font(.footnote)
                                .foregroundColor(OrderStatus(item.status ?? "new") == .canceled ? .red : .blue)
                            Text("•")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text(OrderStatus(item.status ?? "new").stepText)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    // المبلغ الإجمالي أو السعر
                    if let total = item.total {
                        Text("\(total, specifier: "%.2f") SAR")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }

                // تاريخ الطلب
                if let dateString = item.createAt, !dateString.isEmpty {
                    Text(dateString.formattedString())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderItemView_Previews: PreviewProvider {
    static var previews: some View {
        // مثال لمستخدم/عميل
        let user = User(fromDictionary: [:])
                
        // مثال لطلب
        let exampleOrder = Order(
            id: "123456",
            price: 120,
            tax: 18,
            total: 138,
            address: nil,
            orderNo: "ORD-2024-001",
            status: "started",
            createAt: "2024-05-22T09:15:00+0300",
            category: nil,
            user: user,
            notes: "يرجى الاتصال قبل الوصول"
        )

        OrderItemView(item: exampleOrder)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.08))
    }
}
