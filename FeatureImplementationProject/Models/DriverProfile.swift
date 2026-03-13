import Foundation

nonisolated enum CDLClass: String, Codable, CaseIterable, Sendable {
    case classA = "Class A"
    case classB = "Class B"
    case classC = "Class C"
}

nonisolated struct DriverProfile: Codable, Sendable {
    var name: String
    var cdlNumber: String
    var cdlState: String
    var cdlClass: CDLClass
    var endorsements: String
    var medicalCardExpiration: Date?
    var phoneNumber: String
    var email: String

    init(
        name: String = "",
        cdlNumber: String = "",
        cdlState: String = "",
        cdlClass: CDLClass = .classA,
        endorsements: String = "",
        medicalCardExpiration: Date? = nil,
        phoneNumber: String = "",
        email: String = ""
    ) {
        self.name = name
        self.cdlNumber = cdlNumber
        self.cdlState = cdlState
        self.cdlClass = cdlClass
        self.endorsements = endorsements
        self.medicalCardExpiration = medicalCardExpiration
        self.phoneNumber = phoneNumber
        self.email = email
    }

    var isSetUp: Bool {
        !name.isEmpty && !cdlNumber.isEmpty
    }
}
