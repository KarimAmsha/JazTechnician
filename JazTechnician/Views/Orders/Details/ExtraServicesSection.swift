import SwiftUI

struct ExtraServicesSection: View {
    let existingServices: [SubCategory]
    @Binding var newServices: [SubCategory]
    let isEditable: Bool
    let availableExtras: [SubCategory]

    @State private var showExtrasSheet = false
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الخدمات الإضافية")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .padding(.bottom, 4)

            // عرض الخدمات القديمة
            if !existingServices.isEmpty {
                ForEach(existingServices) { service in
                    HStack {
                        Text(service.title ?? "خدمة إضافية")
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.black121212())
                        Spacer()
                        Text("\(String(format: "%.2f", service.price ?? 0)) ر.س")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.primary())
                    }
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(8)
                }
                Divider()
            }

            // الخدمات الجديدة (قابلة للحذف)
            if isEditable {
                ForEach(newServices) { service in
                    HStack {
                        Text(service.title ?? "خدمة إضافية")
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(String(format: "%.2f", service.price ?? 0)) ر.س")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.blue)
                        Button(action: {
                            if let idx = newServices.firstIndex(where: { $0.id == service.id }) {
                                newServices.remove(at: idx)
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.dangerNormal())
                        }
                    }
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.07))
                    .cornerRadius(8)
                }

                // زر الإضافة السفلي
                let remainingExtras = availableExtras.filter { extra in
                    !newServices.contains(where: { $0.id == extra.id }) &&
                    !existingServices.contains(where: { $0.id == extra.id })
                }
                Button(action: {
                    showExtrasSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("إضافة خدمة إضافية")
                            .customFont(weight: .medium, size: 14)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(remainingExtras.isEmpty ? Color.grayA1A1A1() : Color.primary())
                    .cornerRadius(10)
                    .opacity(remainingExtras.isEmpty ? 0.7 : 1)
                }
                .disabled(remainingExtras.isEmpty)
                .padding(.top, 8)
                .sheet(isPresented: $showExtrasSheet) {
                    VStack(spacing: 10) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 8)

                        Text("إضافة خدمة إضافية")
                            .customFont(weight: .semiBold, size: 16)
                            .foregroundColor(.primaryDark())

                        // مربع بحث (اختياري)
                        if remainingExtras.count > 7 {
                            TextField("ابحث عن خدمة...", text: $searchText)
                                .padding(10)
                                .background(Color.grayF5F5F5())
                                .cornerRadius(8)
                                .padding(.bottom, 2)
                        }

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(remainingExtras.filter {
                                    searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false)
                                }) { extra in
                                    Button {
                                        newServices.append(extra)
                                        showExtrasSheet = false
                                        searchText = ""
                                    } label: {
                                        HStack {
                                            Text(extra.title ?? "-")
                                                .foregroundColor(.primaryDark())
                                                .font(.system(size: 15, weight: .medium))
                                            Spacer()
                                            Text("\(String(format: "%.2f", extra.price ?? 0)) ر.س")
                                                .foregroundColor(.primary())
                                                .font(.system(size: 13))
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .frame(maxHeight: 350)

                        Button("إغلاق") {
                            showExtrasSheet = false
                            searchText = ""
                        }
                        .foregroundColor(.dangerNormal())
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white.ignoresSafeArea())
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(18)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 8)
        .animation(.easeInOut, value: newServices)
    }
}
