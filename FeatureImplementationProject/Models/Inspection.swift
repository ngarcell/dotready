import Foundation

nonisolated enum InspectionPointStatus: String, Codable, Sendable {
    case pass = "Pass"
    case fail = "Fail"
    case na = "N/A"
    case unchecked = "Unchecked"
}

nonisolated enum InspectionSection: String, Codable, CaseIterable, Sendable {
    case engineCompartment = "Engine Compartment"
    case cabInterior = "Cab Interior"
    case exteriorWalkAround = "Exterior Walk-Around"
    case lightsSignals = "Lights & Signals"
    case brakes = "Brakes"
    case tiresWheels = "Tires & Wheels"
    case couplingDevices = "Coupling Devices"
    case cargoArea = "Cargo Area"

    var icon: String {
        switch self {
        case .engineCompartment: return "engine.combustion"
        case .cabInterior: return "carseat.left"
        case .exteriorWalkAround: return "figure.walk"
        case .lightsSignals: return "light.beacon.max"
        case .brakes: return "brake.signal"
        case .tiresWheels: return "tire"
        case .couplingDevices: return "link"
        case .cargoArea: return "shippingbox"
        }
    }

    var points: [String] {
        switch self {
        case .engineCompartment:
            return ["Oil level", "Coolant level", "Power steering fluid", "Belts & hoses", "Leaks", "Wiring"]
        case .cabInterior:
            return ["Gauges & warning lights", "Windshield wipers", "Horn", "Mirrors", "Seat belt", "Emergency equipment", "Heater/Defroster"]
        case .exteriorWalkAround:
            return ["Body damage", "Fuel tank & cap", "Frame & cross members", "Exhaust system", "Mud flaps", "Reflectors"]
        case .lightsSignals:
            return ["Headlights", "Tail lights", "Brake lights", "Turn signals", "Hazard lights", "Clearance lights", "Reflective tape"]
        case .brakes:
            return ["Air pressure build-up", "Low air warning", "Parking brake", "Service brake", "Brake drums/rotors", "Brake lines & hoses", "Slack adjusters"]
        case .tiresWheels:
            return ["Tire pressure", "Tread depth", "Tire condition", "Lug nuts", "Wheel seals", "Hub oil level", "Valve stems"]
        case .couplingDevices:
            return ["Fifth wheel", "Kingpin", "Locking jaws", "Mounting bolts", "Apron/skid plate", "Air & electric lines", "Safety chains"]
        case .cargoArea:
            return ["Load secured", "Doors/latches", "Tarp/cover condition", "Weight distribution", "Placards (if required)", "Load height clearance"]
        }
    }
}

nonisolated struct InspectionPoint: Codable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var section: InspectionSection
    var status: InspectionPointStatus
    var notes: String

    init(id: UUID = UUID(), name: String, section: InspectionSection, status: InspectionPointStatus = .unchecked, notes: String = "") {
        self.id = id
        self.name = name
        self.section = section
        self.status = status
        self.notes = notes
    }
}

nonisolated struct Inspection: Codable, Identifiable, Sendable {
    var id: UUID
    var vehicleID: UUID?
    var vehicleName: String
    var points: [InspectionPoint]
    var overallNotes: String
    var startTime: Date
    var endTime: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        vehicleID: UUID? = nil,
        vehicleName: String = "",
        points: [InspectionPoint] = [],
        overallNotes: String = "",
        startTime: Date = Date(),
        endTime: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.vehicleName = vehicleName
        self.points = points
        self.overallNotes = overallNotes
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
    }

    var isComplete: Bool { endTime != nil }

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    var passCount: Int { points.filter { $0.status == .pass }.count }
    var failCount: Int { points.filter { $0.status == .fail }.count }
    var naCount: Int { points.filter { $0.status == .na }.count }
    var uncheckedCount: Int { points.filter { $0.status == .unchecked }.count }

    var result: String {
        if failCount > 0 { return "Failed" }
        if uncheckedCount > 0 { return "Incomplete" }
        return "Passed"
    }

    static func createNew(vehicleID: UUID? = nil, vehicleName: String = "") -> Inspection {
        var points: [InspectionPoint] = []
        for section in InspectionSection.allCases {
            for pointName in section.points {
                points.append(InspectionPoint(name: pointName, section: section))
            }
        }
        return Inspection(vehicleID: vehicleID, vehicleName: vehicleName, points: points)
    }
}
