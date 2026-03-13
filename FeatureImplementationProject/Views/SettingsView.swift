import SwiftUI

struct SettingsView: View {
    @Environment(DataStore.self) private var store
    @Environment(SubscriptionManager.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showProfile = false
    @State private var showVehicles = false
    @State private var showResetAlert = false
    @State private var showPaywall = false
    @State private var showDrugTests = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button { showProfile = true } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.dotBlue)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.driverProfile.isSetUp ? store.driverProfile.name : "Set Up Profile")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(store.driverProfile.isSetUp ? "CDL \(store.driverProfile.cdlNumber)" : "Tap to configure")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                if !subscription.isPro {
                    Section {
                        Button { showPaywall = true } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(AppColors.highwayYellow)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Upgrade to Pro")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("Unlimited items, reminders, document vault")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("$5/mo")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.dotBlue)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundStyle(AppColors.compliant)
                            Text("DOT Ready Pro")
                                .font(.body.weight(.medium))
                            Spacer()
                            if subscription.isTrialActive, let days = subscription.trialDaysRemaining {
                                Text("Trial: \(days)d left")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Active")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.compliant)
                            }
                        }
                    }
                }

                Section("General") {
                    Button { showVehicles = true } label: {
                        Label {
                            HStack {
                                Text("Vehicles").foregroundStyle(.primary)
                                Spacer()
                                Text("\(store.vehicles.count)").foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "truck.box")
                        }
                    }
                    .buttonStyle(.plain)

                    Button { showDrugTests = true } label: {
                        Label {
                            HStack {
                                Text("Drug & Alcohol Tests").foregroundStyle(.primary)
                                Spacer()
                                Text("\(store.drugTests.count)").foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "flask")
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Expiration Reminders", systemImage: "bell")
                    }
                    .disabled(!subscription.canUseReminders)
                    if !subscription.canUseReminders {
                        Text("Upgrade to Pro for reminders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Security") {
                    Toggle(isOn: $biometricLockEnabled) {
                        Label("Biometric Lock", systemImage: "faceid")
                    }
                }

                Section("Data") {
                    HStack {
                        Label("Compliance Items", systemImage: "shield")
                        Spacer()
                        Text("\(store.complianceItems.count)").foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Documents", systemImage: "doc")
                        Spacer()
                        Text("\(store.documents.count)").foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Inspections", systemImage: "clipboard")
                        Spacer()
                        Text("\(store.inspections.count)").foregroundStyle(.secondary)
                    }
                    Button(role: .destructive) { showResetAlert = true } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }

                Section("About") {
                    LabeledRow(label: "Version", value: "1.0.0")
                    HStack {
                        Text("Storage").foregroundStyle(.secondary)
                        Spacer()
                        Text("100% Local").font(.subheadline)
                    }
                    HStack {
                        Text("Privacy").foregroundStyle(.secondary)
                        Spacer()
                        Text("No ads · No tracking").font(.subheadline)
                    }
                }

                Section {
                    Text("DOT Ready helps track compliance dates and documents. It does not certify FMCSA/DOT/state compliance. Drivers and carriers are responsible for all required records and program participation.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showProfile) {
                DriverProfileView()
            }
            .sheet(isPresented: $showVehicles) {
                VehicleManagementView()
            }
            .sheet(isPresented: $showPaywall) {
                UpgradePaywallView()
            }
            .sheet(isPresented: $showDrugTests) {
                DrugTestLogView()
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { store.resetAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your compliance items, documents, inspections, and history. This cannot be undone.")
            }
        }
    }
}
