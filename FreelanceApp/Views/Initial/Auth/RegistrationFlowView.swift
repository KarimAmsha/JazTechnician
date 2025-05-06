import SwiftUI

enum RegistrationStep: Int, CaseIterable {
    case role, personalInfo, workInfo, identity, confirmPhone, success
}

struct RegistrationFlowView: View {
    @State private var selectedRole: UserRole? = .provider
    @State private var step: RegistrationStep = .role
    @State private var showSpecialtyPopup = false

    var body: some View {
        VStack(spacing: 0) {
            StepTabsView(currentStep: step)
                .padding(.top)

            Spacer()

            ZStack {
                switch step {
                case .role:
                    RegistrationRoleView(selectedRole: $selectedRole)
                case .personalInfo:
                    RegistrationPersonalInfoView()
                case .workInfo:
                    RegistrationWorkInfoView(showSpecialtyPopup: $showSpecialtyPopup)
                case .identity:
                    RegistrationIdentityView()
                case .confirmPhone:
                    ConfirmPhoneView()
                case .success:
                    SuccessSubmissionView()
                }
            }
            .animation(.easeInOut, value: step)
            .transition(.slide)

            Spacer()

            if step != .success {
                HStack(spacing: 12) {
                    if step != .role {
                        SecondaryActionButton(title: "رجوع") {
                            goToPrevious()
                        }
                    }
                    PrimaryActionButton(title: step == .confirmPhone ? "إتمام الطلب" : "التالي") {
                        goToNext()
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal)
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
        .popup(isPresented: $showSpecialtyPopup) {
            SpecialtySelectionPopup(isPresented: $showSpecialtyPopup)
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(true)
                .backgroundColor(Color.black.opacity(0.5))
                .useKeyboardSafeArea(true)
        }
    }

    private func goToNext() {
        if let nextStep = RegistrationStep(rawValue: step.rawValue + 1) {
            step = nextStep
        }
    }

    private func goToPrevious() {
        if let previousStep = RegistrationStep(rawValue: step.rawValue - 1) {
            step = previousStep
        }
    }
}

struct StepTabsView: View {
    var currentStep: RegistrationStep

    var body: some View {
        HStack(spacing: 4) {
            ForEach(RegistrationStep.allCases.prefix(5), id: \.self) { step in
                Rectangle()
                    .fill(color(for: step))
                    .frame(height: 4)
            }
        }
    }

    private func color(for step: RegistrationStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return Color(hex: "F8B22A")
        } else if step == currentStep {
            return Color.primary()
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

#Preview {
    RegistrationFlowView()
}
