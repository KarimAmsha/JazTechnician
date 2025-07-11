
import SwiftUI
import PopupView

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject private var authViewModel = AuthViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState

    @State private var showProfileSheet = false
    @State private var isAvailable: Bool = UserSettings.shared.user?.isAvailable ?? false
    @State private var isUpdatingAvailable = false

    // Popup state
    @State private var showErrorPopup = false
    @State private var showSuccessPopup = false
    @State private var popupMessage = ""

    var body: some View {
        GeometryReader { _ in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    profileHeader

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: isAvailable ? "circle.fill" : "circle")
                                .foregroundColor(isAvailable ? .green : .gray)
                            Toggle("متاح لاستقبال الطلبات", isOn: $isAvailable)
                                .onChange(of: isAvailable) { newValue in
                                    setAvailable(newValue)
                                }
                                .disabled(isUpdatingAvailable)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }

                    // Settings List
                    VStack(spacing: 0) {
                        settingsRow(title: "تغيير كلمة المرور", icon: "person.crop.circle") {
                            appRouter.navigate(to: .changePassword)
                        }
                        settingsRow(title: "تواصل معنا", icon: "message") {
                            appRouter.navigate(to: .contactUs)
                        }
                        settingsRow(title: "سياسة الاستخدام", icon: "heart") {
                            if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .using }) {
                                appRouter.navigate(to: .constant(item))
                            }
                        }
                        settingsRow(title: "سياسة الخصوصية", icon: "lock") {
                            if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .privacy }) {
                                appRouter.navigate(to: .constant(item))
                            }
                        }
                        settingsRow(title: "تسجيل الخروج", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                            logout()
                        }
                        settingsRow(title: "حذف الحساب", icon: "trash", isDestructive: true) {
                            deleteAccount()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    AsyncImageView(
                        width: 36,
                        height: 36,
                        cornerRadius: 8,
                        imageURL: UserSettings.shared.user?.image?.toURL(),
                        placeholder: Image(systemName: "person.crop.square"),
                        contentMode: .fill
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Color.black121212()))
                            .overlay(Image(systemName: "gearshape.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white))
                            .offset(x: 8, y: 8), alignment: .bottomTrailing
                    )

                    Text("الملف الشخصي! 🙆🏻‍♀️")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            UserProfileSheetView(
                name: UserSettings.shared.user?.full_name ?? "-",
                email: UserSettings.shared.user?.email ?? "-",
                onClose: { showProfileSheet = false }
            )
            .presentationDetents([.medium])
            .presentationCornerRadius(22)
        }
        .popup(isPresented: $showErrorPopup, type: .toast, position: .top, closeOnTap: true, closeOnTapOutside: true) {
            CustomPopup(
                title: "خطأ",
                message: popupMessage,
                icon: "xmark.octagon.fill",
                color: .red
            ) {
                showErrorPopup = false
            }
        }
        .popup(isPresented: $showSuccessPopup, type: .toast, position: .top, closeOnTap: true, closeOnTapOutside: true) {
            CustomPopup(
                title: "نجاح",
                message: popupMessage,
                icon: "checkmark.circle.fill",
                color: .green
            ) {
                showSuccessPopup = false
            }
        }
        .onAppear {
            getConstants()
        }
    }

    private var profileHeader: some View {
        VStack {
            HStack {
                AsyncImageView(
                    width: 70,
                    height: 70,
                    cornerRadius: 12,
                    imageURL: UserSettings.shared.user?.image?.toURL(),
                    placeholder: Image(systemName: "person.crop.square"),
                    contentMode: .fill
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(UserSettings.shared.user?.full_name ?? "")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.black121212())
                    Text(UserSettings.shared.user?.phone_number ?? "")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.black121212())
                }

                Spacer()

                if let rate = UserSettings.shared.user?.rate {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellowFFB020())
                            .font(.system(size: 14))
                        Text(String(format: "%.1f", rate))
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.grayA1A1A1())
                    }
                }
            }

            Button {
                showProfileSheet = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.primary())
                    Text("عرض معلومات الحساب")
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.primaryDark())
                    Spacer()
                    Image(systemName: "chevron.left")
                        .foregroundColor(.grayA1A1A1())
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Settings Row
    @ViewBuilder
    func settingsRow(title: String, icon: String, badge: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(isDestructive ? .red : .black121212())
                    Text(title)
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(isDestructive ? .red : .black121212())
                    if let badge = badge {
                        Spacer()
                        Text(badge)
                            .font(.caption)
                            .padding(6)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Image(systemName: "chevron.left")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.black121212())
                }
                CustomDivider()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppRouter())
        .environmentObject(AppState())
}

extension ProfileView {
    private func getConstants() {
        initialViewModel.fetchConstantsItems()
    }

    private func setAvailable(_ available: Bool) {
        isUpdatingAvailable = true
        let params = [
            "isAvailable": available
        ]
        let urlString = "\(Constants.baseURL)/driver/employee/available"
        guard let url = URL(string: urlString) else {
            isUpdatingAvailable = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        if let token = UserSettings.shared.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUpdatingAvailable = false

                if let error = error {
                    isAvailable = !available
                    popupMessage = "حدث خطأ في الاتصال"
                    showErrorPopup = true
                    print("Network Error:", error)
                    return
                }
                guard let data = data else {
                    isAvailable = !available
                    popupMessage = "لم يتم استقبال رد من السيرفر"
                    showErrorPopup = true
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let status = json["status"] as? Bool ?? false
                        let message = json["message"] as? String ?? "حدث خطأ"

                        if status {
                            popupMessage = message
                            showSuccessPopup = true
                            // يمكنك تحديث UserSettings.shared.user?.isAvailable إذا أردت مزامنة الحالة فورًا
                        } else {
                            isAvailable = !available
                            popupMessage = message
                            showErrorPopup = true
                        }
                    } else {
                        isAvailable = !available
                        popupMessage = "فشل في قراءة بيانات السيرفر"
                        showErrorPopup = true
                    }
                } catch {
                    isAvailable = !available
                    popupMessage = "خطأ أثناء قراءة الرد"
                    showErrorPopup = true
                }
            }
        }.resume()
    }

    private func logout() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.logout,
                                    message: LocalizedStringKey.logoutMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.logout,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.logoutUser {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        appRouter.togglePopup(.alert(alertModel))
    }

    private func deleteAccount() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.deleteAccount,
                                    message: LocalizedStringKey.deleteAccountMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.deleteAccount,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.deleteAccount {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        appRouter.togglePopup(.alert(alertModel))
    }
}

// MARK: - CustomPopup for success/error
struct CustomPopup: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            Text(title)
                .font(.title3.bold())
                .foregroundColor(color)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            Button(action: onClose) {
                Text("إغلاق")
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(width: 300)
        .background(.white)
        .cornerRadius(18)
        .shadow(radius: 10)
    }
}

// MARK: - UserProfileSheetView
struct UserProfileSheetView: View {
    let name: String
    let email: String
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            HStack {
                Text("معلومات الحساب")
                    .font(.title3.bold())
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 10)

            VStack(spacing: 14) {
                HStack {
                    Text("الاسم:")
                        .font(.body.bold())
                    Spacer()
                    Text(name)
                        .foregroundColor(.primaryDark())
                }
                Divider()
                HStack {
                    Text("البريد الإلكتروني:")
                        .font(.body.bold())
                    Spacer()
                    Text(email)
                        .foregroundColor(.primaryDark())
                }
            }
            .padding()
            .background(Color.backgroundFEF3DE())
            .cornerRadius(12)
            .padding(.horizontal, 6)

            Spacer()
        }
        .padding(24)
    }
}
