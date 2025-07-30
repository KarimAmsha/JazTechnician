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

// صندوق الإحصائية
struct StatBox: View {
    var title: String
    var count: Int
    var icon: String // اسم الصورة أو النظام

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.primary().opacity(0.14), Color.primary().opacity(0.34)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .frame(height: 56)
                .shadow(color: Color.primary().opacity(0.16), radius: 5, x: 0, y: 4)

                if icon.hasPrefix("ic_") {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.primary())
                        .padding(8)
                }
            }

            Text(title)
                .customFont(weight: .medium, size: 16)
                .foregroundColor(.black)
                .lineLimit(1)

            Text("\(count)")
                .customFont(weight: .medium, size: 16)
                .foregroundColor(Color.primary())
        }
        .frame(height: 118)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 17)
                .fill(Color.white)
                .shadow(color: Color.primary().opacity(0.07), radius: 9, x: 0, y: 3)
        )
        .padding(.bottom, 4)
    }
}

// الهوم فيو
struct HomeView: View {
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 🔥 جزء الإحصائيات بالأعلى
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 15) {
                    StatBox(title: "قيد التنفيذ", count: viewModel.orderCount.progress, icon: "hourglass")
                    StatBox(title: "المقبولة", count: viewModel.orderCount.accpeted, icon: "checkmark.seal.fill")
                    StatBox(title: "المنتهية", count: viewModel.orderCount.finished, icon: "flag.checkered")
                    StatBox(title: "الملغية", count: viewModel.orderCount.cancelded, icon: "xmark.octagon.fill")
                }
                .padding(.horizontal, 4)
                .padding(.top, 10)
            }
            .padding(.top)
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: UserSettings.shared.user?.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 36, height: 36)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "#DFE2E6"), lineWidth: 1))
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 36, height: 36)
                        @unknown default:
                            EmptyView()
                        }
                    }

                    Text(LocalizedStringKey.statistics)
                        .customFont(weight: .bold, size: 18)
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            viewModel.getOrderCount()
            refreshFcmToken()
            LocationManager.shared.getUserLocation(completion: { location, address in
                //
            })
            ChatViewModel.setUser()
        }
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
