//
//  OrderDetails.swift
//  Wishy
//
//  Created by Karim Amsha on 29.05.2024.
//

// MARK: - OrderDetails Model
struct OrderDetails: Codable, Identifiable {
    var id: String?
    let orderNo: String?
    let tax: Double?
    let deliveryCost: Double?
    let netTotal: Double?
    let total: Double?
    let totalDiscount: Double?
    let adminTotal: Double?
    let providerTotal: Double?
    let status: String?
    let dtDate: String?
    let dtTime: String?
    let lat: Double?
    let lng: Double?
    let paymentType: String?
    let couponCode: String?
    let userId: User?
    let createAt: String?
    let items: [OrderProducts]?
    let address: String?
    let orderType: Int?
    let isAddressBook: Bool?
    let addressBook: AddressBook?
    
    var formattedCreateDate: String? {
        guard let dtDate = dtDate else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var orderStatus: OrderStatus? {
        return OrderStatus(rawValue: status ?? "")
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id", orderNo = "Order_no", tax = "Tax", deliveryCost = "DeliveryCost", netTotal = "NetTotal", total = "Total", totalDiscount = "TotalDiscount", adminTotal = "Admin_Total", providerTotal = "provider_Total", status = "Status", dtDate = "dt_date", dtTime = "dt_time", lat, lng, paymentType = "PaymentType", couponCode, userId = "user_id", createAt, items, address, orderType = "OrderType", isAddressBook = "is_address_book", addressBook = "address_book"
    }
}

struct OrderBody: Codable, Identifiable {
    var id: String? { _id }
    let _id: String?

    let new_total: Double?
    let new_tax: Double?
    let extra: [SubCategory]?           // مصفوفة فاضية أو عناصر SubCategory حسب الداتا
    let update_code: String?
    let provider_total: Double?
    let admin_total: Double?
    let lat: Double?
    let lng: Double?
    let price: Double?
    let address: OrderAddress?
    let order_no: String?
    let tax: Double?
    let total: Double?
    let totalDiscount: Double?
    let netTotal: Double?
    var status: String?
    let createAt: String?
    let period: Int?
    let dt_date: String?
    let dt_time: String?
    let sub_category_id: SubCategory?
    let category_id: Category?
    let couponCode: String?
    let paymentType: String?
    let user: User?
    let notes: String?
    let canceled_note: String?
    let employee: Employee?
    let provider: Provider?
    let supervisor: String?     // هو عبارة عن ID string
    let place: String?
    let loc: LocationPoint?

    var orderStatus: OrderStatus? {
        return OrderStatus(rawValue: status ?? "")
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var formattedOrderDate: String? {
        guard let dtDate = dt_date else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
