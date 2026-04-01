import SwiftUI

struct StampPicker: View {
    @Binding var selectedStamp: StampType?
    let onSelect: (StampType) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: HaguruSpacing.sm), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: HaguruSpacing.sm) {
            Text("スタンプを送る")
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textSub)
                .padding(.horizontal, HaguruSpacing.md)

            LazyVGrid(columns: columns, spacing: HaguruSpacing.sm) {
                ForEach(StampType.allCases, id: \.self) { stamp in
                    stampCell(stamp)
                }
            }
            .padding(.horizontal, HaguruSpacing.md)
        }
        .padding(.vertical, HaguruSpacing.md)
        .background(HaguruColors.card)
        .clipShape(RoundedRectangle(cornerRadius: HaguruRadius.xl, style: .continuous))
        .shadow(color: HaguruColors.cardShadow, radius: 16, x: 0, y: 6)
    }

    private func stampCell(_ stamp: StampType) -> some View {
        let isSelected = selectedStamp == stamp

        return Button {
            withAnimation(HaguruAnimation.springFast) {
                selectedStamp = stamp
            }
            onSelect(stamp)
        } label: {
            VStack(spacing: HaguruSpacing.xxs) {
                Text(stamp.emoji)
                    .font(.system(size: 32))
                    .scaleEffect(isSelected ? 1.15 : 1.0)

                Text(stamp.label)
                    .font(HaguruFont.small())
                    .foregroundColor(isSelected ? HaguruColors.primary : HaguruColors.textSub)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HaguruSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                    .fill(isSelected ? HaguruColors.primary.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                    .strokeBorder(
                        isSelected ? HaguruColors.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(HaguruAnimation.spring, value: isSelected)
        .accessibilityLabel(stamp.label)
    }
}

#Preview {
    @Previewable @State var selected: StampType? = nil

    VStack {
        StampPicker(selectedStamp: $selected) { stamp in
            print("Selected: \(stamp)")
        }
    }
    .padding()
    .background(HaguruColors.background)
}
