//
//  SubSubCategoryView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 21.05.2025.
//

import SwiftUI
import PopupView

struct SelectableSubSubCategory: Identifiable, Hashable {
    let item: SubSubCategoryItem
    var quantity: Int = 1
    var isSelected: Bool = false

    var id: String { item._id }
}

import SwiftUI

struct SubSubCategoryView: View {
    let title: String
    let items: [SubSubCategoryItem]
    let mainCategoryId: String
    let subCategoryId: String

    @EnvironmentObject var appRouter: AppRouter
    @State private var selectedItems: [String: Int] = [:]
    @State private var showValidationAlert = false

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items, id: \._id) { item in
                        let isSelected = selectedItems[item._id] != nil
                        let quantity = selectedItems[item._id] ?? 1
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(item.price, specifier: "%.0f") SAR")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Text(item.title)
                                        .font(.headline)
                                    
                                    Text(item.description)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                AsyncImage(url: URL(string: item.image)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 60, height: 60)
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(10)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            HStack {
                                Text("الكمية")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Button(action: {
                                        if let current = selectedItems[item._id], current > 1 {
                                            selectedItems[item._id] = current - 1
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .frame(width: 30, height: 30)
                                    }
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                    
                                    Text("\(quantity)")
                                        .frame(width: 30)
                                    
                                    Button(action: {
                                        selectedItems[item._id] = quantity + 1
                                    }) {
                                        Image(systemName: "plus")
                                            .frame(width: 30, height: 30)
                                    }
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? Color.secondary() : Color.gray.opacity(0.1))
                        .foregroundColor(isSelected ? .white : .black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onTapGesture {
                            if isSelected {
                                selectedItems[item._id] = nil
                            } else {
                                selectedItems[item._id] = 1
                            }
                        }
                    }
                }
                .padding(.top)
            }
            
            Button(action: {
                let selected = items.filter { selectedItems[$0._id] != nil }

                if selected.isEmpty {
                    showValidationAlert = true
                } else {
                    appRouter.navigate(to: .orderCompletion(
                        selectedItems: selected.map {
                            SelectedServiceItem(
                                item: $0,
                                quantity: selectedItems[$0._id] ?? 1,
                                subCategoryTitle: title,
                                categoryId: mainCategoryId,       // ببساطة مرر المتغير
                                subCategoryId: subCategoryId      // مرر المتغير
                            )
                        }
                    ))
                }
            }) {
                Text("استكمال الطلب")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .popup(isPresented: $showValidationAlert) {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    Text("تنبيه")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("يرجى اختيار خدمة واحدة على الأقل")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primary())
                .cornerRadius(12)
                .padding(.horizontal, 24)
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .closeOnTap(false)
                    .backgroundColor(Color.black.opacity(0.6))
                    .isOpaque(true)
                    .useKeyboardSafeArea(true)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("ic_back")
                    .onTapGesture {
                        appRouter.navigateBack()
                    }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
}

#Preview {
    SubSubCategoryView(title: "مكيف دولابي", items: [], mainCategoryId: "", subCategoryId: "")
        .environmentObject(AppRouter())
}
