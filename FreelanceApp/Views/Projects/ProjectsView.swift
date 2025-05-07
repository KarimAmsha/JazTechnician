
import SwiftUI

struct ProjectsView: View {
    @State private var selectedTab: ProjectStatus = .inProgress
    @EnvironmentObject var appRouter: AppRouter
    @State private var showDelivery = false
    @State private var showRating = false
    @State private var showRejectionReason = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ForEach(ProjectStatus.allCases, id: \.self) { status in
                    VStack(spacing: 16) {
                        Button(action: {
                            selectedTab = status
                        }) {
                            Text(status.title)
                                .fontWeight(selectedTab == status ? .bold : .regular)
                                .foregroundColor(.black)
                        }
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == status ? Color.brown : .clear)
                    }
                }
            }
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<2) { _ in
                        ProjectCardView(status: selectedTab, showDelivery: $showDelivery, showRating: $showRating, showRejectionReason: $showRejectionReason)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDelivery) {
            DeliveryView(showModal: $showDelivery)
        }
        .sheet(isPresented: $showRating) {
            ServiceRatingView(showModal: $showRating)
        }
        .sheet(isPresented: $showRejectionReason) {
            RejectionReasonView(showModal: $showRejectionReason)
        }
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading) {
                    Text("📂 المشاريع")
                        .customFont(weight: .bold, size: 20)
                    Text("تحكم بجميع مشاريعك عبر المنصة!")
                        .customFont(weight: .regular, size: 10)
                }
                .foregroundColor(Color.black222020())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
    }
}

// MARK: - الحالات

enum ProjectStatus: String, CaseIterable {
    case inProgress, underReview, completed, cancelled

    var title: String {
        switch self {
        case .inProgress: return "قيد التنفيذ"
        case .underReview: return "قيد المراجعة"
        case .completed: return "المكتلة"
        case .cancelled: return "ملغية"
        }
    }
}

// MARK: - البطاقة

struct ProjectCardView: View {
    var status: ProjectStatus
    @Binding var showDelivery: Bool
    @Binding var showRating: Bool
    @Binding var showRejectionReason: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("اسم العميل").bold()
                Spacer()
                Text(statusLabel)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }

            Text("الخدمة: تصميم بوستات لمنصات السوشيال لليبيا و مواقع الويب")
                .font(.callout)

            HStack {
                Text("27 أكتوبر 2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\"تقييم 1400+ تقييم\"  ★ 4.5/5")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if status == .inProgress {
                HStack {
                    Button(action: {
                        showDelivery = true
                    }) {
                        Text("تسليم الخدمة")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary())
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Button(action: {}) {
                        Label("محادثة", systemImage: "bubble.left")
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
            } else if status == .underReview {
                Button(action: {}) {
                    Label("محادثة", systemImage: "bubble.left")
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            } else if status == .completed {
                Button(action: {
                    showRating = true
                }) {
                    Text("تقييم العميل")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary())
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else if status == .cancelled {
                Button(action: {
                    showRejectionReason = true
                }) {
                    Text("عرض سبب الرفض")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    var statusColor: Color {
        switch status {
        case .inProgress: return .blue
        case .underReview: return .orange
        case .completed: return .primary()
        case .cancelled: return .red
        }
    }

    var statusLabel: String {
        switch status {
        case .inProgress: return "قيد التنفيذ"
        case .underReview: return "قيد المراجعة"
        case .completed: return "مكتمل"
        case .cancelled: return "ملغي!"
        }
    }
}

#Preview {
    ProjectsView()
}
