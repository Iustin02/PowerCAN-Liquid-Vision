import SwiftUI

struct ArcGaugeView: View {
    let value: Double
    let maxValue: Double
    let label: String
    let unit: String
    let accentColor: Color
    var size: CGFloat = 200

    private let startAngle: Double = 150
    private let endAngle: Double = 390
    private let strokeWidth: CGFloat = 14

    private var progress: Double {
        min(max(value / maxValue, 0), 1)
    }

    private var trimEnd: CGFloat {
        CGFloat(progress) * 0.667
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.667)
                .stroke(
                    LVTheme.Colors.gaugeArcBg,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(startAngle))

            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    AngularGradient(
                        colors: [accentColor.opacity(0.6), accentColor],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * Double(trimEnd))
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(startAngle))
                .shadow(color: accentColor.opacity(0.6), radius: 8)
                .shadow(color: accentColor.opacity(0.3), radius: 16)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: trimEnd)

            VStack(spacing: 4) {
                Text(formatValue())
                    .font(LVTheme.Fonts.tier1)
                    .foregroundStyle(LVTheme.Colors.textPrimary)
                    .contentTransition(.numericText(value: value))
                    .animation(.spring(response: 0.3), value: value)

                Text(unit)
                    .font(LVTheme.Fonts.tier3)
                    .foregroundStyle(LVTheme.Colors.textSecondary)

                Text(label)
                    .font(LVTheme.Fonts.label)
                    .foregroundStyle(LVTheme.Colors.textSecondary.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
    }

    private func formatValue() -> String {
        if maxValue > 1000 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.0f", value)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ArcGaugeView(
            value: 3200,
            maxValue: 7000,
            label: "ENGINE",
            unit: "RPM",
            accentColor: LVTheme.Colors.neonCyan
        )
    }
}
