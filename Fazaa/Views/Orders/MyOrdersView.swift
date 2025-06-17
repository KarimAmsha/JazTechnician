import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State var selectedTab: OrderStatus = .new

    // ترتيب الحالات حسب التصميم
    let tabs: [OrderStatus] = [.new, .started, .finished, .prefinished, .canceled]

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            let activeColor = Color(red: 16/255, green: 71/255, blue: 119/255) // لون أزرق غامق (غيره إذا عندك لون آخر)
            let inactiveColor = Color(red: 243/255, green: 246/255, blue: 249/255) // رمادي جداً

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { status in
                        Button {
                            selectedTab = status
                        } label: {
                            Text(status.displayTitle)
                                .font(.system(size: 15, weight: .semibold))
                                .frame(minWidth: 0)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 24)
                                .background(
                                    selectedTab == status ? activeColor : inactiveColor
                                )
                                .foregroundColor(selectedTab == status ? .white : .black)
                                .cornerRadius(16)
                                .animation(.easeInOut(duration: 0.18), value: selectedTab)
                        }
                        // مسافة بين العناصر (فقط في حال ليست الأخيرة)
                        if status != tabs.last {
                            Spacer().frame(width: 4)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(inactiveColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .frame(height: 56)

            // Orders List
            ScrollView(showsIndicators: false) {
                if viewModel.orders.isEmpty {
                    VStack(spacing: 20) {
                        Spacer(minLength: 60)
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                        Spacer()
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.orders, id: \.id) { item in
                            OrderItemView(item: item) {
                                appRouter.navigate(to: .orderDetails(item.id ?? ""))
                            }
                        }
                    }
                    .padding(.top, 12)
                }

                if viewModel.shouldLoadMoreData {
                    Color.clear.onAppear { loadMore() }
                }
                if viewModel.isFetchingMoreData {
                    ProgressView().padding(.top)
                }
                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button { appRouter.navigateBack() } label: {
                        Image("ic_back")
                    }
                    Text("طلباتي")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear {
            loadData()
            print("uuuu \(UserSettings.shared.token ?? "")")
        }
        .onChange(of: selectedTab) { _ in loadData() }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
}

#Preview {
    MyOrdersView().environmentObject(AppRouter())
}

// MARK: - Logic
extension MyOrdersView {
    func loadData() {
        viewModel.orders.removeAll()
        viewModel.getOrders(status: selectedTab.rawValue, page: 0, limit: 10)
    }

    func loadMore() {
        viewModel.loadMoreOrders(status: selectedTab.rawValue, limit: 10)
    }
}
