import SwiftUI
import MapKit

// MARK: - OrderDetailsView

struct OrderDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    let orderID: String

    @State private var showCancelSheet = false
    @State private var showRateSheet = false
    @State private var cancelNote: String = ""

    var body: some View {
        VStack(spacing: 0) {
            if let order = viewModel.orderDetailsItem {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // عنوان الشاشة
                        VStack(alignment: .center, spacing: 6) {
                            Text("تفاصيل الطلب")
                                .font(.system(size: 24, weight: .bold))
                            Text("استعرض تفاصيل طلبك وحالته")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        // الكارت الأساسي: الخدمة/الحالة/التاريخ/ID
                        OrderDetailsHeaderSection(order: order)

                        if let status = order.status {
                            StatusLabelView(status: OrderStatus(status))
                        }

                        OrderInfoSection(order: order)

                        if let extra = order.extra, !extra.isEmpty {
                            ServicesListSection(extra: extra)
                        }

                        if let address = order.address, let lat = order.lat, let lng = order.lng {
                            OrderLocationSection(address: address, lat: lat, lng: lng)
                        }

                        OrderActionsSection(
                            order: order,
                            onCancel: { showCancelSheet = true },
                            onRate: { showRateSheet = true }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            } else if viewModel.isLoading {
                ProgressView("جاري التحميل ...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                DefaultEmptyView(title: "لا يوجد بيانات")
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    Text("تفاصيل الطلب")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.getOrderDetails(orderId: orderID) { }
        }
        .sheet(isPresented: $showCancelSheet) {
            CancelOrderSheet(
                note: $cancelNote,
                onConfirm: {
                    viewModel.updateOrderStatus(
                        orderId: orderID,
                        params: [
                            "status": "canceled",
                            "canceled_note": cancelNote
                        ]
                    ) {
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showCancelSheet = false
                        cancelNote = ""
                    }
                },
                onCancel: {
                    showCancelSheet = false
                    cancelNote = ""
                }
            )
        }
        .sheet(isPresented: $showRateSheet) {
            RateOrderSheet(
                orderId: orderID,
                onRate: { rating, comment in
                    let params: [String: Any] = [
                        "rate_from_user": "\(rating)",
                        "note_from_user": comment
                    ]
                    viewModel.addReview(orderID: orderID, params: params) { _ in
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showRateSheet = false
                    }
                },
                onCancel: { showRateSheet = false }
            )
        }
    }
}

// MARK: - الأقسام الداخلية القابلة لإعادة الاستخدام

struct OrderDetailsHeaderSection: View {
    let order: OrderModel
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(order.title ?? "خدمة")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    if let date = order.dtDate {
                        Text(date)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    if let id = order.id {
                        Text("ID: #\(id)").font(.caption).foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(systemName: "wrench.and.screwdriver.fill")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundColor(.gray.opacity(0.5))
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

struct StatusLabelView: View {
    let status: OrderStatus
    var body: some View {
        Text(status.displayTitle)
            .font(.body)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(status.color.opacity(0.14))
            .foregroundColor(status.color)
            .cornerRadius(8)
            .padding(.vertical, 4)
    }
}

struct OrderInfoSection: View {
    let order: OrderModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                infoBox(icon: "calendar", title: "التاريخ", value: order.dtDate ?? "--")
                infoBox(icon: "clock", title: "الوقت", value: order.dtTime ?? "--")
            }
            HStack {
                infoBox(icon: "person", title: "ملاحظات", value: order.notes ?? "--")
                infoBox(icon: "number", title: "كود الطلب", value: order.orderNo ?? "--")
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
    }
    func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ServicesListSection: View {
    let extra: [ExtraBody]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("الخدمات المختارة")
                .font(.headline)
            ForEach(Array(extra.enumerated()), id: \.offset) { idx, item in
                VStack(alignment: .leading) {
                    HStack {
                        Text("خدمة فرعية ID: \(item.subSubCategoryId ?? "-")")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("الكمية: \(item.qty ?? 1)")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct OrderLocationSection: View {
    let address: String
    let lat: Double
    let lng: Double
    @State private var region: MKCoordinateRegion

    init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("مكان تنفيذ الخدمة")
                .font(.headline)
            Text(address)
                .font(.subheadline)
                .foregroundColor(.gray)
            Map(coordinateRegion: $region, annotationItems: [OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .red)
            }
            .frame(height: 140)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    struct OrderMapPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}

struct OrderActionsSection: View {
    let order: OrderModel
    var onCancel: () -> Void
    var onRate: () -> Void
    var body: some View {
        let status = OrderStatus(order.status ?? "new")
        VStack(spacing: 10) {
            if status == .accepted {
                actionButton(title: "إلغاء الطلب", background: Color(red: 1, green: 0.95, blue: 0.95), foreground: .red, action: onCancel)
            }
            if status == .finished {
                actionButton(title: "قيّم الطلب", background: Color.green.opacity(0.1), foreground: .green, action: onRate)
            }
        }
        .padding(.top, 14)
    }
    
    func actionButton(title: String, background: Color, foreground: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(background)
                .foregroundColor(foreground)
                .cornerRadius(12)
        }
    }
}

//----------------------------------------------
// شاشات منبثقة (Popups)

struct CancelOrderSheet: View {
    @Binding var note: String
    var onConfirm: () -> Void
    var onCancel: () -> Void
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("سبب الإلغاء")
                    .font(.headline)
                TextField("اكتب سبب الإلغاء هنا...", text: $note)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("إلغاء", action: onCancel)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    Button("تأكيد الإلغاء", action: onConfirm)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct RateOrderSheet: View {
    let orderId: String
    var onRate: (Int, String) -> Void
    var onCancel: () -> Void
    @State private var rating: Int = 5
    @State private var comment: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("قيّم الطلب")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 28))
                            .onTapGesture { rating = star }
                    }
                }
                TextField("أضف تعليقًا (اختياري)", text: $comment)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("إلغاء", action: onCancel)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    Button("إرسال التقييم") {
                        onRate(rating, comment)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderDetailsView(orderID: OrderModel.mock.id ?? "")
                .environmentObject(AppRouter())
                .environmentObject(OrderViewModel(errorHandling: ErrorHandling()))
        }
    }
}
