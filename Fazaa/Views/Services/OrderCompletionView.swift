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
    @State private var isCurrentLocationSelected: Bool = false
    @State private var isShowingAllAddresses = false
    
    @State private var serviceToDelete: SelectedServiceItem?
    @State private var showDeleteConfirmation = false
    @State private var selectedList: [SelectedServiceItem] = []
    @State private var miniMapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var miniMapCoordinate: CLLocationCoordinate2D? = nil
    
    init(selectedItems: [SelectedServiceItem]) {
        self.selectedItems = selectedItems
        _selectedList = State(initialValue: selectedItems)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("الخدمات المختارة")
                    .customFont(weight: .bold, size: 16)
                
                // تجميع العناصر حسب القسم
                let groupedItems = Dictionary(grouping: selectedList, by: { $0.subCategoryTitle })
                
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
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(total, specifier: "%.2f") SAR")
                                        .font(.footnote)
                                        .foregroundColor(.secondary())
                                    
                                    // 🗑 زر الحذف
                                    Button(action: {
                                        serviceToDelete = selected
                                        showDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Section(header: Text("اختر عنوان التنفيذ").font(.headline)) {
                    
                    // ✅ عرض العنوان المختار (إذا لم يكن من بين أول 3)
                    if let selected = selectedAddress,
                       !isCurrentLocationSelected,
                       !(userViewModel.addressBook ?? []).prefix(3).contains(where: { $0.id == selected.id }) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selected.title ?? "")
                                    .fontWeight(.medium)
                                Text(selected.address ?? "")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // ✅ موقعي الحالي
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
                    
                    // ✅ أول 3 عناوين
                    let addressList = userViewModel.addressBook ?? []
                    ForEach(addressList.prefix(3), id: \.id) { address in
                        AddressItemView(address: address, isSelected: selectedAddress?.id == address.id)
                            .onTapGesture {
                                withAnimation {
                                    selectedAddress = address
                                    isCurrentLocationSelected = false
                                }
                            }
                    }
                    
                    // ✅ عرض كل العناوين
                    if addressList.count > 3 {
                        Button("عرض كل العناوين") {
                            isShowingAllAddresses = true
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
                
                // ✅ إظهار الخريطة المصغرة
                if isCurrentLocationSelected, let loc = locationManager.location?.coordinate {
                    MiniMapView(coordinate: loc)
                } else if let address = selectedAddress,
                          let lat = address.lat,
                          let lng = address.lng {
                    MiniMapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                }
                
                NotesView(notes: $notes, placeholder: placeholder)
                
                Button(action: {
                    handleOrderSubmission()
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
            userViewModel.getAddressList()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                updateMiniMapLocation()
            }
        }
        .popup(isPresented: $showDeleteConfirmation) {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.yellow)
                
                Text("تأكيد الحذف")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("هل أنت متأكد من حذف هذه الخدمة؟")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Button("إلغاء") {
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    
                    Button("حذف") {
                        if let toDelete = serviceToDelete {
                            removeService(item: toDelete)
                        }
                        showDeleteConfirmation = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.9))
            .cornerRadius(16)
            .padding(.horizontal, 24)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.5))
                .isOpaque(true)
        }
        .sheet(isPresented: $isShowingAllAddresses) {
            NavigationView {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(userViewModel.addressBook ?? [], id: \.id) { address in
                            AddressItemView(address: address, isSelected: selectedAddress?.id == address.id)
                                .padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        selectedAddress = address
                                        isCurrentLocationSelected = false
                                        isShowingAllAddresses = false
                                    }
                                }
                            Divider()
                        }
                    }
                    .padding(.top)
                }
                .navigationTitle("كل العناوين")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("إغلاق") {
                            isShowingAllAddresses = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            MessageAlertObserverView(
                message: $userViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
    
    @ViewBuilder
    func addressCell(_ address: AddressItem) -> some View {
        Button(action: {
            selectedAddress = address
            isCurrentLocationSelected = false
        }) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: selectedAddress?.id == address.id ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(.primary)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(address.title ?? "")
                            .fontWeight(.medium)
                            .foregroundColor(.black121212())
                        if let type = address.addressType?.rawValue {
                            Text("(\(type))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    Text(address.address ?? "")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }
    
    func updateMiniMapLocation() {
        if isCurrentLocationSelected {
            miniMapCoordinate = locationManager.location?.coordinate
            if let loc = miniMapCoordinate {
                miniMapRegion.center = loc
            }
        } else if let selected = selectedAddress, let lat = selected.lat, let lng = selected.lng {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            miniMapCoordinate = coord
            miniMapRegion.center = coord
        }
    }
}

#Preview {
    OrderCompletionView(selectedItems: [])
        .environmentObject(AppRouter())
}

extension OrderCompletionView {
    func removeService(item: SelectedServiceItem) {
        withAnimation {
            selectedList.removeAll { $0.id == item.id && $0.subCategoryTitle == item.subCategoryTitle }
        }

        // ✅ الرجوع في حال لم يتبق أي عنصر
        if selectedList.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appRouter.navigateBack()
            }
        }
    }

    func prepareOrderData() -> OrderData {
        let notesText = notes.isEmpty || notes == placeholder ? "" : notes
        let addressValue = isCurrentLocationSelected ? nil : selectedAddress
        let userLoc = isCurrentLocationSelected ? locationManager.location?.coordinate : nil
        
        return OrderData(
            services: selectedList,
            address: addressValue,
            userLocation: userLoc,
            notes: notesText
        )
    }

    func handleOrderSubmission() {
        guard !selectedList.isEmpty else {
            orderViewModel.errorMessage = "يرجى اختيار خدمة واحدة على الأقل"
            return
        }
        
        var lat: Double? = nil
        var lng: Double? = nil
        
        if isCurrentLocationSelected {
            lat = locationManager.location?.coordinate.latitude
            lng = locationManager.location?.coordinate.longitude
        } else if let address = selectedAddress {
            lat = address.lat
            lng = address.lng
        }
        
        guard let finalLat = lat, let finalLng = lng else {
            orderViewModel.errorMessage = "تعذر تحديد الموقع"
            return
        }
        
        let params: [String: Any] = ["lat": finalLat, "lng": finalLng]
        
        orderViewModel.checkPlace(params: params) { message in
            let orderData = prepareOrderData()
            appRouter.navigate(to: .paymentCheckout(orderData: orderData))
        }
    }
}

struct AddressItemView: View {
    let address: AddressItem
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundColor(.primary)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(address.title ?? "")
                        .fontWeight(.medium)
                    if let type = address.addressType?.rawValue {
                        Text("(\(type))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                Text(address.address ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}

struct MiniMapView: View {
    let coordinate: CLLocationCoordinate2D

    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: coordinate)]) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .blue)
        }
        .frame(height: 150)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private struct MapPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}
