//
//  RetailPaymentView.swift
//  Wishy
//
//  Created by Karim Amsha on 1.05.2024.
//

import SwiftUI
import goSellSDK
import TamaraSDK

struct RetailPaymentView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State var total = ""
    @ObservedObject var wishesViewModel = WishesViewModel(errorHandling: ErrorHandling())
    let wishId: String?
    @StateObject private var paymentViewModel = PaymentViewModel()
    @State private var payMada: Bool = true
    @State private var payTamara: Bool = false
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var showTamaraPayment = false
    @State private var checkoutUrl = ""

    var body: some View {
        VStack {
            Image("ic_money")
                .padding(.top, 80)
            
            PaymentOptionsSection(payMada: $payMada, payTamara: $payTamara)
                .padding(.bottom, 16)

            Text("اكتب القيمة بالريال السعودي")
                .customFont(weight: .bold, size: 16)
                .foregroundColor(.primaryBlack())
            
            VStack(alignment: .leading) {
                TextField(LocalizedStringKey.sar, text: $total)
                    .placeholder(when: total.isEmpty) {
                        Text(LocalizedStringKey.sar)
                            .foregroundColor(.gray999999())
                    }
                    .customFont(weight: .regular, size: 14)
                    .keyboardType(.numberPad)
                    .accentColor(.primary())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .underline()
                    .roundedBackground(cornerRadius: 12, strokeColor: .gray898989(), lineWidth: 1)
            }
            .foregroundColor(.black222020())

            Spacer()
            
            if orderViewModel.isLoading {
                LoadingView()
            }

            Button {
                if total.isEmpty {
                    wishesViewModel.errorMessage = "ادخل قيمة للاستمرار بالدفع!"
                    return
                }

                let amount = total.toDouble() ?? 0.0

                if payMada {
                    startPayment(amount: amount)
                } else if payTamara {
                    startTamaraCheckout(amount: amount)
                }
            } label: {
                Text("الاستمرار للدفع")
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            .padding(.horizontal, 16)
            .disabled(orderViewModel.isLoading)
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text("ساهم الان بـ قَطّة!")
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onChange(of: wishesViewModel.errorMessage) { errorMessage in
            if let errorMessage = errorMessage {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: paymentViewModel.errorMessage) { errorMessage in
            if !errorMessage.isEmpty {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: paymentViewModel.paymentSuccess) { paymentSuccess in
            if paymentSuccess {
                payWish()
            }
        }
        .fullScreenCover(isPresented: $showTamaraPayment) {
            let merchantURL = TamaraMerchantURL(
                success: "tamara://checkout/success",
                failure: "tamara://checkout/failure",
                cancel: "tamara://checkout/cancel",
                notification: "tamara://checkout/notification"
            )

            let tamaraViewModel = TamaraSDKCheckoutSwiftUIViewModel(
                url: checkoutUrl,
                merchantURL: merchantURL
            )

            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button {
                            showTamaraPayment = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color.gray)
                                .padding(10)
                        }
                    }
                    .padding()
                    Divider()
                }

                TamaraSDKCheckoutSwiftUI(tamaraViewModel)
                    .onReceive(tamaraViewModel.$successDirection) { _ in
                        showTamaraPayment = false
                        payWish()
                    }
                    .onReceive(tamaraViewModel.$failedDirection) { _ in
                        showTamaraPayment = false
                    }
                    .onReceive(tamaraViewModel.$finishLoadingHandler) { _ in }
            }
        }
        .onAppear {
            GoSellSDK.mode = .production
        }
    }

    func payWish() {
        let params: [String: Any] = [
            "total": total
        ]
        wishesViewModel.payWish(id: wishId ?? "", params: params) {
            appRouter.navigate(to: .paymentSuccess)
        }
    }

    func startPayment(amount: Double) {
        paymentViewModel.updateAmount(amount.toString())
        paymentViewModel.startPayment()
    }

    func startTamaraCheckout(amount: Double) {
        let tamaraBody = TamaraBody(
            amount: amount,
            products: [
                TamaraProduct(
                    product_id: wishId ?? "",
                    variation_name: "",
                    variation_sku: "",
                    qty: 1
                )
            ]
        )
        
        orderViewModel.tamaraCheckout(params: tamaraBody) {
            self.checkoutUrl = orderViewModel.tamaraCheckout?.checkout_url ?? ""
            showTamaraPayment.toggle()
        }
    }
}

struct PaymentOptionsSection: View {
    @Binding var payMada: Bool
    @Binding var payTamara: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("اختر طريقة الدفع")
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            HStack(spacing: 20) {
                RetailCheckboxButton(title: "مدى", isChecked: $payMada, other: $payTamara)
                RetailCheckboxButton(title: "تمارا", isChecked: $payTamara, other: $payMada)
            }
        }
    }
}

struct RetailCheckboxButton: View {
    let title: String
    @Binding var isChecked: Bool
    @Binding var other: Bool

    var body: some View {
        Button {
            if !isChecked {
                isChecked = true
                other = false
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isChecked ? .primary() : .gray595959())
                Text(title)
                    .foregroundColor(.black121212())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
