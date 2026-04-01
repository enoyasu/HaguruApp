import SwiftUI

extension View {
    // MARK: - Conditional modifiers
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) } else { self }
    }

    // MARK: - Standard page layout
    func haguruPageBackground() -> some View {
        self.background(HaguruColors.background.ignoresSafeArea())
    }

    // MARK: - Tap feedback
    func scaleOnTap(scale: CGFloat = 0.96) -> some View {
        self.buttonStyle(ScaleButtonStyle(scale: scale))
    }

    // MARK: - Standard padding
    func haguruHorizontalPadding() -> some View {
        self.padding(.horizontal, HaguruSpacing.md)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(HaguruAnimation.springFast, value: configuration.isPressed)
    }
}

// MARK: - Keyboard dismissal
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}

// MARK: - Shimmer effect (loading placeholder)
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let gradient = LinearGradient(
                        colors: [
                            .white.opacity(0),
                            .white.opacity(0.4),
                            .white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    Rectangle()
                        .fill(gradient)
                        .frame(width: geometry.size.width * 0.5)
                        .offset(x: phase * geometry.size.width * 1.5 - geometry.size.width * 0.5)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
