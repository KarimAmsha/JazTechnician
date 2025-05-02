//
//  AddBalanceView.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI
import goSellSDK

struct AddBalanceView: View {
    @State private var coupon = ""
    @State private var amount = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var showAddBalanceView: Bool
    var onsuccess: () -> Void
    @StateObject private var paymentState = PaymentState(errorHandling: ErrorHandling())
    @StateObject private var viewModel = PaymentViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())

    init(showAddBalanceView: Binding<Bool>, onsuccess: @escaping () -> Void) {
        _showAddBalanceView = showAddBalanceView
        self.onsuccess = onsuccess
    }

    var body: some View {
        VStack(spacing: 20) {
            
//            CustomTextFieldWithTitle(text: $coupon, placeholder: LocalizedStringKey.coupon, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
//                .disabled(paymentState.isLoading)
            
            CustomTextFieldWithTitle(text: $amount, placeholder: LocalizedStringKey.amount, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                .keyboardType(.numberPad)
                .disabled(paymentState.isLoading)

            if let errorMessage = paymentState.errorMessage {
                Text(errorMessage)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.redFF3F3F())
            }

            if paymentState.isLoading {
                LoadingView()
            }

//            VStack {
//                Button("Start Payment") {
//                    viewModel.startPayment()
//                }
//                .padding()
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .cornerRadius(10)
//
//                Spacer()
//            }
//            .padding()

            Button {
//                addBalance()
                checkCoupon()
            } label: {
                Text(LocalizedStringKey.send)
            }
            .buttonStyle(PrimaryButton(fontSize: 18, fontWeight: .bold, background: .primary(), foreground: .white, height: 48, radius: 12))
            .disabled(paymentState.isLoading)

            Spacer()
        }
        .padding()
        .navigationTitle(LocalizedStringKey.addAccount)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(LocalizedStringKey.error), message: Text(alertMessage), dismissButton: .default(Text(LocalizedStringKey.ok)))
        }
        .onAppear {
            GoSellSDK.mode = .production
        }
        .onChange(of: viewModel.errorMessage) { errorMessage in
            if !errorMessage.isEmpty {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: viewModel.paymentSuccess) { paymentSuccess in
            // Do something when payment is successful
            if paymentSuccess {
                addBalance()
            }
        }
    }
}

extension AddBalanceView {
    private func checkCoupon() {

        if coupon.isEmpty {
            guard !amount.isEmpty else {
                paymentState.errorMessage = LocalizedStringKey.addAccount
                return
            }
            startPayment(amount: amount.toDouble() ?? 0.0)
        } else {
            orderViewModel.checkCoupon(params: [:]) { [self] in
                if let finalTotal = orderViewModel.coupon?.final_total {
                    startPayment(amount: finalTotal)
                }
            }
        }
    }
    
    func startPayment(amount: Double) {
        viewModel.updateAmount(amount.toString())
        viewModel.startPayment()
    }
    
    func addBalance() {
        let params: [String: Any] = [
            "amount": coupon.isEmpty ? amount.toDouble() ?? 0.0 : paymentState.coupon?.final_total ?? 0.0,
            "coupon": coupon,
        ]
        
        paymentState.addBalanceToWallet(params: params) { message in
            showAddBalanceView = false
            self.onsuccess()
        }
    }
}

