import SwiftUI

struct ConnectionStatusBar: View {
    let state: ConnectionState
    let dataMode: DataMode

    private var statusColor: Color {
        switch state {
        case .connected: return LVTheme.Colors.neonGreen
        case .simulating: return LVTheme.Colors.neonCyan
        case .scanning, .connecting, .initializing: return LVTheme.Colors.neonOrange
        case .disconnected: return LVTheme.Colors.textSecondary
        case .error: return LVTheme.Colors.neonRed
        }
    }

    private var statusIcon: String {
        switch state {
        case .connected: return "antenna.radiowaves.left.and.right"
        case .simulating: return "waveform.path"
        case .scanning: return "magnifyingglass"
        case .connecting, .initializing: return "arrow.triangle.2.circlepath"
        case .disconnected: return "antenna.radiowaves.left.and.right.slash"
        case .error: return "exclamationmark.triangle"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .neonGlow(statusColor, radius: 4)

            Image(systemName: statusIcon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(statusColor)

            Text(state.rawValue)
                .font(LVTheme.Fonts.tier3)
                .foregroundStyle(LVTheme.Colors.textSecondary)

            Spacer()

            Text(dataMode.rawValue)
                .font(LVTheme.Fonts.label)
                .foregroundStyle(statusColor.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(statusColor.opacity(0.3), lineWidth: 0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .background(LVTheme.Colors.backgroundPrimary.opacity(0.8))
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectionStatusBar(state: .simulating, dataMode: .simulated)
        ConnectionStatusBar(state: .connected, dataMode: .liveOBD)
        ConnectionStatusBar(state: .error, dataMode: .liveOBD)
    }
}
