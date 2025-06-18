//
//  Order.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import Foundation

// MARK: - OrderResponse
struct OrderResponse: Codable {
    let items: [OrderModel]?
    let statusCode: Int?
    let message: String?
    let messageAr: String?
    let messageEn: String?
    let pagination: Pagination?
    
    enum CodingKeys: String, CodingKey {
        case items
        case statusCode = "status_code"
        case message
        case messageAr = "messageAr"
        case messageEn = "messageEn"
        case pagination = "pagenation"
    }
}

struct OrderModel: Codable, Identifiable {
    var couponCode: String?
    var dtDate: String?
    var dtTime: String?
    var title: String?
    var address: String?
    var streetName: String?
    var buildingNo: String?
    var floorNo: String?
    var flatNo: String?
    var notes: String?
    var categoryId: String?
    var subCategoryId: String?
    var paymentType: String?
    var lat: Double?
    var lng: Double?
    var id: String?             // مطابق لـ id في كوتلن
    var status: String?
    var canceledNote: String?
    var updateCode: String?
    var rateFromUser: String?
    var noteFromUser: String?
    var coupon: String?
    var orderNo: String?
    var extra: [ExtraBody]?     // هنا Array وليس MutableList
    var user: User?
    var provider: User?
}

struct ExtraBody: Codable {
    var subSubCategoryId: String?
    var qty: Int?

    enum CodingKeys: String, CodingKey {
        case subSubCategoryId = "sub_sub_id"
        case qty
    }
}

extension ExtraBody {
    static let mock = ExtraBody(subSubCategoryId: "sub_sub_1", qty: 2)
    static let mock2 = ExtraBody(subSubCategoryId: "sub_sub_2", qty: 5)
}

// MARK: - Mock للمعاينة فقط
extension OrderModel {
    static let mock = OrderModel(
        couponCode: "FAZAA50",
        dtDate: "2024-06-19",
        dtTime: "16:20",
        title: "صيانة كهرباء",
        address: "الرياض، حي العليا، شارع الملك فهد",
        streetName: "شارع الملك فهد",
        buildingNo: "17A",
        floorNo: "2",
        flatNo: "6",
        notes: "يرجى الاتصال قبل الوصول.",
        categoryId: "cat1",
        subCategoryId: "sub1",
        paymentType: "online",
        lat: 24.7136,
        lng: 46.6753,
        id: "order_1",
        status: "accepted",
        canceledNote: "",
        updateCode: "update123",
        rateFromUser: "5",
        noteFromUser: "ممتاز جداً",
        coupon: "FAZAA2024",
        orderNo: "ORD-1122",
        extra: [ExtraBody.mock, ExtraBody.mock2]
    )
}

struct AddressBook: Codable, Identifiable {
    var id: String?
    var streetName: String?
    var floorNo: String?
    var buildingNo: String?
    var flatNo: String?
    var type: AddressType?
    var createAt: String?
    var title: String?
    var lat: Double?
    var lng: Double?
    var address: String?
    var userId: String?
    var discount: Double?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case streetName = "streetName"
        case floorNo = "floorNo"
        case buildingNo = "buildingNo"
        case flatNo = "flatNo"
        case type = "type"
        case createAt = "createAt"
        case title = "title"
        case lat = "lat"
        case lng = "lng"
        case address = "address"
        case userId = "user_id"
        case discount = "discount"
    }
}

enum AddressType: String, Codable {
    case home
    case work
    case other
}

struct OrderCreatedModel: Codable {
    let id: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}

struct Order: Codable, Identifiable, Hashable {
    var id: String?                   // "_id"
    var lat: Double?
    var lng: Double?
    var price: Double?
    var tax: Double?
    var total: Double?
    var netTotal: Double?
    var totalDiscount: Double?
    var address: AddressItem?
    var orderNo: String?
    var status: String?
    var createAt: String?
    var dtDate: String?
    var dtTime: String?
    var subCategory: SubCategoryItem?
    var category: MainCategory?
    var couponCode: String?
    var paymentType: String?
    var user: User?
    var notes: String?
    var canceledNote: String?
    var employee: User?
    var provider: User?
    var extra: [Category]?
    var accpeted: String?
    var progress: String?
    var finished: String?
    var cancelded: String?
    var newTotal: Double?
    var newTax: Double?
    var points: Int?
    var title: String?  // هذا ليس في الداتا لكنه كان في الكلاس الكوتلن

    // CodingKeys to map JSON fields to Swift properties
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case lat
        case lng
        case price
        case tax
        case total
        case netTotal
        case totalDiscount
        case address
        case orderNo = "order_no"
        case status
        case createAt
        case dtDate = "dt_date"
        case dtTime = "dt_time"
        case subCategory = "sub_category_id"
        case category = "category_id"
        case couponCode
        case paymentType
        case user
        case notes
        case canceledNote = "canceled_note"
        case employee
        case provider
        case extra
        case accpeted
        case progress
        case finished
        case cancelded
        case newTotal
        case newTax
        case points
        case title
    }
    
    var orderStatus: OrderStatus {
        OrderStatus(self.status ?? "new")
    }
}
