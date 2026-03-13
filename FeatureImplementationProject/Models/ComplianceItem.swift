import Foundation

nonisolated enum ComplianceCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case medical = "Medical"
    case cdl = "CDL"
    case endorsement = "Endorsement"
    case drugAlcohol = "Drug & Alcohol"
    case inspection = "Inspection"
    case insurance = "Insurance"
    case vehicle = "Vehicle"
    case training = "Training"
    case safety = "Safety"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .medical: return "heart.text.square"
        case .cdl: return "person.text.rectangle"
        case .endorsement: return "checkmark.seal"
        case .drugAlcohol: return "flask"
        case .inspection: return "magnifyingglass"
        case .insurance: return "shield.checkered"
        case .vehicle: return "truck.box"
        case .training: return "graduationcap"
        case .safety: return "exclamationmark.shield"
        case .other: return "doc.plaintext"
        }
    }

    var groupName: String {
        switch self {
        case .cdl, .endorsement: return "CDL & Endorsements"
        case .medical: return "DOT Medical"
        case .drugAlcohol: return "Drug & Alcohol"
        case .vehicle, .inspection: return "Vehicle"
        case .insurance: return "Insurance"
        case .training: return "Training & Certifications"
        case .safety: return "Safety"
        case .other: return "Other"
        }
    }
}

nonisolated enum ComplianceStatus: String, Codable, Sendable {
    case current = "Current"
    case expiringSoon = "Expiring Soon"
    case expired = "Expired"
    case noDate = "No Expiration"
}

nonisolated struct ComplianceItem: Codable, Identifiable, Sendable, Hashable {
    var id: UUID
    var name: String
    var category: ComplianceCategory
    var issuingBody: String
    var credentialNumber: String
    var issueDate: Date?
    var expirationDate: Date?
    var notes: String
    var linkedDocumentIDs: [UUID]
    var reminderDays: [Int]
    var createdAt: Date
    var updatedAt: Date
    var source: String

    init(
        id: UUID = UUID(),
        name: String = "",
        category: ComplianceCategory = .other,
        issuingBody: String = "",
        credentialNumber: String = "",
        issueDate: Date? = nil,
        expirationDate: Date? = nil,
        notes: String = "",
        linkedDocumentIDs: [UUID] = [],
        reminderDays: [Int] = [90, 60, 30, 14, 7, 0],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        source: String = "manual"
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.issuingBody = issuingBody
        self.credentialNumber = credentialNumber
        self.issueDate = issueDate
        self.expirationDate = expirationDate
        self.notes = notes
        self.linkedDocumentIDs = linkedDocumentIDs
        self.reminderDays = reminderDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
    }

    var status: ComplianceStatus {
        guard let expDate = expirationDate else { return .noDate }
        let daysRemaining = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: expDate)).day ?? 0
        if daysRemaining < 0 { return .expired }
        if daysRemaining <= 30 { return .expiringSoon }
        return .current
    }

    var daysRemaining: Int? {
        guard let expDate = expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: expDate)).day
    }
}
