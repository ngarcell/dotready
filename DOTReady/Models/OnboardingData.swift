import Foundation

nonisolated enum DriverType: String, Codable, CaseIterable, Sendable {
    case ownerOperator = "Owner-Operator"
    case companyDriver = "Company Driver"
    case fleetOwner = "Fleet Owner / Manager"
    case cdlStudent = "CDL Student"

    var icon: String {
        switch self {
        case .ownerOperator: return "truck.box.fill"
        case .companyDriver: return "person.fill"
        case .fleetOwner: return "person.3.fill"
        case .cdlStudent: return "graduationcap.fill"
        }
    }
}

nonisolated enum CDLClassOption: String, Codable, CaseIterable, Sendable {
    case classA = "Class A"
    case classB = "Class B"
    case classC = "Class C"
    case learnerPermit = "Learner's Permit"

    var subtitle: String {
        switch self {
        case .classA: return "Combination vehicles"
        case .classB: return "Single vehicle 26,001+ lbs"
        case .classC: return "Hazmat / Passenger"
        case .learnerPermit: return "In training"
        }
    }
}

nonisolated enum Endorsement: String, Codable, CaseIterable, Sendable, Identifiable {
    case hazmat = "H"
    case tanker = "N"
    case doubleTriple = "T"
    case passenger = "P"
    case schoolBus = "S"
    case none = "None"

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .hazmat: return "Hazmat (H)"
        case .tanker: return "Tanker (N)"
        case .doubleTriple: return "Double/Triple (T)"
        case .passenger: return "Passenger (P)"
        case .schoolBus: return "School Bus (S)"
        case .none: return "None"
        }
    }
}

nonisolated enum StateCount: String, Codable, CaseIterable, Sendable {
    case one = "1 state"
    case twoThree = "2-3 states"
    case fourPlus = "4+ states"

    var subtitle: String {
        switch self {
        case .one: return "Single state operation"
        case .twoThree: return "Regional multi-state"
        case .fourPlus: return "Nationwide coverage"
        }
    }
}

nonisolated enum TrackingMethod: String, Codable, CaseIterable, Sendable {
    case wallet = "I keep cards in my wallet"
    case company = "My company handles it"
    case memory = "I try to remember dates"
    case spreadsheet = "Spreadsheet / phone notes"

    var painPoint: String {
        switch self {
        case .wallet: return "If you lose your wallet, you lose your livelihood. One missing DOT medical card = out of service."
        case .company: return "Companies make mistakes. If YOUR medical card is expired during a roadside, YOU get the citation — not them."
        case .memory: return "Forgetting your medical renewal means your CDL is automatically downgraded. No warning."
        case .spreadsheet: return "Notes won't remind you 90 days out when you need to schedule your physical."
        }
    }

    var icon: String {
        switch self {
        case .wallet: return "wallet.bifold"
        case .company: return "building.2"
        case .memory: return "brain.head.profile"
        case .spreadsheet: return "tablecells"
        }
    }
}

nonisolated struct OnboardingProfile: Codable, Sendable {
    var driverType: String?
    var cdlClass: String?
    var endorsements: [String]
    var stateCount: String?
    var trackingMethod: String?

    init() {
        self.endorsements = []
    }
}
