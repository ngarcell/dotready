import Foundation

nonisolated enum DocumentCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case license = "License"
    case medical = "Medical"
    case vehicle = "Vehicle"
    case insurance = "Insurance"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .license: return "person.text.rectangle"
        case .medical: return "cross.case"
        case .vehicle: return "car"
        case .insurance: return "shield.checkered"
        case .other: return "doc"
        }
    }
}

nonisolated struct StoredDocument: Codable, Identifiable, Sendable, Hashable {
    var id: UUID
    var name: String
    var category: DocumentCategory
    var imageData: Data?
    var linkedComplianceItemID: UUID?
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        category: DocumentCategory = .other,
        imageData: Data? = nil,
        linkedComplianceItemID: UUID? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.imageData = imageData
        self.linkedComplianceItemID = linkedComplianceItemID
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
