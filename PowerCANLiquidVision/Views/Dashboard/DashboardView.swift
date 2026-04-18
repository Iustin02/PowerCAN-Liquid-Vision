import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var viewModel: OBDViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            LVTheme.Colors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: LVTheme.Spacing.sectionSpacing) {
                    ConnectionStatusBar(
                        state: viewModel.connectionState,
                        dataMode: viewModel.dataMode
                    )

                    gaugesSection
                    carHeatSection
                    metricsGrid
                    tripControls
                }
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            viewModel.startSession()
        }
    }

    private var gaugesSection: some View {
        GeometryReader { geo in
            let available = geo.size.width - 48
            let gaugeSize = min(available / 2, 160.0)

            HStack(spacing: 20) {
                ArcGaugeView(
                    value: viewModel.obdData.rpm,
                    maxValue: 7000,
                    label: "ENGINE",
                    unit: "RPM",
                    accentColor: rpmColor,
                    size: gaugeSize
                )

                ArcGaugeView(
                    value: viewModel.obdData.speed,
                    maxValue: 260,
                    label: "SPEED",
                    unit: "km/h",
                    accentColor: LVTheme.Colors.neonBlue,
                    size: gaugeSize
                )
            }
            .frame(width: geo.size.width, height: gaugeSize)
        }
        .frame(height: 160)
        .padding(.horizontal, 12)
    }

    private var rpmColor: Color {
        let norm = viewModel.obdData.rpmNormalized
        return LVTheme.Colors.heatColor(for: norm)
    }

    private var carHeatSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("VEHICLE THERMAL MAP")
                    .font(LVTheme.Fonts.label)
                    .foregroundStyle(LVTheme.Colors.textSecondary)
                    .tracking(1.5)

                Spacer()

                HeatLegend()
            }
            .padding(.horizontal, 20)

            CarHeatMapView(
                heatLevel: viewModel.obdData.heatLevel,
                coolantTemp: viewModel.obdData.coolantTemp,
                rpm: viewModel.obdData.rpm,
                speed: viewModel.obdData.speed
            )
            .liquidGlass(cornerRadius: 24)
            .padding(.horizontal, 12)
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            MetricCardView(
                title: "Coolant",
                value: String(format: "%.0f", viewModel.obdData.coolantTemp),
                unit: "°C",
                icon: "thermometer.medium",
                accentColor: coolantColor,
                trend: viewModel.obdData.coolantTemp > 90 ? 1 : nil
            )

            MetricCardView(
                title: "Engine Load",
                value: String(format: "%.0f", viewModel.obdData.engineLoad),
                unit: "%",
                icon: "gauge.with.dots.needle.33percent",
                accentColor: LVTheme.Colors.neonBlue
            )

            MetricCardView(
                title: "Fuel Trim S-T",
                value: String(format: "%+.1f", viewModel.obdData.shortTermFuelTrim),
                unit: "%",
                icon: "fuelpump",
                accentColor: LVTheme.Colors.neonGreen
            )

            MetricCardView(
                title: "Fuel Trim L-T",
                value: String(format: "%+.1f", viewModel.obdData.longTermFuelTrim),
                unit: "%",
                icon: "fuelpump.fill",
                accentColor: LVTheme.Colors.neonCyan
            )

            MetricCardView(
                title: "Throttle",
                value: String(format: "%.0f", viewModel.obdData.throttlePosition),
                unit: "%",
                icon: "arrow.up.right.circle",
                accentColor: LVTheme.Colors.neonOrange
            )

            MetricCardView(
                title: "Consumption",
                value: String(format: "%.1f", viewModel.obdData.fuelConsumptionRate),
                unit: "L/100km",
                icon: "drop.fill",
                accentColor: LVTheme.Colors.neonGreen
            )
        }
        .padding(.horizontal, 12)
    }

    private var coolantColor: Color {
        let temp = viewModel.obdData.coolantTemp
        if temp < 70 { return LVTheme.Colors.neonCyan }
        if temp < 95 { return LVTheme.Colors.neonGreen }
        return LVTheme.Colors.neonRed
    }

    private var tripControls: some View {
        Group {
            if viewModel.isTripActive {
                Button {
                    viewModel.endTrip(context: modelContext)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 20))
                        Text("End Trip Recording")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: LVTheme.Spacing.minTouchTarget)
                    .background(LVTheme.Colors.neonRed.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .neonGlow(LVTheme.Colors.neonRed, radius: 6)
                }
            } else {
                Button {
                    viewModel.startTrip(context: modelContext)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "record.circle")
                            .font(.system(size: 20))
                        Text("Start Trip Recording")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: LVTheme.Spacing.minTouchTarget)
                    .background(LVTheme.Colors.neonGreen.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .neonGlow(LVTheme.Colors.neonGreen, radius: 6)
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

struct HeatLegend: View {
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.25)), id: \.self) { val in
                RoundedRectangle(cornerRadius: 2)
                    .fill(LVTheme.Colors.heatColor(for: val))
                    .frame(width: 12, height: 6)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(OBDViewModel())
        .modelContainer(for: TripRecord.self, inMemory: true)
}
