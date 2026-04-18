import SwiftUI

struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = LVTheme.Spacing.cardCornerRadius

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(LVTheme.Colors.backgroundCard.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.05), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

struct NeonGlow: ViewModifier {
    let color: Color
    var radius: CGFloat = 8
    var intensity: Double = 0.6

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity), radius: radius)
            .shadow(color: color.opacity(intensity * 0.5), radius: radius * 2)
    }
}

struct GlowingBorder: ViewModifier {
    let color: Color
    var cornerRadius: CGFloat = LVTheme.Spacing.cardCornerRadius
    var lineWidth: CGFloat = 1.5

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(color.opacity(0.4), lineWidth: lineWidth)
            )
            .modifier(NeonGlow(color: color, radius: 6, intensity: 0.3))
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = LVTheme.Spacing.cardCornerRadius) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius))
    }

    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }

    func glowingBorder(_ color: Color, cornerRadius: CGFloat = LVTheme.Spacing.cardCornerRadius) -> some View {
        modifier(GlowingBorder(color: color, cornerRadius: cornerRadius))
    }
}
