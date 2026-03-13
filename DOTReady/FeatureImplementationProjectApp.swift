import SwiftUI

@main
struct FeatureImplementationProjectApp: App {
    @State private var store = DataStore()
    @State private var subscriptionManager = SubscriptionManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environment(store)
                    .environment(subscriptionManager)
            } else {
                OnboardingContainerView()
                    .environment(store)
                    .environment(subscriptionManager)
            }
        }
    }
}
