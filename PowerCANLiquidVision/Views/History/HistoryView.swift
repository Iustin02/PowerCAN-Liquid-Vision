import SwiftUI
import SwiftData
import MapKit

struct HistoryView: View {
    @Query(sort: \TripRecord.startDate, order: .reverse) private var trips: [TripRecord]
    @State private var selectedTrip: TripRecord?

    var body: some View {
        ZStack {
            LVTheme.Colors.backgroundPrimary
                .ignoresSafeArea()

            if trips.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(trips, id: \.id) { trip in
                            TripCardView(trip: trip)
                                .onTapGesture {
                                    selectedTrip = trip
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedTrip) { trip in
            TripDetailView(trip: trip)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundStyle(LVTheme.Colors.neonCyan.opacity(0.4))

            Text("No Trips Recorded")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(LVTheme.Colors.textPrimary)

            Text("Start a trip from the Dashboard\nto see your route history here.")
                .font(LVTheme.Fonts.tier3)
                .foregroundStyle(LVTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct TripCardView: View {
    let trip: TripRecord

    var body: some View {
        VStack(spacing: 0) {
            if !trip.routePoints.isEmpty {
                TripMapPreview(routePoints: trip.routePoints)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .clipped()
            }

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.startDate, style: .date)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(LVTheme.Colors.textPrimary)

                        Text(trip.startDate, style: .time)
                            .font(LVTheme.Fonts.tier3)
                            .foregroundStyle(LVTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text(trip.durationFormatted)
                        .font(LVTheme.Fonts.tier3)
                        .foregroundStyle(LVTheme.Colors.neonCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(LVTheme.Colors.neonCyan.opacity(0.1))
                        .clipShape(Capsule())
                }

                HStack(spacing: 16) {
                    TripStat(icon: "speedometer", value: String(format: "%.0f", trip.maxSpeed), unit: "km/h max")
                    TripStat(icon: "road.lanes", value: String(format: "%.1f", trip.distanceKm), unit: "km")
                    TripStat(icon: "gauge.with.needle", value: String(format: "%.0f", trip.maxRPM), unit: "RPM max")
                }
            }
            .padding(LVTheme.Spacing.cardPadding)
        }
        .liquidGlass()
    }
}

struct TripStat: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LVTheme.Colors.neonCyan)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(LVTheme.Colors.textPrimary)

            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(LVTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TripMapPreview: View {
    let routePoints: [RoutePoint]

    var body: some View {
        Map {
            if routePoints.count > 1 {
                ForEach(0..<routePoints.count - 1, id: \.self) { i in
                    let from = routePoints[i]
                    let to = routePoints[i + 1]
                    let color = LVTheme.Colors.heatColor(for: from.speedNormalized)

                    MapPolyline(coordinates: [from.coordinate, to.coordinate])
                        .stroke(color, lineWidth: 4)
                }
            }

            if let first = routePoints.first {
                Annotation("Start", coordinate: first.coordinate) {
                    Circle()
                        .fill(LVTheme.Colors.neonGreen)
                        .frame(width: 10, height: 10)
                }
            }

            if let last = routePoints.last {
                Annotation("End", coordinate: last.coordinate) {
                    Circle()
                        .fill(LVTheme.Colors.neonRed)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .allowsHitTesting(false)
    }
}

extension TripRecord: Identifiable {}

#Preview {
    HistoryView()
        .modelContainer(for: TripRecord.self, inMemory: true)
}
