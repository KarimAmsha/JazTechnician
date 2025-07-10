import SwiftUI
import PopupView
import FirebaseMessaging
import MapKit
import Combine

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State var name: String = ""
    @State var email: String = ""
    @State var mobile: String = ""
    @State private var password = ""
    @EnvironmentObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State var completePhoneNumber = ""
    @StateObject private var viewModel = AuthViewModel(errorHandling: ErrorHandling())
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State var countryCode : String = "+966"
    @State var countryFlag : String = "🇸🇦"
    let counrties: [CPData] = Bundle.main.decode("CountryNumbers.json")
    @State private var searchCountry: String = ""
    @Binding var loginStatus: LoginStatus
    @FocusState private var keyIsFocused: Bool
    @State var presentSheet = false
    @EnvironmentObject var appRouter: AppRouter
    @State private var showCompanyRegisterSheet = false

    // UI States
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @State var loginType: LoginType = .login

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // عنوان
                    Text("مرحباً بك!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 32)
                    
                    // حقل الجوال
                    VStack(alignment: .leading, spacing: 8) {
                        Text("رقم الهاتف")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        MobileView(mobile: $mobile, presentSheet: $presentSheet)
                    }
                    
                    // كلمة المرور
                    VStack(alignment: .leading, spacing: 8) {
                        Text("كلمة المرور")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#222B45"))
                            .padding(.leading, 4)
                        ZStack {
                            // نفس ديزاين MobileView (نفس البورد ونفس كل شيء)
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryGreen(), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                                .frame(height: 56)
                            
                            HStack {
                                if showPassword {
                                    TextField("كلمة المرور", text: $password)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("كلمة المرور", text: $password)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .autocapitalization(.none)
                                }
                                Spacer()
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    
                    // هل نسيت كلمة المرور؟
                    Button(action: { showForgotPassword = true }) {
                        Text("هل نسيت كلمة المرور؟")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "#222B45"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.top, 2)
                    .sheet(isPresented: $showForgotPassword) {
                        ForgotPasswordView(isPresented: $showForgotPassword)
                    }

                    // زر تسجيل الدخول
                    Button {
                        keyIsFocused = false
                        Messaging.messaging().token { token, error in
                            if let error = error {
                                appRouter.toggleAppPopup(.alertError(LocalizedStringKey.error, error.localizedDescription))
                            } else if let token = token {
                                register(fcmToken: token)
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.primary())
                                .cornerRadius(12)
                        } else {
                            Text("تسجيل الدخول")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.primary())
                                .cornerRadius(12)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 3)
                    .disabled(viewModel.isLoading)
                    
                    // زر سجل الآن
                    Button(action: {
                        showCompanyRegisterSheet = true
                    }) {
                        Text("تسجيل الشركات")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#222B45"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(hex: "#F2F3F7"))
                            .cornerRadius(14)
                    }
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)

                    Spacer(minLength: 0)
                    
                    // تواصل معنا
                    HStack(spacing: 3) {
                        Text("هل تواجه مشكلة في تسجيل الدخول؟")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#666"))
                        Button(action: {
                            appRouter.navigate(to: .contactUs)
                        }) {
                            Text("تواصل معنا!")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.primary())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, 24)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $presentSheet) {
            NavigationStack {
                List(filteredResorts) { country in
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                            .font(.headline)
                        Spacer()
                        Text(country.dial_code)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        self.countryFlag = country.flag
                        self.countryCode = country.dial_code
                        presentSheet = false
                        searchCountry = ""
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchCountry, prompt: LocalizedStringKey.yourCountry)
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .sheet(isPresented: $showCompanyRegisterSheet) {
            CompanyRegisterView()
                .presentationDetents([.large, .medium])
                .presentationCornerRadius(22)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func getCompletePhoneNumber() -> String {
        completePhoneNumber = "\(countryCode)\(mobile)".replacingOccurrences(of: " ", with: "")
        if countryCode.hasPrefix("+") {
            completePhoneNumber = completePhoneNumber.replacingOccurrences(of: countryCode, with: String(countryCode.dropFirst()))
        }
        return completePhoneNumber
    }
    
    var filteredResorts: [CPData] {
        if searchCountry.isEmpty {
            return counrties
        } else {
            return counrties.filter { $0.name.contains(searchCountry) }
        }
    }
}

// دوال التسجيل الأصلية كما طلبت
extension LoginView {
    func register(fcmToken: String) {
        appState.phoneNumber = getCompletePhoneNumber()
        var params: [String: Any] = [
            "phone_number": getCompletePhoneNumber(),
            "password": password,
            "os": "IOS",
            "fcmToken": fcmToken,
            "lat": userLocation?.latitude ?? 0.0,
            "lng": userLocation?.longitude ?? 0.0,
        ]
        if let userLocation = userLocation {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            Utilities.getAddress(for: userLocation) { address in
                params["address"] = address
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                self.continueRegistration(with: params)
            }
        } else {
            continueRegistration(with: params)
        }
    }

    private func continueRegistration(with params: [String: Any]) {
        viewModel.registerUser(params: params) { id, token in
            appState.userId = id
            loginStatus = .verification
        }
    }
}

// شاشة استعادة كلمة المرور
struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    @State private var phone: String = ""
    @State var presentSheet = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("استعادة كلمة المرور")
                    .font(.title2.bold())
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding(.top, 40)
            
            MobileView(mobile: $phone, presentSheet: $presentSheet)
            
            Button {
                // أكشن الإرسال
                isPresented = false
            } label: {
                Text(LocalizedStringKey.send)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            Spacer()
        }
        .padding(24)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    LoginView(loginStatus: .constant(.login))
        .environmentObject(AppState())
        .environmentObject(UserSettings())
}
