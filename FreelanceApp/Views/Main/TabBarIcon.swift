//
//  TabBarIcon.swift
//  Wishy
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI

struct TabBarIcon: View {
    
    @StateObject var appState: AppState
    let assignedPage: Page
    @ObservedObject private var settings = UserSettings()
    @ObservedObject private var cartViewModel = CartViewModel(errorHandling: ErrorHandling())

    let width, height: CGFloat
    let iconName, tabName: String
    let isAddButton: Bool
    @State var count: Int?
    let isCart: Bool?

    var body: some View {
        VStack(spacing: 0) {
            if isAddButton {
                HStack {
                    Spacer()
                    
                    ZStack {
                        Text("+")
                            .customFont(weight: .bold, size: 13)
                            .foregroundColor(appState.currentPage == assignedPage ? Color.primary() : Color.gray595959())
                    }
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(appState.currentPage == assignedPage ? Color.primary() : Color.gray595959(), lineWidth: 2)
                    )
                    .padding(10)

                    Spacer()
                }
            } else {
                ZStack {
                    if isCart ?? false && count != 0 {
                        Text(count?.toString() ?? "")
                            .customFont(weight: .medium, size: 15)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .padding(.leading, 20)
                            .padding(.bottom, 60)
                    }
                    
                    VStack(spacing: 8) {
                        Image(appState.currentPage == assignedPage ? "\(iconName)_s" : iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)

                        
                        Text(tabName)
                            .customFont(weight: appState.currentPage == assignedPage ? .bold : .regular, size: 12)
                            .foregroundColor(appState.currentPage == assignedPage ? .primary() : .primaryBlack())
                    }
                }
            }
        }
//        .frame(width: width, height: height)
        .onTapGesture {
            appState.currentPage = assignedPage
        }
        .onReceive(cartViewModel.$cartCount) { newCount in
            // This block will execute whenever cartCount changes
            cartViewModel.cartCount {
                self.count = cartViewModel.cartCount
            }
        }
        .onAppear {
            cartViewModel.cartCount {
                self.count = cartViewModel.cartCount
            }
        }
    }
}

#Preview {
    TabBarIcon(appState: AppState(), assignedPage: .home, width: 38, height: 38, iconName: "ic_home", tabName: LocalizedStringKey.home, isAddButton: false, count: 0, isCart: false)
}

