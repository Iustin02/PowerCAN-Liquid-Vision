import Foundation

enum MockDTCGenerator {
    private static let commonCodes = [
        "P0171", "P0300", "P0420", "P0442", "P0507",
        "P0128", "P0135", "P0301", "P0172", "P0562",
        "P0340", "P0325", "P0455", "P0700", "P0505",
        "C0035", "C0050", "C0550",
        "B1000",
        "U0100", "U0121",
    ]

    static func generate() -> [DiagnosticTroubleCode] {
        let count = Int.random(in: 2...6)
        let selected = commonCodes.shuffled().prefix(count)

        return selected.map { code in
            let cat = DTCDecoder.category(for: code)
            let sev = DTCDecoder.severity(for: code)
            let desc = DTCDatabase.describe(code)
            return DiagnosticTroubleCode(
                code: code,
                category: cat,
                description: desc,
                severity: sev,
                timestamp: Date.now.addingTimeInterval(-Double.random(in: 0...3600))
            )
        }
        .sorted { $0.severity == .critical && $1.severity != .critical }
    }
}
