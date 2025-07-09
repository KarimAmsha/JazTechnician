import SwiftUI

struct CompanyRegisterView: View {
    @State private var phoneNumber: String = ""
    @State private var companyName: String = ""
    @State private var email: String = ""

    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?
    @StateObject private var locationManager = LocationManager()

    enum Field { case phone, name, email }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    Text("تسجيل شركة جديدة")
                        .customFont(weight: .semiBold, size: 19)
                        .foregroundColor(.primaryDark())
                        .padding(.top, 8)

                    formField(
                        title: "اسم الشركة",
                        systemIcon: "building.2.crop.circle",
                        text: $companyName,
                        field: .name
                    )

                    formField(
                        title: "رقم الجوال",
                        systemIcon: "phone.fill",
                        text: $phoneNumber,
                        keyboardType: .numberPad,
                        field: .phone
                    )

                    formField(
                        title: "البريد الإلكتروني",
                        systemIcon: "envelope.fill",
                        text: $email,
                        keyboardType: .emailAddress,
                        field: .email
                    )

                    // موقع الشركة (غير قابل للتعديل)
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.primary())
                            Text("الموقع الجغرافي")
                                .customFont(weight: .medium, size: 14)
                                .foregroundColor(.primaryDark())
                        }
                        HStack(spacing: 12) {
                            VStack(alignment: .trailing) {
                                Text("Latitude")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.grayA1A1A1())
                                Text(locationManager.lat != nil ? String(format: "%.6f", locationManager.lat!) : "--")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black121212())
                            }
                            VStack(alignment: .trailing) {
                                Text("Longitude")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.grayA1A1A1())
                                Text(locationManager.lng != nil ? String(format: "%.6f", locationManager.lng!) : "--")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black121212())
                            }
                        }
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("العنوان")
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.grayA1A1A1())
                            Text(locationManager.address.isEmpty ? "جارٍ تحديد العنوان..." : locationManager.address)
                                .customFont(weight: .regular, size: 14)
                                .foregroundColor(.black121212())
                                .lineLimit(3)
                                .multilineTextAlignment(.trailing)
                        }
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("تحديد موقعي الحالي")
                            }
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.primary())
                            .padding(8)
                            .background(Color.grayF5F5F5())
                            .cornerRadius(8)
                        }
                    }
                    .padding(10)
                    .background(Color.grayEFEFEF())
                    .cornerRadius(12)

                    if let error = errorMessage {
                        Text(error)
                            .customFont(weight: .regular, size: 13)
                            .foregroundColor(.dangerNormal())
                            .padding(.top, 2)
                    }

                    Button(action: submit) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("تسجيل الشركة")
                                .customFont(weight: .medium, size: 16)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.primary() : Color.grayDCDCDC())
                    .cornerRadius(12)
                    .disabled(!isFormValid || isSubmitting)
                    .padding(.vertical, 8)
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }

    // MARK: - Helpers

    func formField(title: String, systemIcon: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, field: Field) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Image(systemName: systemIcon)
                    .foregroundColor(.primary())
                Text(title)
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
            }
            TextField(title, text: text)
                .customFont(weight: .regular, size: 14)
                .foregroundColor(.black121212())
                .padding(10)
                .background(Color.grayF5F5F5())
                .cornerRadius(10)
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
        }
    }

    var isFormValid: Bool {
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !companyName.trimmingCharacters(in: .whitespaces).isEmpty &&
        locationManager.lat != nil &&
        locationManager.lng != nil &&
        !locationManager.address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        phoneNumber.count >= 9
    }

    func submit() {
        guard isFormValid else {
            errorMessage = "يرجى تعبئة جميع الحقول بشكل صحيح"
            return
        }
        errorMessage = nil
        isSubmitting = true

        // هنا مكان اتصالك بالـ API
        // أرسل:
        // phone_number: phoneNumber
        // company_name: companyName
        // lat: locationManager.lat
        // lng: locationManager.lng
        // address: locationManager.address
        // email: email

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSubmitting = false
            errorMessage = "تم تسجيل الشركة بنجاح!"
        }
    }
}
