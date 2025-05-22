//
//  PaymentCheckoutView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 22.05.2025.
//

//
//  PaymentCheckoutView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 22.05.2025.
//

import SwiftUI
import CoreLocation

struct PaymentCheckoutView: View {
    let orderData: OrderData

    @EnvironmentObject var appRouter: AppRouter
    @State private var couponCode: String = ""
    @State private var discountValue: Double = 0
    @State private var selectedPaymentMethod: PaymentMethodType? = nil
    @State private var couponMessage: String? = nil

    // اختصارات للبيانات المطلوبة
    var services: [SelectedServiceItem] { orderData.services }
    var address: AddressItem? { orderData.address }
    var userLocation: CLLocationCoordinate2D? { orderData.userLocation }
    var notes: String { orderData.notes }

    var totalBeforeDiscount: Double {
        services.reduce(0) { $0 + ($1.item.price * Double($1.quantity)) }
    }

    var taxAmount: Double {
        totalBeforeDiscount * 0.15
    }

    var totalAmount: Double {
        max(0, totalBeforeDiscount - discountValue + taxAmount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("الدفع")
                    .customFont(weight: .bold, size: 20)

                Text("اختر طريقة الدفع المناسبة لك")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                // كوبون الخصم
                couponSection

                Divider().padding(.vertical, 4)

                // ملخص الفاتورة
                summarySection

                Divider().padding(.vertical, 4)

                // طرق الدفع
                paymentSection

                Divider().padding(.vertical, 4)

                // ملخص المبلغ وزر الدفع
                payBar
            }
            .padding()
        }
        .navigationTitle("الدفع")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Coupon Section
    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("كوبون الخصم", text: $couponCode)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 48)
                Button("فحص") { checkCoupon() }
                    .frame(width: 80, height: 48)
                    .background(Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            if let message = couponMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(discountValue > 0 ? .green : .red)
            }
        }
    }

    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("البيانات المالية")
                .font(.headline)
            financialRow(title: "المبلغ قبل الضريبة", value: totalBeforeDiscount)
            financialRow(title: "قيمة الخصم", value: discountValue)
            financialRow(title: "مبلغ الضريبة", value: taxAmount)
            financialRow(title: "المبلغ الاجمالي", value: totalAmount, isBold: true)
        }
    }

    // MARK: - Payment Section
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("طريقة الدفع")
                .font(.headline)
            Text("الاسعار لا تشمل قطع الغيار!")
                .font(.footnote)
                .foregroundColor(.gray)

            ForEach(PaymentMethodType.allCases, id: \.self) { method in
                paymentOption(icon: method.rawValue, title: method.displayName, method: method)
            }
        }
    }

    // MARK: - Bottom Bar
    private var payBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("المجموع")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(totalAmount, specifier: "%.2f") SAR")
                    .fontWeight(.bold)
            }

            Button(action: payNow) {
                Text("ادفع الان")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.top)
    }

    // MARK: - Components

    func financialRow(title: String, value: Double, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            Spacer()
            Text("\(value, specifier: "%.2f") SAR")
                .font(.subheadline)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(isBold ? .black : .primary)
        }
        .padding(.vertical, 4)
    }

    func paymentOption(icon: String, title: String, method: PaymentMethodType) -> some View {
        Button(action: {
            selectedPaymentMethod = method
        }) {
            HStack {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(title)
                    .padding(.leading, 8)
                Spacer()
                if selectedPaymentMethod == method {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Logic

    func checkCoupon() {
        // Example only - replace with real API call
        if couponCode.lowercased() == "karim" {
            discountValue = 20
            couponMessage = "تم تطبيق الخصم بنجاح"
        } else {
            discountValue = 0
            couponMessage = "الكوبون غير صالح"
        }
    }

    func payNow() {
        // تنفيذ منطق الدفع أو التنقل للشاشة التالية هنا
        // orderData, selectedPaymentMethod, discountValue, ... متوفرين للاستخدام
    }
}

enum PaymentMethodType: String, CaseIterable, Hashable {
    case mada, wallet, tamara

    var displayName: String {
        switch self {
        case .mada: return "مدى"
        case .wallet: return "المحفظة"
        case .tamara: return "تمارا"
        }
    }
}

#Preview {
    PaymentCheckoutView(
        orderData: OrderData(
            services: [],
            address: nil,
            userLocation: nil,
            notes: ""
        )
    )
    .environmentObject(AppRouter())
}
