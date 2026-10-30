import SwiftUI

enum LVTheme {
    enum Colors {
        static let backgroundPrimary = Color(hex: 0x0A0A0A)
        static let backgroundCard = Color(hex: 0x1A1A1E)
        static let backgroundElevated = Color(hex: 0x2C2C30)
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: 0xA0A0A8)
        static let neonGreen = Color(hex: 0x00FF88)
        static let neonCyan = Color(hex: 0x00DDFF)
        static let neonBlue = Color(hex: 0x00AAFF)
        static let neonOrange = Color(hex: 0xFF8800)
        static let neonRed = Color(hex: 0xFF2244)
        static let gaugeArcBg = Color(hex: 0x1E1E24)

        static func heatColor(for value: Double) -> Color {
            let clamped = min(max(value, 0), 1)
            if clamped < 0.3 {
                return neonCyan
            } else if clamped < 0.6 {
                return neonGreen
            } else if clamped < 0.8 {
                return neonOrange
            } else {
                return neonRed
            }
        }

        static func heatGradient(for value: Double) -> LinearGradient {
            let clamped = min(max(value, 0), 1)
            let primary = heatColor(for: clamped)
            let secondary = heatColor(for: max(clamped - 0.2, 0))
            return LinearGradient(colors: [secondary, primary], startPoint: .leading, endPoint: .trailing)
        }
    }

    enum Fonts {
        static let tier1 = Font.system(size: 38, weight: .bold, design: .rounded).monospacedDigit()
        static let tier1Small = Font.system(size: 34, weight: .bold, design: .rounded).monospacedDigit()
        static let tier2 = Font.system(size: 26, weight: .semibold, design: .rounded).monospacedDigit()
        static let tier3 = Font.system(size: 14, weight: .medium, design: .default)
        static let label = Font.system(size: 12, weight: .medium, design: .default)
        static let status = Font.system(size: 16, weight: .medium, design: .default)
    }

    enum Spacing {
        static let cardPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20
        static let sectionSpacing: CGFloat = 16
        static let minTouchTarget: CGFloat = 60
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
