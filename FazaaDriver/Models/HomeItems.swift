//
//  HomeItems.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

struct HomeSection: Codable, Hashable, Identifiable {
    var id: String { type }
    let type: String
    let action: String?
    let title: String
    let data: [HomeItem]?
}

struct HomeItem: Codable, Hashable, Identifiable {
    let _id: String
    var id: String { _id }

    let title: String?
    let description: String?
    let image: String?
    let type: String
}
