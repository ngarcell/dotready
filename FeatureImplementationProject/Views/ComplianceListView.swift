import SwiftUI

struct ComplianceListView: View {
    @Environment(DataStore.self) private var store
    @Environment(SubscriptionManager.self) private var subscription
    @State private var searchText = ""
    @State private var selectedCategory: ComplianceCategory?
    @State private var showAddItem = false
    @State private var selectedItem: ComplianceItem?
    @State private var showPaywall = false

    private var filteredItems: [ComplianceItem] {
        var items = store.complianceItems
        if let cat = selectedCategory {
            items = items.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return items.sorted { ($0.daysRemaining ?? Int.max) < ($1.daysRemaining ?? Int.max) }
    }

    private var groupedItems: [(String, [ComplianceItem])] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category.groupName }
        let order: [String] = ["CDL & Endorsements", "DOT Medical", "Drug & Alcohol", "Vehicle", "Insurance", "Training & Certifications", "Safety", "Other"]
        return order.compactMap { group in
            guard let items = grouped[group], !items.isEmpty else { return nil }
            return (group, items)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !store.complianceItems.isEmpty {
                    categoryFilter
                }

                if selectedCategory != nil {
                    ForEach(filteredItems) { item in
                        Button { selectedItem = item } label: {
                            ComplianceItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteComplianceItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } else {
                    ForEach(groupedItems, id: \.0) { group, items in
                        Section(group) {
                            ForEach(items) { item in
                                Button { selectedItem = item } label: {
                                    ComplianceItemRow(item: item)
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        store.deleteComplianceItem(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search compliance items")
            .navigationTitle("Compliance")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if subscription.canAddComplianceItem(currentCount: store.complianceItems.count) {
                            showAddItem = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if store.complianceItems.isEmpty {
                    ContentUnavailableView("No Compliance Items", systemImage: "shield", description: Text("Add your first compliance item to start tracking."))
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddComplianceItemView()
            }
            .sheet(item: $selectedItem) { item in
                ComplianceDetailView(item: item)
            }
            .sheet(isPresented: $showPaywall) {
                UpgradePaywallView()
            }
        }
    }

    private var categoryFilter: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterChip(label: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(ComplianceCategory.allCases) { category in
                        FilterChip(label: category.rawValue, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? AppColors.dotBlue : Color(.tertiarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct ComplianceItemRow: View {
    let item: ComplianceItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundStyle(AppColors.statusColor(for: item.status))
                .frame(width: 36, height: 36)
                .background(AppColors.statusColor(for: item.status).opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.medium))
                HStack(spacing: 6) {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let days = item.daysRemaining {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(daysLabel(days))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppColors.statusColor(for: item.status))
                    }
                }
            }

            Spacer()

            StatusBadge(status: item.status)
        }
        .padding(.vertical, 2)
    }

    private func daysLabel(_ days: Int) -> String {
        if days < 0 { return "\(abs(days))d overdue" }
        if days == 0 { return "Today" }
        return "\(days)d left"
    }
}

struct StatusBadge: View {
    let status: ComplianceStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColors.statusColor(for: status).opacity(0.12))
            .foregroundStyle(AppColors.statusColor(for: status))
            .clipShape(Capsule())
    }
}
