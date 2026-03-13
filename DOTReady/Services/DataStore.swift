import Foundation
import SwiftUI

@Observable
@MainActor
class DataStore {
    var complianceItems: [ComplianceItem] = []
    var documents: [StoredDocument] = []
    var vehicles: [Vehicle] = []
    var inspections: [Inspection] = []
    var historyEvents: [HistoryEvent] = []
    var driverProfile: DriverProfile = DriverProfile()
    var drugTests: [DrugTest] = []

    private let complianceKey = "compliance_items"
    private let documentsKey = "stored_documents"
    private let vehiclesKey = "stored_vehicles"
    private let inspectionsKey = "stored_inspections"
    private let historyKey = "history_events"
    private let profileKey = "driver_profile"
    private let drugTestsKey = "drug_tests"

    init() {
        loadAll()
    }

    private func loadAll() {
        complianceItems = load(key: complianceKey) ?? []
        documents = load(key: documentsKey) ?? []
        vehicles = load(key: vehiclesKey) ?? []
        inspections = load(key: inspectionsKey) ?? []
        historyEvents = load(key: historyKey) ?? []
        driverProfile = load(key: profileKey) ?? DriverProfile()
        drugTests = load(key: drugTestsKey) ?? []
    }

    private nonisolated func load<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private nonisolated func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Compliance Items

    func addComplianceItem(_ item: ComplianceItem) {
        complianceItems.append(item)
        save(complianceItems, key: complianceKey)
        addHistoryEvent(type: .complianceAdded, title: "Added: \(item.name)", detail: item.category.rawValue)
    }

    func updateComplianceItem(_ item: ComplianceItem) {
        if let index = complianceItems.firstIndex(where: { $0.id == item.id }) {
            var updated = item
            updated.updatedAt = Date()
            complianceItems[index] = updated
            save(complianceItems, key: complianceKey)
            addHistoryEvent(type: .complianceUpdated, title: "Updated: \(item.name)", detail: item.category.rawValue)
        }
    }

    func deleteComplianceItem(_ item: ComplianceItem) {
        complianceItems.removeAll { $0.id == item.id }
        save(complianceItems, key: complianceKey)
    }

    // MARK: - Documents

    func addDocument(_ doc: StoredDocument) {
        documents.append(doc)
        save(documents, key: documentsKey)
        addHistoryEvent(type: .documentAdded, title: "Added: \(doc.name)", detail: doc.category.rawValue)
    }

    func updateDocument(_ doc: StoredDocument) {
        if let index = documents.firstIndex(where: { $0.id == doc.id }) {
            var updated = doc
            updated.updatedAt = Date()
            documents[index] = updated
            save(documents, key: documentsKey)
        }
    }

    func deleteDocument(_ doc: StoredDocument) {
        documents.removeAll { $0.id == doc.id }
        save(documents, key: documentsKey)
    }

    // MARK: - Vehicles

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        save(vehicles, key: vehiclesKey)
        addHistoryEvent(type: .vehicleAdded, title: "Added: \(vehicle.displayName)")
    }

    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            save(vehicles, key: vehiclesKey)
        }
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        save(vehicles, key: vehiclesKey)
    }

    // MARK: - Inspections

    func addInspection(_ inspection: Inspection) {
        inspections.insert(inspection, at: 0)
        save(inspections, key: inspectionsKey)
        addHistoryEvent(type: .inspectionCompleted, title: "Inspection: \(inspection.result)", detail: inspection.vehicleName)
    }

    func updateInspection(_ inspection: Inspection) {
        if let index = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[index] = inspection
            save(inspections, key: inspectionsKey)
        }
    }

    // MARK: - Drug Tests

    func addDrugTest(_ test: DrugTest) {
        drugTests.insert(test, at: 0)
        save(drugTests, key: drugTestsKey)
        addHistoryEvent(type: .complianceAdded, title: "Drug Test: \(test.type.rawValue)", detail: test.testDate.formatted(date: .abbreviated, time: .omitted))
    }

    func deleteDrugTest(_ test: DrugTest) {
        drugTests.removeAll { $0.id == test.id }
        save(drugTests, key: drugTestsKey)
    }

    // MARK: - Driver Profile

    func updateProfile(_ profile: DriverProfile) {
        driverProfile = profile
        save(driverProfile, key: profileKey)
        addHistoryEvent(type: .profileUpdated, title: "Profile Updated")
    }

    // MARK: - History

    func addHistoryEvent(type: HistoryEventType, title: String, detail: String = "") {
        let event = HistoryEvent(type: type, title: title, detail: detail)
        historyEvents.insert(event, at: 0)
        if historyEvents.count > 500 {
            historyEvents = Array(historyEvents.prefix(500))
        }
        save(historyEvents, key: historyKey)
    }

    // MARK: - Computed

    var urgentItems: [ComplianceItem] {
        complianceItems
            .filter { $0.expirationDate != nil }
            .sorted { ($0.daysRemaining ?? Int.max) < ($1.daysRemaining ?? Int.max) }
            .prefix(3)
            .map { $0 }
    }

    var overallStatus: String {
        let hasExpired = complianceItems.contains { $0.status == .expired }
        return hasExpired ? "Action Needed" : "Roadside Ready"
    }

    var isRoadsideReady: Bool {
        !complianceItems.contains { $0.status == .expired }
    }

    var latestInspection: Inspection? {
        inspections.first
    }

    func documentsForItem(_ item: ComplianceItem) -> [StoredDocument] {
        documents.filter { item.linkedDocumentIDs.contains($0.id) }
    }

    var itemsWithin90Days: [ComplianceItem] {
        complianceItems
            .filter { item in
                guard let days = item.daysRemaining else { return false }
                return days <= 90
            }
            .sorted { ($0.daysRemaining ?? Int.max) < ($1.daysRemaining ?? Int.max) }
    }

    var lastRandomTestDate: Date? {
        drugTests.filter { $0.type == .random }.first?.testDate
    }

    func resetAllData() {
        let keys = [complianceKey, documentsKey, vehiclesKey, inspectionsKey, historyKey, profileKey, drugTestsKey]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        complianceItems = []
        documents = []
        vehicles = []
        inspections = []
        historyEvents = []
        driverProfile = DriverProfile()
        drugTests = []
    }
}
