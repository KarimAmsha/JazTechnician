//
//  ChangePasswordView.swift
//  JazTechnician
//
//  Created by Karim OTHMAN on 11.07.2025.
//

import SwiftUI
import Alamofire

struct ChangePasswordView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = ChangePasswordViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                VStack(spacing: 18) {
                    SecureInputField(
                        title: "كلمة المرور الحالية",
                        text: $viewModel.oldPassword,
                        icon: "lock"
                    )
                    
                    SecureInputField(
                        title: "كلمة المرور الجديدة",
                        text: $viewModel.newPassword,
                        icon: "lock.rotation"
                    )
                    
                    SecureInputField(
                        title: "تأكيد كلمة المرور الجديدة",
                        text: $viewModel.confirmPassword,
                        icon: "lock.shield"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)
                
                Spacer()
                
                Button(action: {
                    viewModel.changePassword(userId: UserSettings.shared.id ?? "")
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("حفظ كلمة المرور")
                            .customFont(weight: .bold, size: 15)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary())
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
            .navigationBarBackButtonHidden()
            .background(Color.background().ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            appRouter.navigateBack()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.primaryDark())
                        }
                        Text("تغيير كلمة المرور")
                            .customFont(weight: .semiBold, size: 18)
                            .foregroundColor(.primaryDark())
                    }
                }
            }
            
            if let error = viewModel.errorMessage {
                CustomErrorAlert(message: error) {
                    viewModel.errorMessage = nil
                }
                .zIndex(10)
            }
            
            if viewModel.showSuccess {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)

                SuccessModalView(
                    onDismiss: {
                        viewModel.showSuccess = false
                        appRouter.navigateBack()
                    }
                )
                .zIndex(2)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: viewModel.showSuccess)
        .animation(.easeInOut, value: viewModel.isLoading)
    }
}

// MARK: - SecureInputField

struct SecureInputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    @State private var isSecure = true

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.grayA1A1A1())
            if isSecure {
                SecureField(title, text: $text)
                    .customFont(weight: .regular, size: 14)
            } else {
                TextField(title, text: $text)
                    .customFont(weight: .regular, size: 14)
            }
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.grayA1A1A1())
            }
        }
        .padding()
        .background(Color.grayF5F5F5())
        .cornerRadius(10)
    }
}

// MARK: - ViewModel

class ChangePasswordViewModel: ObservableObject {
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    var isValid: Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 6
    }
    
    func changePassword(userId: String) {
        guard isValid else {
            errorMessage = "تأكد من صحة البيانات"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let url = "\(Constants.baseURL)/mobile/driver/change/\(userId)"
        let parameters: [String: String] = [
            "old_password": oldPassword,
            "password": newPassword
        ]
        let headers: HTTPHeaders = [
            "Accept": "application/json"
            // أضف أي هيدرز مطلوبة (Authorization ...) حسب مشروعك
        ]
        
        AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        )
        .validate()
        .response { response in
            self.isLoading = false
            if let data = response.data {
                // يمكنك هنا فك الـ JSON لو فيه رسالة معينة
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    print("Message: \(message)")
                    self.showSuccess = true
                } else {
                    self.showSuccess = true
                }
            } else if let error = response.error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ChangePasswordView().environmentObject(AppRouter())
}

struct SuccessModalView: View {
    var title: String = "تم تغيير كلمة المرور"
    var message: String = "تم تحديث كلمة المرور بنجاح."
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .frame(width: 54, height: 54)
                .foregroundColor(.green)
                .padding(.top, 18)
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.green)
            
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
            
            Button(action: {
                onDismiss?()
            }) {
                Text("موافق")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 38)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            Spacer(minLength: 6)
        }
        .padding(26)
        .background(.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 4)
        .frame(maxWidth: 350)
        .transition(.scale.combined(with: .opacity))
    }
}
