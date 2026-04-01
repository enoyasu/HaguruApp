import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String

    @State private var selectedRole: UserRole?
    @State private var isLoading = false
    @State private var error: String?

    private let repo = UserRepository()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: HaguruSpacing.xl) {
                // Header
                VStack(spacing: HaguruSpacing.sm) {
                    Text("🤝")
                        .font(.system(size: 56))

                    VStack(spacing: HaguruSpacing.xs) {
                        Text("どちらとして使いますか？")
                            .font(HaguruFont.title2())
                            .foregroundColor(HaguruColors.textMain)
                            .multilineTextAlignment(.center)

                        Text("あとから変更はできません")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)
                    }
                }

                // Role cards
                VStack(spacing: HaguruSpacing.sm) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        roleCard(role)
                    }
                }

                if let error {
                    HaguruErrorBanner(message: error) { self.error = nil }
                }
            }
            .padding(.horizontal, HaguruSpacing.lg)

            Spacer()

            PrimaryButton(
                title: "つぎへ",
                isLoading: isLoading,
                isDisabled: selectedRole == nil
            ) {
                Task { await saveRole() }
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .padding(.bottom, HaguruSpacing.xl)
        }
        .background(HaguruColors.background.ignoresSafeArea())
    }

    private func roleCard(_ role: UserRole) -> some View {
        let isSelected = selectedRole == role

        return Button {
            withAnimation(HaguruAnimation.spring) {
                selectedRole = role
            }
        } label: {
            HStack(spacing: HaguruSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? HaguruColors.primary.opacity(0.15) : HaguruColors.surfaceGreen)
                        .frame(width: 52, height: 52)

                    Image(systemName: role.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? HaguruColors.primary : HaguruColors.textSub)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(role.displayName)
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)

                    Text(role.description)
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? HaguruColors.primary : HaguruColors.divider)
            }
            .padding(HaguruSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .fill(HaguruColors.card)
                    .shadow(
                        color: isSelected ? HaguruColors.primary.opacity(0.15) : HaguruColors.cardShadow,
                        radius: isSelected ? 12 : 6,
                        x: 0, y: isSelected ? 6 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .strokeBorder(
                        isSelected ? HaguruColors.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(HaguruAnimation.spring, value: isSelected)
        .accessibilityLabel(role.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func saveRole() async {
        guard let role = selectedRole,
              var user = appState.currentUser else { return }
        isLoading = true
        defer { isLoading = false }

        user = HaguruUser(
            id: user.id,
            nickname: user.nickname,
            roleType: role,
            email: user.email,
            profileIcon: user.profileIcon,
            createdAt: user.createdAt,
            birthYear: user.birthYear
        )

        do {
            try await repo.saveUser(user)
            appState.currentUser = user
            if role == .child {
                appState.screen = .relationshipSelection(userID: userID)
            } else {
                appState.screen = .enterInviteCode(userID: userID)
            }
        } catch {
            self.error = "保存に失敗しました。もう一度お試しください。"
        }
    }
}

#Preview {
    RoleSelectionView(userID: "preview-uid")
        .environmentObject(AppState.shared)
}
