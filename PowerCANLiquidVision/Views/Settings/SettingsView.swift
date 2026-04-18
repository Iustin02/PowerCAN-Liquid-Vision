import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: OBDViewModel
    @State private var showAbout = false

    var body: some View {
        ZStack {
            LVTheme.Colors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    dataSourceSection
                    connectionInfoSection
                    obdInfoSection
                    aboutSection
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 100)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "car.top.radiowaves.rear.right")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [LVTheme.Colors.neonCyan, LVTheme.Colors.neonBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("PowerCAN Liquid Vision")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(LVTheme.Colors.textPrimary)

            Text("v1.0.0 — ESP32 OBD-II Diagnostics")
                .font(LVTheme.Fonts.tier3)
                .foregroundStyle(LVTheme.Colors.textSecondary)
        }
        .padding(.vertical, 20)
    }

    private var dataSourceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "DATA SOURCE", icon: "antenna.radiowaves.left.and.right")

            VStack(spacing: 2) {
                ForEach(DataMode.allCases, id: \.rawValue) { mode in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.dataMode = mode
                        }
                    } label: {
                        HStack {
                            Image(systemName: mode == .simulated ? "waveform.path" : "antenna.radiowaves.left.and.right")
                                .font(.system(size: 18))
                                .foregroundStyle(modeColor(mode))
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(LVTheme.Colors.textPrimary)

                                Text(modeDescription(mode))
                                    .font(LVTheme.Fonts.label)
                                    .foregroundStyle(LVTheme.Colors.textSecondary)
                            }

                            Spacer()

                            if viewModel.dataMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(modeColor(mode))
                            }
                        }
                        .padding(14)
                        .background(
                            viewModel.dataMode == mode
                            ? modeColor(mode).opacity(0.08)
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .liquidGlass()
        }
    }

    private var connectionInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "CONNECTION STATUS", icon: "link")

            VStack(spacing: 12) {
                InfoRow(label: "State", value: viewModel.connectionState.rawValue)
                InfoRow(label: "Mode", value: viewModel.dataMode.rawValue)
                InfoRow(label: "Adapter", value: "Mister Diy PowerCAN ESP32")
                InfoRow(label: "Protocol", value: "ELM327 BLE")
            }
            .padding(LVTheme.Spacing.cardPadding)
            .liquidGlass()
        }
    }

    private var obdInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "OBD-II PROTOCOL", icon: "doc.text")

            VStack(spacing: 12) {
                InfoRow(label: "Init Sequence", value: "ATZ → ATL1 → ATSP0")
                InfoRow(label: "RPM Formula", value: "((256×A)+B)/4")
                InfoRow(label: "Coolant Formula", value: "A − 40")
                InfoRow(label: "Speed Formula", value: "A (direct)")
                InfoRow(label: "Polling Rate", value: "~250ms (Tier 1)")
            }
            .padding(LVTheme.Spacing.cardPadding)
            .liquidGlass()
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "ABOUT", icon: "info.circle")

            VStack(spacing: 12) {
                InfoRow(label: "Target Device", value: "iPhone 12 Pro Max")
                InfoRow(label: "Min iOS", value: "17.0")
                InfoRow(label: "Framework", value: "SwiftUI + SwiftData")
                InfoRow(label: "BLE Stack", value: "Core Bluetooth")
                InfoRow(label: "Maps", value: "MapKit")
            }
            .padding(LVTheme.Spacing.cardPadding)
            .liquidGlass()
        }
    }

    private func modeColor(_ mode: DataMode) -> Color {
        mode == .simulated ? LVTheme.Colors.neonCyan : LVTheme.Colors.neonGreen
    }

    private func modeDescription(_ mode: DataMode) -> String {
        switch mode {
        case .simulated: return "Realistic generated data for testing"
        case .liveOBD: return "Connect to ESP32 PowerCAN adapter"
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LVTheme.Colors.neonCyan)

            Text(title)
                .font(LVTheme.Fonts.label)
                .foregroundStyle(LVTheme.Colors.textSecondary)
                .tracking(1.5)
        }
        .padding(.horizontal, 4)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(LVTheme.Fonts.tier3)
                .foregroundStyle(LVTheme.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(LVTheme.Colors.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(OBDViewModel())
}
