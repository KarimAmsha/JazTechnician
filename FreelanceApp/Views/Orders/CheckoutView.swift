import SwiftUI
import PopupView
import MapKit
import goSellSDK
import TamaraSDK

enum PurchaseType: String, CaseIterable, Identifiable {
    case myself = "شخصي"
    case friend = "لصديق"

    var id: String { self.rawValue }
}

struct CheckoutView: View {
    @State private var payCash: Bool = true
    @State private var payMada: Bool = false
    @State private var payTamara: Bool = false
    @State private var payOnline: Bool = false
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var isShowingAddress = false
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @State private var addressTitle = ""
    @State private var streetName = ""
    @State private var buildingNo = ""
    @State private var floorNo = ""
    @State private var flatNo = ""
    @State private var servicePlace: PlaceType = .home
    @State private var locations: [Mark] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 24.7136,
            longitude: 46.6753
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 5,
            longitudeDelta: 5
        )
    )
    @State private var isShowingMap = false
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @StateObject private var cartViewModel = CartViewModel(errorHandling: ErrorHandling())
    let cartItems: CartItems?
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State var currentUserLocation: AddressItem?
    @StateObject private var locationManager2 = LocationManager2()
    @State private var selectedPurchaseType: PurchaseType = .myself
    @State private var isAddressBook = false
    @State private var coupon: String = ""
    @State private var notes: String = LocalizedStringKey.notes
    @State var placeholderString = LocalizedStringKey.notes
    @StateObject private var paymentViewModel = PaymentViewModel()
    @State private var showTamaraPayment = false
    @State private var checkoutUrl = ""

    @State private var selectedAddress: AddressItem? {
        didSet {
            // Update the region and other address-related fields when a new address is selected
            if let selectedAddress = selectedAddress {
                streetName = selectedAddress.streetName ?? ""
                floorNo = selectedAddress.floorNo ?? ""
                buildingNo = selectedAddress.buildingNo ?? ""
                flatNo = selectedAddress.flatNo ?? ""
                
                // Update the region based on the selected address coordinates
                region.center = CLLocationCoordinate2D(latitude: selectedAddress.lat ?? 0, longitude: selectedAddress.lng ?? 0)
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                // Append a new Mark with the selected address coordinates and title
                let newLocation = Mark(
                    title: selectedAddress.title ?? "",
                    coordinate: CLLocationCoordinate2D(latitude: selectedAddress.lat ?? 0, longitude: selectedAddress.lng ?? 0),
                    show: true,
                    imageName: "ic_logo",
                    isUserLocation: false
                )

                locations.removeAll()
                locations.append(newLocation)
            }
        }
    }
        
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
//                    CouponCheckSection(coupon: $coupon) {
//                        // Action to perform when check coupon button is tapped
//                        checkCartCoupun()
//                    }
//
                    ProductSummarySection(products: cartItems?.results)

                    PurchaseTypeSection(purchaseType: $selectedPurchaseType)
                        .disabled(orderViewModel.isLoading)

                    AddressSelectionView(addressTitle: $addressTitle, streetName: $streetName, isShowingMap: $isShowingMap, servicePlace: $servicePlace, locations: $locations, region: $region, isShowingAddress: $isShowingAddress, userLocation: $userLocation, purchaseType: $selectedPurchaseType)
                        .disabled(orderViewModel.isLoading)

                    NotesView(notes: $notes, placeholder: placeholderString)
                        .disabled(orderViewModel.isLoading)

                    PaymentInformationSection(payCash: $payCash, payMada: $payMada, payTamara: $payTamara)
                        .disabled(orderViewModel.isLoading)

                    if let cartTotal = cartViewModel.cartTotal {
                        OrderSummarySection(cartTotal: cartTotal)
                    }
                }
                .padding()
            }
            VStack {
                if orderViewModel.isLoading {
                    LoadingView()
                }
                
                Button(action: {
                    // Place order logic
                    if payCash {
                        addOrder()
                    } else {
                        if let cartTotal = cartViewModel.cartTotal {
                            startPayment(amount: cartTotal.final_total ?? 0.0)
                        }
                    }
                }) {
                    HStack {
                        Text(LocalizedStringKey.payNow)
                    }
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
                .disabled(orderViewModel.isLoading)
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text(LocalizedStringKey.payment)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .popup(isPresented: $isShowingAddress) {
            let model = CustomModel(
                title: LocalizedStringKey.addressBook,
                content: "",
                items: userViewModel.addressBook ?? [],
                onSelect: { item in
                    DispatchQueue.main.async {
                        selectedAddress = item
                        addressTitle = item.title ?? ""
                        
                        isShowingAddress = false
                    }
            })
            
            AddressListView(customModel: model, currentUserLocation: $currentUserLocation, isAddressBook: $isAddressBook)

        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .onChange(of: orderViewModel.errorMessage) { errorMessage in
            if let errorMessage = errorMessage {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: cartViewModel.errorMessage) { errorMessage in
            if let errorMessage = errorMessage {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: locationManager2.location) { value in
            if let location = locationManager2.location {
                print("New Location: \(location)")
                currentUserLocation = AddressItem(
                    streetName: "",
                    floorNo: "",
                    buildingNo: "",
                    flatNo: "",
                    type: "موقعي الحالي",
                    createAt: "",
                    id: "",
                    title: "موقعي الحالي",
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude,
                    address: locationManager2.address,
                    userId: "",
                    discount: 0
                )
            }
        }
        .onChange(of: paymentViewModel.errorMessage) { errorMessage in
            if !errorMessage.isEmpty {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: orderViewModel.errorMessage) { errorMessage in
            if let errorMessage = errorMessage {
                appRouter.togglePopupError(.alertError("", errorMessage))
            }
        }
        .onChange(of: paymentViewModel.paymentSuccess) { paymentSuccess in
            // Do something when payment is successful
            if paymentSuccess {
                addOrder()
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
                        addOrder()
                    }
                    .onReceive(tamaraViewModel.$failedDirection) { _ in
                        showTamaraPayment = false
                    }
                    .onReceive(tamaraViewModel.$finishLoadingHandler) { _ in }
            }
        }
        .onAppear {
            userViewModel.getAddressByType(type: servicePlace.rawValue)
            cartViewModel.cartTotal {
                //
            }
            cartViewModel.getCartItems()
            locationManager2.startUpdatingLocation()
            
            GoSellSDK.mode = .production
        }
    }
}

struct ProductSummarySection: View {
    let products: [CartProduct]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.productSummary)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            if let products = products {
                ForEach(products.indices, id: \.self) { index in
                    let item = products[index]
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "")
                            
                            if let variationName = item.variation_name, !variationName.isEmpty {
                                Text("النوع: \(variationName)")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Text(LocalizedStringKey.quantity)
                                Text(item.qty?.toString() ?? "")
                            }
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                Text(String(format: "%.2f", item.sale_price ?? 0))
                                Text(LocalizedStringKey.sar)
                            }
                        }
                    }
                    .customFont(weight: .regular, size: 15)
                    .foregroundColor(.black121212())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PaymentInformationSection: View {
    @Binding var payCash: Bool
    @Binding var payMada: Bool
    @Binding var payTamara: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.paymentMethod)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            HStack {
                CheckboxButton(title: LocalizedStringKey.payCash, isChecked: $payCash, other1: $payMada, other2: $payTamara)
                Spacer()
                CheckboxButton(title: LocalizedStringKey.payMada, isChecked: $payMada, other1: $payCash, other2: $payTamara)
                Spacer()
                CheckboxButton(title: LocalizedStringKey.payTamara, isChecked: $payTamara, other1: $payCash, other2: $payMada)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CheckboxButton: View {
    let title: String
    @Binding var isChecked: Bool
    @Binding var other1: Bool
    @Binding var other2: Bool
    
    var body: some View {
        Button(action: {
            if !isChecked {
                isChecked = true
                other1 = false
                other2 = false
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isChecked ? .primary() : .gray595959())
                Text(title)
                    .font(.body)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderSummarySection: View {
    let cartTotal: CartTotal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.orderSummary)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            if let tax = cartTotal.tax {
                orderSummaryRow(title: LocalizedStringKey.cartTotalTax, amount: tax)
            }

            if let totalPrice = cartTotal.total_price {
                orderSummaryRow(title: LocalizedStringKey.cartTotalTotalPrice, amount: totalPrice)
            }
  
            if let finalTotal = cartTotal.final_total {
                orderSummaryRow(title: LocalizedStringKey.cartTotalFinalTotal, amount: finalTotal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func orderSummaryRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(LocalizedStringKey.sar) \(amount, specifier: "%.2f")")
                .environment(\.locale, .init(identifier: "en_US"))
        }
        .customFont(weight: title == LocalizedStringKey.cartTotalFinalTotal ? .bold : .regular, size: 15)
        .foregroundColor(.black121212())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView(cartItems: nil)
        }
    }
}

struct AddressSelectionView: View {
    @Binding var addressTitle: String
    @Binding var streetName: String
    @Binding var isShowingMap: Bool
    @Binding var servicePlace: PlaceType
    @Binding var locations: [Mark]
    @Binding var region: MKCoordinateRegion
    @Binding var isShowingAddress: Bool
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var purchaseType: PurchaseType

    @State private var isRotating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.yourLocation)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            if purchaseType == .friend {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.address)
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.black1F1F1F())
                    CustomTextField(text: $addressTitle, placeholder: LocalizedStringKey.address, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                }
            } else {
                if servicePlace != .currentLocation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.selectAddress)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        ZStack {
                            CustomTextField(text: $addressTitle, placeholder: LocalizedStringKey.selectAddress, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .disabled(true)
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray8F8F8F())
                                    .padding()
                            }
                        }
                    }
                    .onTapGesture {
                        isShowingAddress = true
                    }
                }
            }

            VStack(alignment: .leading) {
                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
                        MapAnnotation(
                            coordinate: location.coordinate,
                            anchorPoint: CGPoint(x: 0.5, y: 0.7)
                        ) {
                            VStack {
                                if location.isUserLocation {
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                                        .onAppear {
                                            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                                                self.isRotating.toggle()
                                            }
                                        }
                                } else {
                                    Image("ic_pin")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                        }
                    }
                    .disabled(true)
                    .onAppear {
                        moveToUserLocation()
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "square.arrowtriangle.4.outward")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    isShowingMap = true
                                }
                        }
                    }
                    .padding(10)
                    .sheet(isPresented: $isShowingMap) {
                        if purchaseType == .friend {
                            FullMapView(region: $region, isShowingMap: $isShowingMap, address: $addressTitle)
                        } else {
                            ShowMapView(region: $region, locations: $locations, isShowingMap: $isShowingMap)
                        }
                    }
                    .onChange(of: region, perform: { newRegion in
                        if purchaseType == .friend {
                            Utilities.getAddress(for: newRegion.center) { address in
                                self.addressTitle = address
                            }
                        }
                    })
                }
                .frame(height: 158)
                .cornerRadius(8)
            }
            
            if servicePlace == .currentLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.name)
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.black1F1F1F())
                    CustomTextField(text: $addressTitle, placeholder: LocalizedStringKey.homeAddress, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey.address)
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.black1F1F1F())
                    CustomTextField(text: $streetName, placeholder: LocalizedStringKey.address, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    func moveToUserLocation() {
        withAnimation(.easeInOut(duration: 2.0)) {
            LocationManager.shared.getCurrentLocation { location in
                if let location = location {
                    region.center = location
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let userLocationMark = Mark(
                        title: "موقعي",
                        coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        show: true,
                        imageName: "ic_logo",
                        isUserLocation: true
                    )
                    
                    locations.append(userLocationMark)
                    self.userLocation = location
                    Utilities.getAddress(for: location) { address in
                        self.streetName = address
                    }
                }
            }
        }
    }
}

