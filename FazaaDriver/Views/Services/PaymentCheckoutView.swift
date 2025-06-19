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
import PopupView

enum PaymentResult {
    case success
    case failed(String)
    case cancelled
}

struct PaymentCheckoutView: View {
    let orderData: OrderData

    @EnvironmentObject var appRouter: AppRouter
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var couponCode: String = ""
    @State private var selectedPaymentType: PaymentType? = nil
    @State private var couponMessage: String? = nil
    @State private var isLoading = false
    @State private var loadingMessage: String? = nil
    @State private var showPaymentError = false
    var handleTamaraPaymentCompletion: ((PaymentResult) -> Void)? = nil
//    @StateObject private var paymentViewModel = PaymentViewModel()
    @State private var showTamaraPayment = false
    @State private var checkoutUrl = ""
    @State var tamaraViewModel: TamaraWebViewModel? = nil

    // استخراج القيم
    var services: [SelectedServiceItem] { orderData.services }
    var address: AddressItem? { orderData.address }
    var userLocation: CLLocationCoordinate2D? { orderData.userLocation }
    var notes: String { orderData.notes }

    // حساب القيم المالية
    var totalBeforeDiscount: Double {
        orderViewModel.coupon?.total_before_tax ?? services.reduce(0) { $0 + ($1.item.price * Double($1.quantity)) }
    }
    var discountValue: Double {
        orderViewModel.coupon?.discount ?? 0
    }
    var taxAmount: Double {
        orderViewModel.coupon?.total_tax ?? (totalBeforeDiscount * 0.15)
    }
    var totalAmount: Double {
        orderViewModel.coupon?.final_total ?? max(0, totalBeforeDiscount - discountValue + taxAmount)
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
        .navigationBarTitle("الدفع", displayMode: .inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("ic_back") // أو System Image حسب ما تستعمل
                    .onTapGesture {
                        appRouter.navigateBack()
                    }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            orderViewModel.isLoading ? AnyView(
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView(loadingMessage ?? "جاري التحميل...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            ) : AnyView(EmptyView())
        )
        .overlay(
            isLoading ? AnyView(
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView(loadingMessage ?? "جاري التحميل...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            ) : AnyView(EmptyView())
        )
        .popup(isPresented: $showPaymentError) {
            PaymentErrorPopup(
                message: orderViewModel.errorMessage ?? "حدث خطأ أثناء الدفع. حاول مرة أخرى.",
                onClose: { showPaymentError = false }
            )
            .padding(.horizontal, 20)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.48))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }

        .fullScreenCover(isPresented: $showTamaraPayment) {
            if let url = URL(string: checkoutUrl) {
                SafariView(url: url) { redirectedURL in
                    handleTamaraRedirect(url: redirectedURL)
                }
            }
        }
//        .onChange(of: paymentViewModel.paymentStatus) { status in
//            guard let status = status else { return }
//            isLoading = false
//
//            switch status {
//            case .success:
//                addOrder(paymentType: .online)
//            case .failed(let message):
//                orderViewModel.errorMessage = message
//                showPaymentError = true
//            case .cancelled:
//                orderViewModel.errorMessage = "تم إلغاء عملية الدفع"
//                showPaymentError = true
//            }
//        }
        .onAppear {
        }
    }

    // MARK: - Coupon Section
    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TextField("كوبون الخصم", text: $couponCode)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.gray.opacity(0.07))
                    .cornerRadius(10)
                    .font(.system(size: 16, weight: .medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.16), lineWidth: 1)
                    )

