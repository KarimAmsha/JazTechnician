//
// TabBarIcon.swift
// Fazaa
//
// Created by Karim Amsha on 28.04.2024.
//

import SwiftUI

struct TabBarIcon: View {
    @StateObject var appState: AppState
    let assignedPage: Page

    let width, height: CGFloat
    let iconName, tabName: String
    let isNotified: Bool?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundColor(appState.currentPage == assignedPage ? .white : .secondary().opacity(0.8))

            Text(tabName)
                .font(.footnote)
                .foregroundColor(appState.currentPage == assignedPage ? .white : .secondary())
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            appState.currentPage == assignedPage ? Color.secondary().opacity(0.9) : Color.clear
        )
        .cornerRadius(12)
        .onTapGesture {
            appState.currentPage = assignedPage
        }
    }
}

struct CustomTabBar: View {
    @StateObject var appState: AppState

    private var tabItems: [MainTabItem] {
        [
            MainTabItem(page: .home, iconSystemName: "house", title: "الرئيسية"),
            MainTabItem(page: .categories, iconSystemName: "archivebox", title: "التصنيفات"),
            MainTabItem(page: .orders, iconSystemName: "tray.full", title: "طلباتي"),
            MainTabItem(page: .chat, iconSystemName: "bubble.left.and.bubble.right", title: "الرسائل"),
            MainTabItem(page: .more, iconSystemName: "square.grid.2x2", title: "المزيد"),
        ]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \MainTabItem.page) { item in
                TabBarIcon(
                    appState: appState,
                    assignedPage: item.page,
                    width: 24,
                    height: 24,
                    iconName: item.iconSystemName,
                    tabName: item.title,
                    isNotified: item.isNotified
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
        .padding(.bottom, 8)
    }
}

#Preview {
    CustomTabBar(appState: AppState())
} 
