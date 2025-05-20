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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // الضمان
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .frame(height: 110)

                    HStack(spacing: 12) {
                        Image(systemName: "shield")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("جميع خدماتنا خاضعة للضمان الذهبي")
                                .font(.body)
                                .fontWeight(.bold)
                            Text("ضمان استرجاع نقودك بالكامل إن لم يتم حل المشكلة")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)

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
                                        appRouter.navigate(to: .freelancerList)
                                    }

                                    // النص أسفل البطاقة
                                    Text(item.title ?? "")
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(height: 180) // 💡 إجمالي ارتفاع موحّد لكل عنصر
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    }
                }

                if let whatsappSection = viewModel.homeItems.first(where: { $0.type == "whatsapp" }),
                   let item = whatsappSection.data?.first {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title ?? "")
                            .font(.headline)
                        Text(item.description ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Button(action: {
                            if let url = URL(string: "https://wa.me/رقمك") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("راسلنا على واتساب")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                            .foregroundColor(.black)

                        Text(LocalizedStringKey.myLocation)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    Text(locationManager.address.isEmpty ? "جارٍ تحديد الموقع..." : locationManager.address)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.55, alignment: .leading)
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
            }
        }
        .onAppear {
            getHome()
            viewModel.fetchContactItems()
            refreshFcmToken()
            locationManager.startUpdatingLocation()
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
