import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let accentColor: Color
    var trend: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentColor)

                Text(title)
                    .font(LVTheme.Fonts.tier3)
                    .foregroundStyle(LVTheme.Colors.textSecondary)

                Spacer()

                if let trend {
                    Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(trend > 0 ? LVTheme.Colors.neonOrange : LVTheme.Colors.neonGreen)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(LVTheme.Fonts.tier2)
                    .foregroundStyle(LVTheme.Colors.textPrimary)
                    .contentTransition(.numericText())

                Text(unit)
                    .font(LVTheme.Fonts.tier3)
                    .foregroundStyle(LVTheme.Colors.textSecondary)
            }
        }
        .padding(LVTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass()
        .glowingBorder(accentColor.opacity(0.3))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MetricCardView(
            title: "Coolant Temp",
            value: "92",
            unit: "°C",
            icon: "thermometer.medium",
            accentColor: LVTheme.Colors.neonOrange,
            trend: 0.5
        )
        .padding()
    }
}
