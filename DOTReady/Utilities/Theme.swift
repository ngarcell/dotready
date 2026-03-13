import SwiftUI

enum AppColors {
    static let dotBlue = Color(red: 0.118, green: 0.251, blue: 0.686)
    static let dotBlueDark = Color(red: 0.08, green: 0.16, blue: 0.45)
    static let navy = Color(red: 0.08, green: 0.13, blue: 0.28)
    static let highwayYellow = Color(red: 0.918, green: 0.702, blue: 0.031)
    static let compliant = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let expired = Color(red: 1.0, green: 0.23, blue: 0.19)

    static func statusColor(for status: ComplianceStatus) -> Color {
        switch status {
        case .current: return compliant
        case .expiringSoon: return warning
        case .expired: return expired
        case .noDate: return .secondary
        }
    }
}
