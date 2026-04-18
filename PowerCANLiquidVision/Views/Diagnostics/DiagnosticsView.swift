import SwiftUI

struct DiagnosticsView: View {
    @EnvironmentObject private var viewModel: OBDViewModel
    @State private var isScanning = false
    @State private var showClearConfirm = false

    private var groupedCodes: [(DTCCategory, [DiagnosticTroubleCode])] {
        let groups = Dictionary(grouping: viewModel.dtcCodes, by: \.category)
        return DTCCategory.allCases.compactMap { cat in
            guard let codes = groups[cat], !codes.isEmpty else { return nil }
            return (cat, codes)
        }
    }

    var body: some View {
        ZStack {
            LVTheme.Colors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    statusHeader
                    actionButtons
                    if viewModel.dtcCodes.isEmpty {
                        emptyState
                    } else {
                        errorsList
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 100)
            }
        }
    }

    private var statusHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 80, height: 80)

                Circle()
                    .stroke(statusColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 80)

                if isScanning {
                    ProgressView()
                        .tint(statusColor)
                        .scaleEffect(1.3)
                } else {
                    Image(systemName: statusIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(statusColor)
                }
            }
            .neonGlow(statusColor, radius: 10)

            Text(statusTitle)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LVTheme.Colors.textPrimary)

            Text(statusSubtitle)
                .font(LVTheme.Fonts.tier3)
                .foregroundStyle(LVTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            if !viewModel.dtcCodes.isEmpty {
                HStack(spacing: 12) {
                    ForEach(DTCCategory.allCases, id: \.rawValue) { cat in
                        let count = viewModel.dtcCodes.filter { $0.category == cat }.count
                        if count > 0 {
                            CategoryBadge(category: cat, count: count)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 20)
    }

    private var statusColor: Color {
        if isScanning { return LVTheme.Colors.neonCyan }
        let criticalCount = viewModel.dtcCodes.filter { $0.severity == .critical }.count
        if criticalCount > 0 { return LVTheme.Colors.neonRed }
        if !viewModel.dtcCodes.isEmpty { return LVTheme.Colors.neonOrange }
        return LVTheme.Colors.neonGreen
    }

    private var statusIcon: String {
        if viewModel.dtcCodes.isEmpty { return "checkmark.shield.fill" }
        let hasCritical = viewModel.dtcCodes.contains { $0.severity == .critical }
        return hasCritical ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill"
    }

    private var statusTitle: String {
        if isScanning { return "Scanning ECU..." }
        if viewModel.dtcCodes.isEmpty { return "No Faults Detected" }
        let count = viewModel.dtcCodes.count
        return "\(count) Fault\(count == 1 ? "" : "s") Found"
    }

    private var statusSubtitle: String {
        if isScanning { return "Reading diagnostic trouble codes\nfrom vehicle ECU..." }
        if viewModel.dtcCodes.isEmpty { return "Your vehicle systems are operating normally.\nScan again to check for new faults." }
        let critical = viewModel.dtcCodes.filter { $0.severity == .critical }.count
        if critical > 0 { return "\(critical) critical issue\(critical == 1 ? "" : "s") require\(critical == 1 ? "s" : "") immediate attention." }
        return "Review the codes below for details."
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                performScan()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Scan DTCs")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: LVTheme.Spacing.minTouchTarget)
                .background(LVTheme.Colors.neonCyan.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .neonGlow(LVTheme.Colors.neonCyan, radius: 4)
            }
            .disabled(isScanning)
            .opacity(isScanning ? 0.5 : 1)

            if !viewModel.dtcCodes.isEmpty {
                Button {
                    showClearConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Clear")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: LVTheme.Spacing.minTouchTarget)
                    .background(LVTheme.Colors.neonRed.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .alert("Clear All DTCs?", isPresented: $showClearConfirm) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear All", role: .destructive) {
                        withAnimation { viewModel.clearDTCs() }
                    }
                } message: {
                    Text("This sends Mode 04 to the ECU, clearing all stored codes and resetting readiness monitors. Are you sure?")
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundStyle(LVTheme.Colors.neonGreen.opacity(0.3))

            Text("All Clear")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(LVTheme.Colors.textSecondary)
        }
        .padding(.top, 40)
    }

    private var errorsList: some View {
        VStack(spacing: 14) {
            ForEach(groupedCodes, id: \.0) { category, codes in
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(
                        title: category.rawValue.uppercased(),
                        icon: iconForCategory(category)
                    )

                    ForEach(codes) { dtc in
                        DTCCardView(dtc: dtc)
                    }
                }
            }
        }
    }

    private func iconForCategory(_ cat: DTCCategory) -> String {
        switch cat {
        case .powertrain: return "engine.combustion"
        case .chassis: return "car.side"
        case .body: return "car.top.door.front.left.open"
        case .network: return "network"
        }
    }

    private func performScan() {
        isScanning = true
        viewModel.clearDTCs()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.4)) {
                viewModel.scanDTCs()
                isScanning = false
            }
        }
    }
}

struct DTCCardView: View {
    let dtc: DiagnosticTroubleCode

    private var severityColor: Color {
        switch dtc.severity {
        case .critical: return LVTheme.Colors.neonRed
        case .warning: return LVTheme.Colors.neonOrange
        case .info: return LVTheme.Colors.neonCyan
        }
    }

    private var categoryColor: Color {
        switch dtc.category {
        case .powertrain: return LVTheme.Colors.neonRed
        case .chassis: return LVTheme.Colors.neonOrange
        case .body: return LVTheme.Colors.neonCyan
        case .network: return LVTheme.Colors.neonBlue
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(categoryColor)
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(dtc.code)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(LVTheme.Colors.textPrimary)

                    Spacer()

                    Text(dtc.severity.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(severityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(severityColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(dtc.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(LVTheme.Colors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(dtc.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(categoryColor.opacity(0.8))

                    Circle()
                        .fill(LVTheme.Colors.textSecondary.opacity(0.3))
                        .frame(width: 3, height: 3)

                    Text(dtc.timestamp, style: .time)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(LVTheme.Colors.textSecondary.opacity(0.6))
                }
            }
        }
        .padding(14)
        .liquidGlass()
        .glowingBorder(categoryColor.opacity(0.15))
    }
}

struct CategoryBadge: View {
    let category: DTCCategory
    let count: Int

    private var color: Color {
        switch category {
        case .powertrain: return LVTheme.Colors.neonRed
        case .chassis: return LVTheme.Colors.neonOrange
        case .body: return LVTheme.Colors.neonCyan
        case .network: return LVTheme.Colors.neonBlue
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(category.prefix)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text("×\(count)")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 0.5))
    }
}

#Preview {
    DiagnosticsView()
        .environmentObject(OBDViewModel())
}
