import SwiftUI

struct RoadsideReadySummaryView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerBadge
                    driverInfoCard
                    cdlStatusCard
                    medicalCardStatus
                    vehicleInfoCard
                    recentInspectionCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Roadside Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var headerBadge: some View {
        VStack(spacing: 10) {
            Image(systemName: store.isRoadsideReady ? "shield.checkmark.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(store.isRoadsideReady ? AppColors.compliant : AppColors.expired)
            Text(store.overallStatus)
                .font(.title2.bold())
                .foregroundStyle(store.isRoadsideReady ? AppColors.compliant : AppColors.expired)
            Text(Date().formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var driverInfoCard: some View {
        SummaryCard(title: "Driver Information", icon: "person.fill") {
            SummaryRow(label: "Name", value: store.driverProfile.name.isEmpty ? "Not set" : store.driverProfile.name)
            SummaryRow(label: "CDL Number", value: store.driverProfile.cdlNumber.isEmpty ? "Not set" : store.driverProfile.cdlNumber)
            SummaryRow(label: "State", value: store.driverProfile.cdlState.isEmpty ? "Not set" : store.driverProfile.cdlState)
            SummaryRow(label: "Class", value: store.driverProfile.cdlClass.rawValue)
            if !store.driverProfile.endorsements.isEmpty {
                SummaryRow(label: "Endorsements", value: store.driverProfile.endorsements)
            }
        }
    }

    private var cdlStatusCard: some View {
        Group {
            if let cdlItem = store.complianceItems.first(where: { $0.category == .cdl }) {
                SummaryCard(title: "CDL Status", icon: "person.text.rectangle") {
                    SummaryRow(label: "Status", value: cdlItem.status.rawValue, color: AppColors.statusColor(for: cdlItem.status))
                    if let exp = cdlItem.expirationDate {
                        SummaryRow(label: "Expires", value: exp.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let days = cdlItem.daysRemaining {
                        SummaryRow(label: "Days Remaining", value: "\(days)", color: AppColors.statusColor(for: cdlItem.status))
                    }
                }
            }
        }
    }

    private var medicalCardStatus: some View {
        Group {
            if let medItem = store.complianceItems.first(where: { $0.category == .medical }) {
                SummaryCard(title: "Medical Card", icon: "heart.text.square") {
                    SummaryRow(label: "Status", value: medItem.status.rawValue, color: AppColors.statusColor(for: medItem.status))
                    if let exp = medItem.expirationDate {
                        SummaryRow(label: "Expires", value: exp.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let days = medItem.daysRemaining {
                        SummaryRow(label: "Days Remaining", value: "\(days)", color: AppColors.statusColor(for: medItem.status))
                    }
                }
            }
        }
    }

    private var vehicleInfoCard: some View {
        Group {
            if let vehicle = store.vehicles.first {
                SummaryCard(title: "Vehicle", icon: "truck.box") {
                    SummaryRow(label: "Vehicle", value: vehicle.displayName)
                    if !vehicle.vin.isEmpty { SummaryRow(label: "VIN", value: vehicle.vin) }
                    if !vehicle.plateNumber.isEmpty { SummaryRow(label: "Plate", value: vehicle.plateNumber) }
                    if !vehicle.dotNumber.isEmpty { SummaryRow(label: "DOT Number", value: vehicle.dotNumber) }
                }
            }
        }
    }

    private var recentInspectionCard: some View {
        Group {
            if let insp = store.latestInspection {
                SummaryCard(title: "Last Inspection", icon: "clipboard") {
                    SummaryRow(label: "Date", value: insp.createdAt.formatted(date: .abbreviated, time: .omitted))
                    SummaryRow(label: "Result", value: insp.result, color: insp.failCount == 0 ? AppColors.compliant : AppColors.expired)
                    if !insp.vehicleName.isEmpty {
                        SummaryRow(label: "Vehicle", value: insp.vehicleName)
                    }
                }
            }
        }
    }
}

struct SummaryCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(AppColors.dotBlue)
                Text(title)
                    .font(.headline)
            }
            VStack(spacing: 0) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
        }
        .padding(.vertical, 4)
    }
}
