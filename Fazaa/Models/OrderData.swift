//
//  OrderData.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 22.05.2025.
//

import CoreLocation

struct OrderData: Hashable {
    let services: [SelectedServiceItem]
    let address: AddressItem?                   // إذا العنوان من دفتر العناوين
    let userLocation: CLLocationCoordinate2D?   // إذا اختار الموقع الحالي
    let notes: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(services)
        hasher.combine(address?.id)
        hasher.combine(userLocation?.latitude)
        hasher.combine(userLocation?.longitude)
        hasher.combine(notes)
    }

    static func == (lhs: OrderData, rhs: OrderData) -> Bool {
        lhs.services == rhs.services &&
        lhs.address?.id == rhs.address?.id &&
        lhs.userLocation?.latitude == rhs.userLocation?.latitude &&
        lhs.userLocation?.longitude == rhs.userLocation?.longitude &&
        lhs.notes == rhs.notes
    }

    // تحويل الى JSON للAPI
    func toJson(couponCode: String, paymentType: String) -> [String: Any] {
        let extraItems: [[String: Any]] = services.map { item in
            [
                "sub_sub_id": item.item._id,
                "qty": item.quantity
            ]
        }
        let firstItem = services.first
        let subCategoryId = firstItem?.subCategoryId ?? ""
        let categoryId = firstItem?.categoryId ?? ""

        var dict: [String: Any] = [
            "couponCode": couponCode,
            "paymentType": paymentType,
            "address": address?.id ?? "",   // هنا دائماً يُرسل حتى لو فارغ
            "notes": notes,
            "extra": extraItems,
            "orderNo": "112233",
            "sub_category_id": subCategoryId,
            "category_id": categoryId
        ]
        if let address = address {
            dict["lat"] = address.lat ?? 0
            dict["lng"] = address.lng ?? 0
            dict["title"] = address.title ?? ""
            dict["streetName"] = address.streetName ?? ""
        } else if let userLoc = userLocation {
            dict["lat"] = userLoc.latitude
            dict["lng"] = userLoc.longitude
            dict["title"] = "موقعي الحالي"
            dict["streetName"] = ""
        }
        return dict
    }
}
