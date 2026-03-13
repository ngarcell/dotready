import Foundation

nonisolated struct Vehicle: Codable, Identifiable, Sendable, Hashable {
    var id: UUID
    var name: String
    var vin: String
    var plateNumber: String
    var year: String
    var make: String
    var model: String
    var dotNumber: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        vin: String = "",
        plateNumber: String = "",
        year: String = "",
        make: String = "",
        model: String = "",
        dotNumber: String = "",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.vin = vin
        self.plateNumber = plateNumber
        self.year = year
        self.make = make
        self.model = model
        self.dotNumber = dotNumber
        self.notes = notes
        self.createdAt = createdAt
    }

    var displayName: String {
        if !name.isEmpty { return name }
        let parts = [year, make, model].filter { !$0.isEmpty }
        return parts.isEmpty ? "Unnamed Vehicle" : parts.joined(separator: " ")
    }
}
