import Foundation
import SwiftUI
import StoreKit

nonisolated enum SubscriptionTier: String, Codable, Sendable {
    case free = "Free"
    case pro = "Pro"
    case fleet = "Fleet"
}

@Observable
@MainActor
class SubscriptionManager {
    var currentTier: SubscriptionTier = .free
    var isTrialActive: Bool = false
    var trialEndDate: Date?

    private let tierKey = "subscription_tier"
    private let trialKey = "trial_end_date"
    private let dismissedPaywallKey = "dismissed_paywall"

    var isPro: Bool { currentTier == .pro || currentTier == .fleet || isTrialActive }
    var isFleet: Bool { currentTier == .fleet }

    var trialDaysRemaining: Int? {
        guard let endDate = trialEndDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }

    let maxFreeItems = 3

    func canAddComplianceItem(currentCount: Int) -> Bool {
        isPro || currentCount < maxFreeItems
    }

    var canUseReminders: Bool { isPro }
    var canUseDocumentVault: Bool { isPro }
    var canExport: Bool { isPro }
    var canUseOfficerMode: Bool { isPro }

    init() {
        loadState()
    }

    private func loadState() {
        if let tierRaw = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: tierRaw) {
            currentTier = tier
        }
        if let trialEnd = UserDefaults.standard.object(forKey: trialKey) as? Date {
            trialEndDate = trialEnd
            isTrialActive = trialEnd > Date()
        }
    }

    func startTrial() {
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        trialEndDate = endDate
        isTrialActive = true
        UserDefaults.standard.set(endDate, forKey: trialKey)
    }

    func activateSubscription(tier: SubscriptionTier) {
        currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
    }

    func dismissPaywall() {
        UserDefaults.standard.set(true, forKey: dismissedPaywallKey)
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
        }
    }
}