extension CheckoutView {
    func addOrder() {
        if selectedPurchaseType == .myself {
            // Check if the selected address is valid based on the purchase type
            guard let selectedAddress = selectedAddress else {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }

            // Validate latitude and longitude for "myself" purchase type
            if selectedAddress.lat == 0.0 || selectedAddress.lng == 0.0 {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }
        } else {
            // Validate address ID for other purchase types
            if region.center.latitude == 0.0 || region.center.longitude == 0.0 {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }
        }

        let currentDate = Date()
        let formattedDate = currentDate.formattedDateString()
        let formattedTime = currentDate.formattedTimeString()

        // Prepare parameters dictionary
        var params: [String: Any] = [
            "couponCode": coupon,
            "PaymentType": payCash ? "cash" : "online",
            "dt_date": formattedDate,
            "dt_time": formattedTime,
            "is_address_book": isAddressBook,
            "OrderType": selectedPurchaseType == .myself ? 1 : 2,
            "notes": notes,
        ]

        // Determine address and coordinates based on purchase type
        if selectedPurchaseType == .myself {
            params["address"] = selectedAddress?.address ?? ""
            params["lat"] = selectedAddress?.lat ?? 0.0
            params["lng"] = selectedAddress?.lng ?? 0.0
        } else { // For purchase type = .friend
            params["address"] = addressTitle
            params["lat"] = region.center.latitude
            params["lng"] = region.center.longitude
        }
        
        if isAddressBook {
            params["address_book"] = selectedAddress?.id ?? ""
        }
        
        orderViewModel.addOrder(params: params) { id, msg in
            appRouter.navigate(to: .paymentSuccess)
        }
    }
    
