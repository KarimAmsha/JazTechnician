//
//  HomeView.swift
//  Fazaa
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI
import SkeletonUI
import RefreshableScrollView
import FirebaseMessaging

struct HomeView: View {
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject private var locationManager = LocationManager2()
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // الضمان
                if let sliderSection = viewModel.homeItems.first(where: { $0.type == "slider" }),
                   let item = sliderSection.data?.first {

                    AsyncImage(url: URL(string: item.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 140)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 140)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }

                // عرض أقسام الخدمات من نوع "main_service"
                if let mainServiceSection = viewModel.homeItems.first(where: { $0.type == "main_service" }) {
                    if let categories = mainServiceSection.data, !categories.isEmpty {
                        // العنوان
                        if !mainServiceSection.title.isEmpty {
                            Text(mainServiceSection.title)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }

                        // الشبكة
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 20) {
                            ForEach(categories, id: \._id) { item in
                                VStack(spacing: 8) {
                                    VStack {
                                        AsyncImage(url: URL(string: item.image ?? "")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(height: 80)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 80)
                                                    .padding(8)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 80)
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .onTapGesture {
                                        appRouter.navigate(to: .subCategory(title: item.title ?? "", categoryId: item._id))
                                    }

                                    // النص أسفل البطاقة
                                    Text(item.title ?? "")
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(height: 40) // 🔐 ارتفاع ثابت للنص

                                }
                                .frame(height: 190) // ✅ ارتفاع نهائي موحد لكل عنصر
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    }
                }

                if let offerSection = viewModel.homeItems.first(where: { $0.type == "offer" }),
                   let offers = offerSection.data, !offers.isEmpty {

                    TabView(selection: $currentIndex) {
                        ForEach(offers.indices, id: \.self) { index in
                            let offer = offers[index]
                            AsyncImage(url: URL(string: offer.image ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 180)
                                        .frame(maxWidth: .infinity)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding(.horizontal)
                            .tag(index)
                        }
                    }
                    .frame(height: 200)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .onReceive(timer) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % offers.count
                        }
                    }
                }

                if let whatsappSection = viewModel.homeItems.first(where: { $0.type == "whatsapp" }),
                   let item = whatsappSection.data?.first {

                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: item.image ?? "")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 160)
                                    .frame(maxWidth: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 160)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .onTapGesture {
                            if let url = URL(string: "https://wa.me/\(viewModel.whatsAppContactItem?.Data ?? "")") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.north.circle")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.secondary())

                        Text(LocalizedStringKey.myLocation)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text(locationManager.address.isEmpty ? "جارٍ تحديد الموقع..." : locationManager.address)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.head)
                        Spacer()
                        Image(systemName: "chevron.down.circle.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                }
                .onTapGesture {
                    appRouter.navigate(to: .addressBook)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("الرصيد:")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Image(systemName: "wallet.pass")
                        Text("\(20, specifier: "%.1f") SAR")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.black)
                }
                .onTapGesture {
                    appRouter.navigate(to: .walletView)
                }
            }
        }
        .onAppear {
            getHome()
            viewModel.fetchContactItems()
            refreshFcmToken()
            locationManager.startUpdatingLocation()
            ChatViewModel.setUser()
        }
    }

    func getHome() {
        viewModel.fetchHomeItems()
    }

    func refreshFcmToken() {
        Messaging.messaging().token { token, error in
            if let token = token {
                let params: [String: Any] = [
                    "id": UserSettings.shared.id ?? "",
                    "fcmToken": token
                ]
                userViewModel.refreshFcmToken(params: params, onsuccess: {})
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