                Button(action: checkCoupon) {
                    Text("فحص")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(width: 80, height: 48)
                .background(Color.secondary())
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.secondary.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .frame(height: 48)
            .clipped()

            if let message = couponMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(discountValue > 0 ? .green : .red)
                    .padding(.top, 2)
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
    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("طريقة الدفع").font(.headline)
            Text("الأسعار لا تشمل قطع الغيار!").font(.footnote).foregroundColor(.gray)
            LazyVStack(spacing: 14) {
                ForEach(PaymentType.allCases) { method in
                    paymentCard(method: method)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func paymentCard(method: PaymentType) -> some View {
        let isSelected = selectedPaymentType == method

        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedPaymentType = method
            }
        }) {
            HStack(spacing: 16) {
                Image(method.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(.trailing, 2)

                VStack(alignment: .leading, spacing: 5) {
                    Text(method.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Text(method.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()
                
                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .transition(.scale)
                            .font(.system(size: 28))
                    }
                }
                .frame(width: 32, height: 32)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(method.cardColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.19), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.13) : Color.clear, radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
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
                Text("ادفع الآن")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPaymentType == nil ? Color.gray : Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selectedPaymentType == nil || isLoading)
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

    // MARK: - Logic

    func checkCoupon() {
        guard !couponCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            couponMessage = "يرجى إدخال كود الكوبون"
            return
        }
        loadingMessage = "جارٍ التحقق من الكوبون..."
        isLoading = true
        orderViewModel.checkCoupon(params: [
            "coupun": couponCode,
            "extra": services.map { ["sub_sub_id": $0.item._id, "qty": $0.quantity] }
        ]) {
            couponMessage = orderViewModel.coupon != nil ? "تم تطبيق الكوبون!" : "كوبون غير صالح"
            isLoading = false
        }
    }

    func payNow() {
        guard let paymentMethod = selectedPaymentType else { return }

        switch paymentMethod {
        case .wallet:
            addOrder(paymentType: .wallet)
        case .online:
//            startMadaPayment(amount: totalAmount)
            break
        case .tamara:
            startTamaraPayment(amount: totalAmount) { result in
                if case .success = result {
                    addOrder(paymentType: .tamara)
                } else if case .failed(let message) = result {
                    orderViewModel.errorMessage = message
                    showPaymentError = true
                } else if case .cancelled = result {
                    orderViewModel.errorMessage = "تم إلغاء عملية الدفع"
                    showPaymentError = true
                }
            }
        }
    }

//    func startMadaPayment(amount: Double) {
//        loadingMessage = "جارٍ معالجة الدفع..."
//        isLoading = true
//        paymentViewModel.updateAmount("\(amount)")
//        paymentViewModel.startPayment()
//    }
//
    func startTamaraPayment(amount: Double, completion: @escaping (PaymentResult) -> Void) {
        let extraItems: [TamaraExtraItem] = services.map {
            TamaraExtraItem(sub_sub_id: $0.item._id, qty: $0.quantity)
        }

        let tamaraBody = TamaraItemBody(amount: totalAmount, extra: extraItems)

        loadingMessage = "جارٍ معالجة الدفع..."
        isLoading = true
        orderViewModel.tamaraCheckout(params: tamaraBody) {
            let url = orderViewModel.tamaraCheckout?.checkout_url ?? ""
            checkoutUrl = url
            tamaraViewModel = TamaraWebViewModel(
                url: checkoutUrl,
                merchantURL: TamaraMerchantURL(
                    success: "tamara://checkout/success",
                    failure: "tamara://checkout/failure",
                    cancel: "tamara://checkout/cancel",
                    notification: "tamara://checkout/notification"
                )
            )
            showTamaraPayment = true
        }
    }

    private func handleTamaraRedirect(url: URL) {
        isLoading = false // أوقف اللودينج هنا دائمًا عند انتهاء الدفع
        let urlStr = url.absoluteString
        showTamaraPayment = false

        if urlStr.contains("checkout/success") {
            addOrder(paymentType: .tamara)
        } else if urlStr.contains("tamara://checkout/failure") {
            orderViewModel.errorMessage = "فشلت عملية الدفع بتمارا"
            showPaymentError = true
        } else if urlStr.contains("tamara://checkout/cancel") {
            orderViewModel.errorMessage = "تم إلغاء عملية الدفع"
            showPaymentError = true
        }
    }

    func addOrder(paymentType: PaymentType) {
//        var params = orderData.toJson(
//            couponCode: couponCode,
//            paymentType: paymentType.rawValue
//        )
//
//        // فرض بيانات الرياض
//        params["lat"] = 24.774265      // إحداثيات الرياض
//        params["lng"] = 46.738586
//        params["address"] = "الرياض - حي النرجس"
//        params["title"] = "شقتي في الرياض"
//        print("tokkkk \(UserSettings.shared.token)")
//        print("paramsparams \(params)")
//
//        orderViewModel.addOrder(params: params) { id, msg in
//            if id.isEmpty {
//                orderViewModel.errorMessage = msg
//                showPaymentError = true
//            } else {
//                // نجاح
//                appRouter.navigate(to: .paymentSuccess)
//            }
//        }

        let params = orderData.toJson(
            couponCode: couponCode,
            paymentType: paymentType.rawValue
        )

        orderViewModel.addOrder(params: params) { id, msg in
            if id.isEmpty {
                orderViewModel.errorMessage = msg
                showPaymentError = true
            } else {
                // نجاح
                appRouter.navigate(to: .paymentSuccess)
            }
        }
    }
}

#Preview {
    let address = AddressItem(
        streetName: "شارع الأمير",
        floorNo: "2",
        buildingNo: "10",
        flatNo: "5",
        type: "home",
        createAt: nil,
        id: "addr001",
        title: "شقتي في النرجس",
        lat: 24.774265,
        lng: 46.738586,
        address: "الرياض - حي النرجس",
        userId: "user001",
        discount: nil
    )

    let serviceItem = SelectedServiceItem(
        item: SubSubCategoryItem(
            _id: "service001",
            price: 150,
            title: "تنظيف مكيف سبليت",
            description: "تنظيف كامل للمكيف مع التعقيم",
            image: "",
            type: "split"
        ),
        quantity: 2,
        subCategoryTitle: "خدمات التكييف",
        categoryId: "main_cat_1",
        subCategoryId: "sub_cat_1"
    )

    let orderData = OrderData(
        services: [serviceItem],
        address: address,
        userLocation: nil,
        notes: "يرجى التواصل قبل الوصول"
    )

    PaymentCheckoutView(orderData: orderData)
        .environmentObject(AppRouter())
}

struct PaymentErrorPopup: View {
    let message: String
    var onClose: () -> Void

