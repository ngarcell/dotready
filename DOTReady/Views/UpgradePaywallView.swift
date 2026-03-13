import SwiftUI
import UIKit

struct UpgradePaywallView: View {
    @Environment(SubscriptionManager.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PaywallPlan = .annual

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "shield.checkmark.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(AppColors.dotBlue)

                        Text("Unlock DOT Ready Pro")
                            .font(.title2.bold())

                        Text("Unlimited compliance tracking, reminders, document vault, and more.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "infinity", text: "Unlimited compliance items")
                        FeatureRow(icon: "bell.badge.fill", text: "Expiration reminders (90/60/30/14/7 days)")
                        FeatureRow(icon: "doc.viewfinder", text: "Document vault with photo storage")
                        FeatureRow(icon: "person.badge.shield.checkmark", text: "\"Show to Officer\" presentation mode")
                        FeatureRow(icon: "square.and.arrow.up", text: "Export compliance reports")
                        FeatureRow(icon: "clipboard.fill", text: "Pre-trip inspection checklists")
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 14))

                    VStack(spacing: 10) {
                        PlanCard(plan: .annual, isSelected: selectedPlan == .annual) { selectedPlan = .annual }
                        PlanCard(plan: .monthly, isSelected: selectedPlan == .monthly) { selectedPlan = .monthly }
                    }

                    Button {
                        subscription.startTrial()
                        dismiss()
                    } label: {
                        Text("Start Free Trial")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.dotBlue)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    if let errorMessage = subscription.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 16) {
                        Button("Restore Purchases") { Task { 
                            let success = await subscription.restorePurchases()
                            if success {
                                dismiss()
                            }
                        } }
                        Text("·").foregroundStyle(.tertiary)
                        Button("Terms") { 
                            if let url = URL(string: "https://yourdomain.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        Text("·").foregroundStyle(.tertiary)
                        Button("Privacy") { 
                            if let url = URL(string: "https://yourdomain.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppColors.dotBlue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}
