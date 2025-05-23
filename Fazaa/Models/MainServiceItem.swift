//
//  MainServiceItem.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 21.05.2025.
//

struct MainServiceItem: Codable, Identifiable, Hashable {
    let _id: String
    var id: String { _id }
    let title: String
    let description: String
    let image: String
    let type: String
    let category: [SubCategoryItem]?
}

struct SubCategoryItem: Codable, Identifiable, Hashable, Equatable {
    let _id: String
    var id: String { _id }
    let title: String
    let description: String
    let image: String
    let type: String
    let sub: [SubSubCategoryItem]?
}

struct SubSubCategoryItem: Codable, Hashable, Identifiable, Equatable {
    let _id: String
    var id: String { _id }
    let price: Double
    let title: String
    let description: String
    let image: String
    let type: String
}

struct SelectedServiceItem: Identifiable, Hashable {
    let item: SubSubCategoryItem
    let quantity: Int
    let subCategoryTitle: String
    let categoryId: String      // main_category_id
    let subCategoryId: String   // sub_category_id

    var id: String { item._id }
}
