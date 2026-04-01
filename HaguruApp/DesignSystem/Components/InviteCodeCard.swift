import SwiftUI

struct InviteCodeCard: View {
    let code: String
    var onCopy: (() -> Void)? = nil

    @State private var copied = false

    var body: some View {
        VStack(spacing: HaguruSpacing.md) {
            Text("招待コード")
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)

            Text(code)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(HaguruColors.textMain)
                .tracking(4)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Button {
                UIPasteboard.general.string = code
                withAnimation(HaguruAnimation.springFast) { copied = true }
                onCopy?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(HaguruAnimation.springFast) { copied = false }
                }
            } label: {
                Label(
                    copied ? "コピーしました" : "コードをコピー",
                    systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc"
                )
                .font(HaguruFont.captionMedium())
                .foregroundColor(copied ? HaguruColors.primary : HaguruColors.textSub)
            }
            .buttonStyle(.plain)
        }
        .padding(HaguruSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                .fill(HaguruColors.surfaceGreen)
                .overlay(
                    RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                        .strokeBorder(
                            HaguruColors.primary.opacity(0.2),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("招待コード: \(code)")
    }
}

#Preview {
    VStack {
        InviteCodeCard(code: "HAGURU-ABCD") {
            print("Copied!")
        }
    }
    .padding()
    .background(HaguruColors.background)
}
