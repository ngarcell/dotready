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
    static let monthlyProductID = "com.softlog.dotready.monthly"
    static let annualProductID = "com.softlog.dotready.annual"

    var currentTier: SubscriptionTier = .free
    var isTrialActive: Bool = false
    var trialEndDate: Date?
    var isLoading = false
    var errorMessage: String?

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

    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            for await entitlement in Transaction.currentEntitlements {
                if case .verified(let transaction) = entitlement {
                    await handleVerifiedTransaction(transaction)
                    return true
                }
            }
            return false
        } catch {
            errorMessage = "Failed to restore purchases. Please try again."
            return false
        }
    }

    func purchaseProduct(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                if case .verified(let transaction) = verificationResult {
                    await handleVerifiedTransaction(transaction)
                    await transaction.finish()
                    return true
                } else {
                    errorMessage = "Purchase verification failed."
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                errorMessage = "Purchase is pending approval."
                return false
            @unknown default:
                errorMessage = "Purchase failed. Please try again."
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        if let expirationDate = transaction.expirationDate, expirationDate > Date() {
            trialEndDate = expirationDate
            isTrialActive = true
            UserDefaults.standard.set(expirationDate, forKey: trialKey)
        }
        
        switch transaction.productType {
        case .autoRenewable:
            currentTier = .pro
            UserDefaults.standard.set(SubscriptionTier.pro.rawValue, forKey: tierKey)
        default:
            break
        }
    }

    func checkCurrentEntitlements() async {
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                await handleVerifiedTransaction(transaction)
            }
        }
    }
}
