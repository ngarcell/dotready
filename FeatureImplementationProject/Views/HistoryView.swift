import SwiftUI

struct HistoryView: View {
    @Environment(DataStore.self) private var store
    @Environment(SubscriptionManager.self) private var subscription
    @State private var filterType: String = "All"
    @State private var showPaywall = false

    private let filterOptions = ["All", "Compliance", "Document", "Inspection", "Vehicle", "Profile"]

    private var filteredEvents: [HistoryEvent] {
        if filterType == "All" { return store.historyEvents }
        return store.historyEvents.filter { $0.type.category == filterType }
    }

    private var groupedEvents: [(String, [HistoryEvent])] {
        let grouped = Dictionary(grouping: filteredEvents) { event in
            event.date.formatted(date: .abbreviated, time: .omitted)
        }
        return grouped.sorted { lhs, rhs in
            (lhs.value.first?.date ?? .distantPast) > (rhs.value.first?.date ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !store.historyEvents.isEmpty {
                    Section {
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(filterOptions, id: \.self) { option in
                                    FilterChip(label: option, isSelected: filterType == option) {
                                        filterType = option
                                    }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 0)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }

                ForEach(groupedEvents, id: \.0) { dateString, events in
                    Section(dateString) {
                        ForEach(events) { event in
                            HistoryEventRow(event: event)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if !store.historyEvents.isEmpty {
                        Button {
                            if subscription.canExport {
                                shareComplianceReport()
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .overlay {
                if store.historyEvents.isEmpty {
                    ContentUnavailableView("No History", systemImage: "clock", description: Text("Your compliance events will appear here."))
                }
            }
            .sheet(isPresented: $showPaywall) {
                UpgradePaywallView()
            }
        }
    }

    private func shareComplianceReport() {
        var report = "DOT Ready Compliance Report\n"
        report += "Generated: \(Date().formatted(date: .abbreviated, time: .shortened))\n\n"

        if store.driverProfile.isSetUp {
            report += "Driver: \(store.driverProfile.name)\n"
            report += "CDL: \(store.driverProfile.cdlNumber) (\(store.driverProfile.cdlState))\n"
            report += "Class: \(store.driverProfile.cdlClass.rawValue)\n\n"
        }

        report += "Compliance Items:\n"
        for item in store.complianceItems {
            report += "• \(item.name) — \(item.status.rawValue)"
            if let days = item.daysRemaining {
                report += " (\(days) days)"
            }
            report += "\n"
        }

        let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct HistoryEventRow: View {
    let event: HistoryEvent

    private var iconColor: Color {
        switch event.type {
        case .complianceAdded, .inspectionCompleted: return AppColors.compliant
        case .complianceExpired: return AppColors.expired
        case .complianceUpdated, .profileUpdated: return AppColors.dotBlue
        case .documentAdded: return .orange
        case .vehicleAdded: return AppColors.navy
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type.icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    if !event.detail.isEmpty {
                        Text(event.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                    }
                    Text(event.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
