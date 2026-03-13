import Foundation

nonisolated enum HistoryEventType: String, Codable, CaseIterable, Sendable {
    case complianceAdded = "Compliance Added"
    case complianceUpdated = "Compliance Updated"
    case complianceExpired = "Compliance Expired"
    case documentAdded = "Document Added"
    case inspectionCompleted = "Inspection Completed"
    case vehicleAdded = "Vehicle Added"
    case profileUpdated = "Profile Updated"

    var icon: String {
        switch self {
        case .complianceAdded: return "plus.circle.fill"
        case .complianceUpdated: return "pencil.circle.fill"
        case .complianceExpired: return "exclamationmark.triangle.fill"
        case .documentAdded: return "doc.badge.plus"
        case .inspectionCompleted: return "checkmark.circle.fill"
        case .vehicleAdded: return "truck.box.fill"
        case .profileUpdated: return "person.crop.circle.badge.checkmark"
        }
    }

    var category: String {
        switch self {
        case .complianceAdded, .complianceUpdated, .complianceExpired: return "Compliance"
        case .documentAdded: return "Document"
        case .inspectionCompleted: return "Inspection"
        case .vehicleAdded: return "Vehicle"
        case .profileUpdated: return "Profile"
        }
    }
}

nonisolated struct HistoryEvent: Codable, Identifiable, Sendable {
    var id: UUID
    var type: HistoryEventType
    var title: String
    var detail: String
    var date: Date

    init(id: UUID = UUID(), type: HistoryEventType, title: String, detail: String = "", date: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.date = date
    }
}
