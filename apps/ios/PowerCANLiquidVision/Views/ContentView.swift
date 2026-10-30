import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: OBDViewModel
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case diagnostics = "Errors"
        case history = "History"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "gauge.with.dots.needle.67percent"
            case .diagnostics: return "exclamationmark.triangle.fill"
            case .history: return "map.fill"
            case .settings: return "gearshape.fill"
            }
        }

        var activeColor: Color {
            switch self {
            case .dashboard: return LVTheme.Colors.neonCyan
            case .diagnostics: return LVTheme.Colors.neonOrange
            case .history: return LVTheme.Colors.neonBlue
            case .settings: return LVTheme.Colors.neonGreen
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .diagnostics:
                    DiagnosticsView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? tab.activeColor : LVTheme.Colors.textSecondary)
                                .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                            if tab == .diagnostics && !viewModel.dtcCodes.isEmpty {
                                Text("\(viewModel.dtcCodes.count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                                    .background(LVTheme.Colors.neonRed)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -6)
                            }
                        }

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(selectedTab == tab ? tab.activeColor : LVTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: LVTheme.Spacing.minTouchTarget)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
        .background(LVTheme.Colors.backgroundPrimary.opacity(0.85))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.08), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(OBDViewModel())
        .modelContainer(for: TripRecord.self, inMemory: true)
}
