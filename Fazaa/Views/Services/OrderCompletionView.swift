//
//  OrderCompletionView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 21.05.2025.
//

//  OrderCompletionView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 21.05.2025.

import SwiftUI
import MapKit
import PopupView

struct OrderCompletionView: View {
    let selectedItems: [SelectedServiceItem]

    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject private var locationManager = LocationManager2()

    @State private var selectedAddress: AddressItem? = nil
    @State private var currentUserLocation: AddressItem? = nil
    @State private var isShowingAddress = false
    @State private var isAddressBook = false
    @State private var addressTitle = ""
    @State private var notes = LocalizedStringKey.notes
    let placeholder = LocalizedStringKey.notes
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locations: [Mark] = []
    @State private var isCurrentLocationSelected: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("الخدمات المختارة")
                    .customFont(weight: .bold, size: 16)

                // تجميع العناصر المختارة حسب عنوان القسم الفرعي
                let groupedItems = Dictionary(grouping: selectedItems, by: { $0.subCategoryTitle })

                ForEach(groupedItems.keys.sorted(), id: \.self) { categoryTitle in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(categoryTitle)
                            .customFont(weight: .medium, size: 14)
                            .foregroundColor(.gray)

                        ForEach(groupedItems[categoryTitle] ?? []) { selected in
                            let item = selected.item
                            let quantity = selected.quantity
                            let total = item.price * Double(quantity)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .customFont(weight: .medium, size: 14)
                                    Text("الكمية: \(quantity)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("\(total, specifier: "%.2f") SAR")
                                    .font(.footnote)
                                    .foregroundColor(.secondary())
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }

                Section(header: Text("اختر عنوان التنفيذ").font(.headline)) {

                    // 🟢 خيار: موقعي الحالي
                    Button(action: {
                        selectedAddress = nil
                        isCurrentLocationSelected = true
                    }) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: isCurrentLocationSelected ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.primary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("موقعي الحالي")
                                    .fontWeight(.medium)
                                Text(locationManager.address.isEmpty ? "جارٍ تحديد الموقع..." : locationManager.address)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }

                    Divider()

                    // 🟢 خيارات: دفتر العناوين
                    ForEach(userViewModel.addressBook ?? [], id: \.id) { address in
                        Button(action: {
                            selectedAddress = address
                            isCurrentLocationSelected = false
                        }) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: selectedAddress?.id == address.id ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.primary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(address.title ?? "")
                                        .fontWeight(.medium)
                                    Text(address.address ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                    }
                }

                NotesView(notes: $notes, placeholder: placeholder)

                Button(action: {
                    if selectedItems.isEmpty {
                        orderViewModel.errorMessage = "يرجى اختيار خدمة واحدة على الأقل"
                        return
                    }

                    // Call place order here or navigate to next screen
                    appRouter.navigate(to: .paymentSuccess)
                }) {
                    Text("استكمال الطلب")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary())
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle("تفاصيل الطلب", displayMode: .inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("ic_back")
                    .onTapGesture {
                        appRouter.navigateBack()
                    }
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            userViewModel.getAddressByType(type: "")
        }
        .popup(isPresented: $isShowingAddress) {
            let model = CustomModel(
                title: "دفتر العناوين",
                content: "",
                items: userViewModel.addressBook ?? [],
                onSelect: { item in
                    DispatchQueue.main.async {
                        selectedAddress = item
                        addressTitle = item.title ?? ""
                        isShowingAddress = false
                        isAddressBook = true
                    }
                })

            AddressListView(customModel: model, currentUserLocation: $currentUserLocation, isAddressBook: $isAddressBook)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(Color.black.opacity(0.8))
                .isOpaque(true)
        }
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
}

#Preview {
    OrderCompletionView(selectedItems: [])
        .environmentObject(AppRouter())
}

extension OrderCompletionView {
    func add() {
        if isCurrentLocationSelected {
            let lat = locationManager.location?.coordinate.latitude
            let lng = locationManager.location?.coordinate.longitude
            // أرسل lat/lng أو العنوان النصي
        } else if let selected = selectedAddress {
            let lat = selected.lat
            let lng = selected.lng
            let addressId = selected.id
            // أرسل ID أو بيانات العنوان المختار
        } else {
            orderViewModel.errorMessage = "يرجى اختيار عنوان تنفيذ الطلب"
        }
    }
}
