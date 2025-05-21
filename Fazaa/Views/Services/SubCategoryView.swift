//
//  SubCategoryView.swift
//  Fazaa
//
//  Created by Karim OTHMAN on 21.05.2025.
//

import SwiftUI

struct SubCategoryView: View {
    let title: String
    let categoryId: String

    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = InitialViewModel(errorHandling: ErrorHandling())

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if viewModel.subCategories.isEmpty {
                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
            } else {
                let categories = viewModel.subCategories

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categories, id: \.id) { item in
                        VStack(spacing: 8) {
                            VStack {
                                AsyncImage(url: URL(string: item.image)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(height: 60)
                                    case .success(let image):
                                        image.resizable().scaledToFit().frame(height: 60)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                            Text(item.title)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(height: 36)
                        }
                        .onTapGesture {
                            appRouter.navigate(to: .subSubCategory(item))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.getSubCategories(q: "", id: categoryId)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("ic_back")
                    .onTapGesture {
                        appRouter.navigateBack()
                    }
            }
        }
        .background(Color.white)
    }
}

#Preview {
    SubCategoryView(title: "خدمات الكهرباء", categoryId: "65f7224c1bbbbe3b513694e9")
        .environmentObject(AppRouter())
}