    @State private var appear = false
    @State private var iconGlow = false
    @State private var buttonPressed = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.red.opacity(0.28))
                    .frame(width: 80, height: 80)
                    .blur(radius: iconGlow ? 16 : 4)
                    .scaleEffect(iconGlow ? 1.15 : 0.96)
                    .opacity(iconGlow ? 0.55 : 0.35)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: iconGlow)

                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.25), radius: 12, x: 0, y: 2)
            }

            Text("خطأ في الدفع")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .scaleEffect(appear ? 1 : 0.92)
                .animation(.easeOut(duration: 0.5), value: appear)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .opacity(appear ? 1 : 0)
                .animation(.easeIn(duration: 0.8).delay(0.2), value: appear)

            Button(action: {
                buttonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    buttonPressed = false
                    onClose()
                }
            }) {
                Text("حسناً")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(buttonPressed ? Color.red.opacity(0.7) : Color.red.opacity(0.90))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .scaleEffect(buttonPressed ? 0.96 : 1)
            }
            .padding()
        }
        .padding(.vertical, 34)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.97))
                .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 6)
        )
        .scaleEffect(appear ? 1 : 0.84)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.48, dampingFraction: 0.85), value: appear)
        .onAppear {
            appear = true
            iconGlow = true
            // هزة بسيطة عند الخطأ (هنا لو عندك haptic engine)
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
        }
    }
}
