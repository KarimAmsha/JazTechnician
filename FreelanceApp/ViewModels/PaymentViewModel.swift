//
//  PaymentViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI
import goSellSDK

class PaymentViewModel: NSObject, ObservableObject {
    @Published var myAmount: Decimal = 100.0
    @Published var transactionMode: TransactionMode = .purchase
    let settings = UserSettings.shared
    @Published var paymentSuccess: Bool = false
    @Published var errorMessage: String = ""
    var applePay = false
    var applePayUI = false

    var applePayMerchantID: String
    {
        return "merchant.wishy.sa.com"
    }
    
//    var merchantID: String?
//    {
//        return "35263831"
//    }

    func startPayment() {
        let session = Session()
        session.dataSource = self
        session.delegate = self
//        applePay = true
//        applePayUI = false
        do {
//            try session.startApplePay()
            try session.start()
        } catch {
            // Handle the error appropriately
            print("Error starting payment session: \(error)")
        }
    }
    
    // Function to update the amount based on user input
    func updateAmount(_ newAmount: String) {
        if let decimalAmount = Decimal(string: newAmount) {
            myAmount = decimalAmount
        } else {
            print("Invalid amount format")
        }
    }
    
    func updatePaymentSuccess(paymentSuccess: Bool, paymentError: String) {
        DispatchQueue.main.async {
            self.paymentSuccess = paymentSuccess
            if !paymentError.isEmpty {
                self.errorMessage = paymentError.localized
            }
        }
    }

    func notifyPaymentStatus() {
        DispatchQueue.main.async {
            self.updatePaymentSuccess(paymentSuccess: self.paymentSuccess, paymentError: self.errorMessage)
        }
    }
}

extension PaymentViewModel: SessionDataSource {
    var amount: Decimal {
        return self.myAmount
    }

    var currency: goSellSDK.Currency? {
        do {
            return try goSellSDK.Currency(isoCode: "SAR")
        } catch {
            // Handle the error appropriately
            print("Error creating currency object: \(error)")
            return nil
        }
    }

    var customer: goSellSDK.Customer? {
        // Replace with actual customer details
//        let customerIdentifier = settings.id ?? ""
        do {
            let emailAddressCopy = try EmailAddress(emailAddressString: settings.user?.email ?? "")
            let phoneNumberCopy = try PhoneNumber(isdNumber: "+966", phoneNumber: settings.user?.phone_number ?? "")

            return try goSellSDK.Customer(
                emailAddress: emailAddressCopy,
                phoneNumber: phoneNumberCopy,
                firstName: settings.user?.full_name ?? "",
                middleName: settings.user?.full_name ?? "",
                lastName: settings.user?.full_name ?? ""
            )
        } catch {
            // Handle the error appropriately
            print("Error creating customer object: \(error)")
            return nil
        }
    }

    var mode: TransactionMode {
        return self.transactionMode
    }
}

extension PaymentViewModel: SessionDelegate {
    func paymentSucceed(_ charge: goSellSDK.Charge, on session: SessionProtocol) {
        // Handle successful payment
        handlePaymentSuccess()
    }

    func paymentFailed(with charge: goSellSDK.Charge?, error: TapSDKError?, on session: SessionProtocol) {
        // Handle payment failure
        handlePaymentError(error: error)
    }

    func sessionCancelled(_ session: SessionProtocol) {
        // Handle payment cancellation
        print("Payment Cancelled")
    }
    
    func handlePaymentSuccess() {
        print("Payment Succeed")
        self.paymentSuccess = true
        self.errorMessage = ""
        notifyPaymentStatus()
    }

    func handlePaymentError(error: TapSDKError?) {
        self.paymentSuccess = false
        self.errorMessage = error?.localizedDescription ?? ""
        print("Payment Failed: \(error?.localizedDescription ?? "")")
        notifyPaymentStatus()
    }
}