    func checkCartCoupun() {
        let params: [String: Any] = [
            "coupon": $coupon,
            "is_address_book": isAddressBook,
            "address_book": isAddressBook ? selectedAddress?.id ?? "" : "",
            "lat": selectedAddress?.lat ?? 0.0,
            "lng": selectedAddress?.lng ?? 0.0,
        ]

        cartViewModel.checkCartCoupun(params: params)
    }
}

struct PurchaseTypeSection: View {
    @Binding var purchaseType: PurchaseType

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("نوع عملية الشراء")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 10) {
                    RadioButton2(label: "شخصي", isSelected: purchaseType == .myself) {
                        purchaseType = .myself
                    }
                    RadioButton2(label: "لصديق", isSelected: purchaseType == .friend) {
                        purchaseType = .friend
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RadioButton2: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(isSelected ? .primary1() : .black121212())
                .onTapGesture {
                    action()
                }
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.black1F1F1F())
        }
        .padding(.vertical, 8)
    }
}

struct CouponCheckSection: View {
    @Binding var coupon: String
    var checkCoupon: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                TextField(LocalizedStringKey.coupon, text: $coupon)
                    .customFont(weight: .regular, size: 16)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image("ic_coupon") // Replace with your actual image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryDark(), lineWidth: 1)
            )
            
            Button(action: {
                checkCoupon()
            }) {
                Text(LocalizedStringKey.checkCoupon)
                    .customFont(weight: .bold, size: 16)
                    .foregroundColor(.white)
            }
            .padding(18)
            .background(Color.primary())
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NotesView: View {
    @Binding var notes: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.notes)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            TextEditor(text: $notes)
                .customFont(weight: .regular, size: 15)
                .foregroundColor(notes == placeholder ? .gray : .black121212())
                .frame(height: 100)
                .onTapGesture {
                    if notes == placeholder {
                        notes = ""
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

extension CheckoutView {
    func startPayment(amount: Double) {
        paymentViewModel.updateAmount(amount.toString())
        paymentViewModel.startPayment()
    }
}

extension CheckoutView {
    func tamaraCheckout() {
        if selectedPurchaseType == .myself {
            guard let selectedAddress = selectedAddress else {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }

            if selectedAddress.lat == 0.0 || selectedAddress.lng == 0.0 {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }
        } else {
            if region.center.latitude == 0.0 || region.center.longitude == 0.0 {
                orderViewModel.errorMessage = "الرجاء اختيار عنوان"
                return
            }
        }

        guard let cartTotal = cartViewModel.cartTotal,
              let cartItems = cartViewModel.cartItems?.results else {
            orderViewModel.errorMessage = "تعذر جلب بيانات السلة"
            return
        }

        let products = cartItems.map {
            TamaraProduct(
                product_id: $0.id ?? "",
                variation_name: $0.variation_name ?? "",
                variation_sku: $0.variation_sku ?? "",
                qty: $0.qty ?? 1
            )
        }

        let tamaraBody = TamaraBody(
            amount: cartTotal.final_total ?? 0.0,
            products: products
        )

        orderViewModel.tamaraCheckout(params: tamaraBody) {
            self.checkoutUrl = orderViewModel.tamaraCheckout?.checkout_url ?? ""
            showTamaraPayment.toggle()
        }
    }
}
