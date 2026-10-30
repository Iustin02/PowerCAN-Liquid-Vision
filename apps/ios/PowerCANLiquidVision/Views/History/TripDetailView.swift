import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: TripRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LVTheme.Colors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    mapSection
                    statsSection
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trip Details")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(LVTheme.Colors.textPrimary)

                Text(trip.startDate, format: .dateTime.day().month().year().hour().minute())
                    .font(LVTheme.Fonts.tier3)
                    .foregroundStyle(LVTheme.Colors.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LVTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var mapSection: some View {
        Group {
            if !trip.routePoints.isEmpty {
                Map {
                    ForEach(0..<max(trip.routePoints.count - 1, 0), id: \.self) { i in
                        let from = trip.routePoints[i]
                        let to = trip.routePoints[i + 1]
                        let color = LVTheme.Colors.heatColor(for: from.speedNormalized)

                        MapPolyline(coordinates: [from.coordinate, to.coordinate])
                            .stroke(color, lineWidth: 5)
                    }

                    if let first = trip.routePoints.first {
                        Annotation("Start", coordinate: first.coordinate) {
                            Image(systemName: "flag.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(LVTheme.Colors.neonGreen)
                        }
                    }

                    if let last = trip.routePoints.last {
                        Annotation("End", coordinate: last.coordinate) {
                            Image(systemName: "flag.checkered.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(LVTheme.Colors.neonRed)
                        }
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 12)
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                DetailStatCard(
                    title: "Distance",
                    value: String(format: "%.1f", trip.distanceKm),
                    unit: "km",
                    icon: "road.lanes",
                    color: LVTheme.Colors.neonCyan
                )

                DetailStatCard(
                    title: "Duration",
                    value: trip.durationFormatted,
                    unit: "",
                    icon: "clock",
                    color: LVTheme.Colors.neonBlue
                )
            }

            HStack(spacing: 10) {
                DetailStatCard(
                    title: "Max Speed",
                    value: String(format: "%.0f", trip.maxSpeed),
                    unit: "km/h",
                    icon: "speedometer",
                    color: LVTheme.Colors.neonOrange
                )

                DetailStatCard(
                    title: "Avg Speed",
                    value: String(format: "%.0f", trip.avgSpeed),
                    unit: "km/h",
                    icon: "gauge.with.dots.needle.50percent",
                    color: LVTheme.Colors.neonGreen
                )
            }

            HStack(spacing: 10) {
                DetailStatCard(
                    title: "Max RPM",
                    value: String(format: "%.0f", trip.maxRPM),
                    unit: "RPM",
                    icon: "gauge.with.needle",
                    color: LVTheme.Colors.neonRed
                )

                DetailStatCard(
                    title: "Fuel Cons.",
                    value: String(format: "%.1f", trip.avgFuelConsumption),
                    unit: "L/100km",
                    icon: "fuelpump.fill",
                    color: LVTheme.Colors.neonGreen
                )
            }
        }
        .padding(.horizontal, 12)
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(LVTheme.Colors.textPrimary)

            if !unit.isEmpty {
                Text(unit)
                    .font(LVTheme.Fonts.label)
                    .foregroundStyle(LVTheme.Colors.textSecondary)
            }

            Text(title)
                .font(LVTheme.Fonts.label)
                .foregroundStyle(LVTheme.Colors.textSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .liquidGlass()
        .glowingBorder(color.opacity(0.2))
    }
}
