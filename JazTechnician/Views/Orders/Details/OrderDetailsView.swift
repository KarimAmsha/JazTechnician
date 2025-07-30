import SwiftUI
import MapKit

struct OrderDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    let orderID: String
    @StateObject var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())

    @State private var showCancelSheet = false
    @State private var showRateSheet = false
    @State private var cancelNote = ""
    @State private var newExtraServices: [SubCategory] = []
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let order = viewModel.orderBody {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            // Timeline
                            OrderStatusStepperView(status: order.orderStatus ?? .accepted)
                            // Main Info
                            mainInfoSection(order)
                            // Extra notes
                            if let notes = order.notes, !notes.isEmpty {
                                extraNotesSection(notes)
                            }
                            // Address
                            if let address = order.address?.address, let lat = order.lat, let lng = order.lng {
                                OrderLocationSection(address: address, lat: lat, lng: lng)
                            }
                            // Order Info
                            orderInfoSection(order)
                            // Chat
                            chatSection(order)
                            // Price Table
                            OrderPriceTableView(order: order)
                            if (order.new_total ?? 0) > 0 || (order.new_tax ?? 0) > 0 {
                                OrderNewTotalsTableView(order: order)
                            }
                            // Extra Services (progress)
                            let isEditable = order.orderStatus == .progress
                            let showExtraSection = !(order.extra?.isEmpty ?? true) || isEditable
                            if showExtraSection {
                                let allCategories = initialViewModel.homeItems?.category ?? []
                                let currentCategoryId = order.category_id?.id
                                let currentCategory = allCategories.first(where: { $0.id == currentCategoryId })
                                let relatedSubCategories = currentCategory?.sub ?? []
                                ExtraServicesSection(
                                    existingServices: order.extra ?? [],
                                    newServices: $newExtraServices,
                                    isEditable: isEditable,
                                    availableExtras: relatedSubCategories
                                )
                            }
                            // ==== Status Flow ====
                            statusActionsSection(order)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    }
                } else if viewModel.isLoading {
                    ProgressView("جاري التحميل ...")
                        .customFont(weight: .medium, size: 15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    DefaultEmptyView(title: "لا يوجد بيانات")
                }
            }
            if showError, let errorMessage = errorMessage {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                CustomErrorAlert(message: errorMessage) {
                    showError = false
                    self.errorMessage = nil
                }.zIndex(99)
            }
        }
        .animation(.spring(), value: showError)
        .background(Color.background().ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button { appRouter.navigateBack() } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.primaryDark())
                    }
                    Text("تفاصيل الطلب")
                        .customFont(weight: .semiBold, size: 18)
                        .foregroundColor(.primaryDark())
                }
            }
        }
        .onAppear {
            viewModel.getOrderDetails(orderId: orderID) {
                viewModel.startListeningOrderRealtime(orderId: orderID)
            }
            LocationManager.shared.getCurrentLocation { coordinate in
                guard let coordinate = coordinate else { return }
                if (initialViewModel.homeItems?.category ?? []).isEmpty {
                    initialViewModel.fetchHomeItems(q: nil, lat: coordinate.latitude, lng: coordinate.longitude)
                }
            }
        }
        .onDisappear { viewModel.stopListeningOrderRealtime() }
        .sheet(isPresented: $showCancelSheet) {
            CancelOrderSheet(
                note: $cancelNote,
                onConfirm: {
                    viewModel.updateOrderStatus(
                        orderId: orderID,
                        status: "canceled_by_driver",
                        onSuccess: {
                            viewModel.getOrderDetails(orderId: orderID) {}
                            showCancelSheet = false
                            cancelNote = ""
                        },
                        onError: { msg in
                            errorMessage = msg
                            showError = true
                        }
                    )
                },
                onCancel: {
                    showCancelSheet = false
                    cancelNote = ""
                }
            )
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(22)
            .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: $showRateSheet) {
            RateOrderSheet(
                orderId: orderID,
                onRate: { rating, comment in
                    let params: [String: Any] = [
                        "rate_from_driver": "\(rating)",
                        "note_from_driver": comment
                    ]
                    viewModel.addReview(orderID: orderID, params: params) { _ in
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showRateSheet = false
                    }
                },
                onCancel: { showRateSheet = false }
            )
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(22)
        }
    }

    // MARK: - Sections
    func mainInfoSection(_ order: OrderBody) -> some View {
        // بيانات الخدمة الرئيسية
        VStack(spacing: 6) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary())
                            .background(Color.backgroundFEF3DE())
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("الخدمة")
                            .customFont(weight: .bold, size: 18)
                            .foregroundColor(.black121212())
                    }
                    HStack {
                        Text(order.category_id?.title ?? "")
                        Text(" / ")
                        Text(order.sub_category_id?.title ?? "")
                    }
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.black121212())
                    
                    if let date = order.formattedCreateDate {
                        Text(date)
                            .customFont(weight: .light, size: 12)
                            .foregroundColor(.grayA1A1A1())
                    }
                    if let orderNo = order.order_no {
                        Text("رقم الطلب: #\(orderNo)")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.grayA1A1A1())
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(14)
    }
    func extraNotesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "doc.text")
                    .foregroundColor(.primary())
                Text("تفاصيل إضافية للطلب")
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
                Spacer()
            }
            Text(notes)
                .customFont(weight: .regular, size: 14)
                .foregroundColor(.black121212())
                .padding(.vertical, 4)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
    }
    func orderInfoSection(_ order: OrderBody) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                infoBox(icon: "clock", title: "وقت التنفيذ", value: order.formattedOrderDate ?? "--")
                infoBox(icon: "number", title: "كود الطلب", value: order.order_no ?? "--")
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
    }
    func chatSection(_ order: OrderBody) -> some View {
        let validOrderStatuses: [OrderStatus] = [.accepted, .way, .started, .finished]
        if let customer = order.user,
           let customerId = customer.id,
           customerId != UserSettings.shared.id,
           validOrderStatuses.contains(order.orderStatus ?? .accepted) {
            return AnyView(
                CustomerCardWithChatButtonView(
                    customer: customer,
                    orderStatus: order.orderStatus ?? .accepted,
                    onChat: {
                        let myId = UserSettings.shared.id ?? ""
                        let chatId = Utilities.makeChatId(currentUserId: myId, otherUserId: customerId)
                        appRouter.navigate(to: .chat(chatId: chatId, currentUserId: myId, receiverId: customerId))
                    }
                )
            )
        }
        return AnyView(EmptyView())
    }
    @ViewBuilder
    func statusActionsSection(_ order: OrderBody) -> some View {
        switch order.orderStatus {
        case .accepted:
            AcceptedActionsView(
                viewModel: viewModel,
                orderID: orderID,
                showCancelSheet: $showCancelSheet,
                showError: $showError,
                errorMessage: $errorMessage
            )
        case .way:
            WayActionsView(
                viewModel: viewModel,
                orderID: orderID,
                showError: $showError,
                errorMessage: $errorMessage
            )
        case .started:
            StartedActionsView(
                viewModel: viewModel,
                orderID: orderID,
                showError: $showError,
                errorMessage: $errorMessage
            )
        case .progress:
            ProgressActionsView(
                viewModel: viewModel,
                orderID: orderID,
                newExtraServices: $newExtraServices,
                showError: $showError,
                errorMessage: $errorMessage
            )
        case .updated, .prefinished:
            ConfirmationCodeSection(
                order: order,
                viewModel: viewModel,
                orderID: orderID,
                errorMessage: $errorMessage,
                showError: $showError
            )
        case .finished:
            Button("تقييم العميل") { showRateSheet = true }
                .buttonStyle(ActionButtonStyle(color: .primary()))
        default:
            EmptyView()
        }
    }
    func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.primary())
                Text(title)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.gray737373())
            }
            Text(value)
                .customFont(weight: .medium, size: 13)
                .foregroundColor(.black131313())
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OrderDetailsView(orderID: "order-xyz")
        .environmentObject(AppRouter())
}
