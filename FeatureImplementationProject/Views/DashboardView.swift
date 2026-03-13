import SwiftUI

struct DashboardView: View {
    @Environment(DataStore.self) private var store
    @Environment(SubscriptionManager.self) private var subscription
    @State private var showInspection = false
    @State private var showRoadsideSummary = false
    @State private var showAddItem = false
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    driverCard
                    statusBadge
                    if !subscription.isPro && !store.complianceItems.isEmpty {
                        freeTierBanner
                    }
                    urgentItemsSection
                    quickActionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showInspection) {
                PreTripInspectionView()
            }
            .sheet(isPresented: $showAddItem) {
                AddComplianceItemView()
            }
            .fullScreenCover(isPresented: $showRoadsideSummary) {
                RoadsideReadySummaryView()
            }
            .sheet(isPresented: $showProfile) {
                DriverProfileView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                UpgradePaywallView()
            }
        }
    }

    private var driverCard: some View {
        Button { showProfile = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.dotBlue)
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    if store.driverProfile.isSetUp {
                        Text(store.driverProfile.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("CDL \(store.driverProfile.cdlNumber) · \(store.driverProfile.cdlState)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Set Up Your Profile")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Tap to add your CDL info")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private var statusBadge: some View {
        VStack(spacing: 12) {
            Image(systemName: store.isRoadsideReady ? "shield.checkmark.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(store.isRoadsideReady ? AppColors.compliant : AppColors.expired)
                .symbolEffect(.bounce, value: store.isRoadsideReady)

            Text(store.overallStatus)
                .font(.title2.bold())
                .foregroundStyle(store.isRoadsideReady ? AppColors.compliant : AppColors.expired)

            Text(store.isRoadsideReady ? "All compliance items are current" : "Some items need your attention")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var freeTierBanner: some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundStyle(AppColors.highwayYellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Free Plan — \(store.complianceItems.count)/\(subscription.maxFreeItems) items")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Upgrade for unlimited tracking & reminders")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(14)
            .background(AppColors.dotBlue)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var urgentItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Items")
                .font(.headline)
                .padding(.leading, 4)

            if store.urgentItems.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.compliant)
                    Text("No urgent items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(store.urgentItems.enumerated()), id: \.element.id) { index, item in
                        UrgentItemRow(item: item)
                        if index < store.urgentItems.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionButton(icon: "clipboard.fill", label: "Pre-Trip", color: AppColors.dotBlue) {
                    showInspection = true
                }
                QuickActionButton(icon: "shield.checkmark.fill", label: "Roadside", color: AppColors.compliant) {
                    showRoadsideSummary = true
                }
                QuickActionButton(icon: "plus.circle.fill", label: "Add Item", color: .blue) {
                    if subscription.canAddComplianceItem(currentCount: store.complianceItems.count) {
                        showAddItem = true
                    } else {
                        showPaywall = true
                    }
                }
            }
        }
    }

}

struct UrgentItemRow: View {
    let item: ComplianceItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundStyle(AppColors.statusColor(for: item.status))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                if let days = item.daysRemaining {
                    Text(daysText(days))
                        .font(.caption)
                        .foregroundStyle(AppColors.statusColor(for: item.status))
                }
            }

            Spacer()

            if let days = item.daysRemaining {
                Text("\(abs(days))")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(AppColors.statusColor(for: item.status))
                Text(days >= 0 ? "days" : "overdue")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
    }

    private func daysText(_ days: Int) -> String {
        if days < 0 { return "Expired \(abs(days)) days ago" }
        if days == 0 { return "Expires today" }
        return "Expires in \(days) days"
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
