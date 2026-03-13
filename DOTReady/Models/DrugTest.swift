import Foundation

nonisolated enum DrugTestType: String, Codable, CaseIterable, Sendable {
    case preEmployment = "Pre-Employment"
    case random = "Random"
    case postAccident = "Post-Accident"
    case reasonableSuspicion = "Reasonable Suspicion"
    case returnToDuty = "Return-to-Duty"
    case followUp = "Follow-Up"

    var icon: String {
        switch self {
        case .preEmployment: return "briefcase"
        case .random: return "dice"
        case .postAccident: return "exclamationmark.triangle"
        case .reasonableSuspicion: return "eye"
        case .returnToDuty: return "arrow.uturn.left"
        case .followUp: return "arrow.clockwise"
        }
    }
}

nonisolated struct DrugTest: Codable, Identifiable, Sendable {
    var id: UUID
    var type: DrugTestType
    var testDate: Date
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: DrugTestType = .random,
        testDate: Date = Date(),
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.testDate = testDate
        self.notes = notes
        self.createdAt = createdAt
    }
}
