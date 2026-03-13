import SwiftUI
import UserNotifications
import StoreKit

struct OnboardingContainerView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var driverType: DriverType?
    @State private var cdlClass: CDLClassOption?
    @State private var selectedEndorsements: Set<Endorsement> = []
    @State private var stateCount: StateCount?
    @State private var trackingMethod: TrackingMethod?
    @State private var selectedPlan: PaywallPlan = .annual
    @State private var showFeedbackField = false
    @State private var feedbackText = ""
    @State private var processingProgress: Double = 0
    @State private var currentProcessingMessage = ""

    private let totalPages = 12

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if currentPage > 0 && currentPage < 11 {
                    onboardingProgress
                }

                TabView(selection: $currentPage) {
                    welcomeScreen.tag(0)
                    driverTypeScreen.tag(1)
                    cdlClassScreen.tag(2)
                    endorsementsScreen.tag(3)
                    statesScreen.tag(4)
                    trackingMethodScreen.tag(5)
                    processingScreen.tag(6)
                    notificationScreen.tag(7)
                    ratingScreen.tag(8)
                    profileReadyScreen.tag(9)
                    trialReminderScreen.tag(10)
                    paywallScreen.tag(11)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }

    private var onboardingProgress: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? AppColors.dotBlue : Color(.systemGray4))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var welcomeScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "shield.checkmark.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppColors.dotBlue)
                    .symbolEffect(.pulse.byLayer)

                VStack(spacing: 12) {
                    Text("Don't get put out of service\nfor an expired medical card.")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Trusted by 20,000+ CDL drivers\nfor DOT compliance tracking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    BulletRow(text: "Track your DOT medical, CDL, and certifications")
                    BulletRow(text: "Get renewal reminders months in advance")
                    BulletRow(text: "Show documents instantly at any roadside inspection")
                }
                .padding(.horizontal, 8)
            }
            Spacer()
            OnboardingCTAButton(title: "Get Started — Free") { advancePage() }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }

    private var driverTypeScreen: some View {
        OnboardingQuestionScreen(title: "What kind of driver are you?") {
            VStack(spacing: 12) {
                ForEach(DriverType.allCases, id: \.rawValue) { type in
                    OnboardingOptionCard(
                        icon: type.icon, title: type.rawValue,
                        isSelected: driverType == type
                    ) {
                        driverType = type
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { advancePage() }
                    }
                }
            }
        }
    }

    private var cdlClassScreen: some View {
        OnboardingQuestionScreen(title: "What CDL class?", subtitle: "CDL class determines your compliance requirements") {
            VStack(spacing: 12) {
                ForEach(CDLClassOption.allCases, id: \.rawValue) { cls in
                    OnboardingOptionCard(
                        icon: "rectangle.badge.person.crop", title: cls.rawValue,
                        subtitle: cls.subtitle, isSelected: cdlClass == cls
                    ) {
                        cdlClass = cls
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { advancePage() }
                    }
                }
            }
        }
    }

    private var endorsementsScreen: some View {
        OnboardingQuestionScreen(title: "What endorsements?", subtitle: "Each has its own renewal requirements") {
            VStack(spacing: 12) {
                ForEach(Endorsement.allCases.filter { $0 != .none }) { endorsement in
                    OnboardingCheckCard(title: endorsement.fullName, isSelected: selectedEndorsements.contains(endorsement)) {
                        if selectedEndorsements.contains(endorsement) {
                            selectedEndorsements.remove(endorsement)
                        } else {
                            selectedEndorsements.insert(endorsement)
                        }
                    }
                }
                OnboardingCTAButton(title: "Continue") { advancePage() }
                    .padding(.top, 8)
            }
        }
    }

    private var statesScreen: some View {
        OnboardingQuestionScreen(title: "How many states?", subtitle: "Multi-state drivers have more compliance touchpoints — we'll track them all") {
            VStack(spacing: 12) {
                ForEach(StateCount.allCases, id: \.rawValue) { count in
                    OnboardingOptionCard(icon: "map", title: count.rawValue, subtitle: count.subtitle, isSelected: stateCount == count) {
                        stateCount = count
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { advancePage() }
                    }
                }
            }
        }
    }

    private var trackingMethodScreen: some View {
        OnboardingQuestionScreen(title: "How do you track compliance today?") {
            VStack(spacing: 12) {
                ForEach(TrackingMethod.allCases, id: \.rawValue) { method in
                    OnboardingOptionCard(icon: method.icon, title: method.rawValue, isSelected: trackingMethod == method) {
                        trackingMethod = method
                    }
                }
                if let trackingMethod {
                    Text(trackingMethod.painPoint)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.expired)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    OnboardingCTAButton(title: "Continue") { advancePage() }
                        .padding(.top, 4)
                }
            }
            .animation(.spring(duration: 0.4), value: trackingMethod != nil)
        }
    }

    private var processingScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: processingProgress)
                        .stroke(AppColors.dotBlue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppColors.dotBlue)
                        .symbolEffect(.rotate, value: processingProgress)
                }
                Text("Building your compliance plan")
                    .font(.title3.bold())
                Text(currentProcessingMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(height: 40)
            }
            Spacer()
        }
        .onAppear { startProcessingAnimation() }
    }

    private var notificationScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.dotBlue)
                VStack(spacing: 8) {
                    Text("Stay ahead of every\ncompliance deadline")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text("Get reminders before expirations, inspections, and required updates")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 10) {
                    NotifPreview(icon: "exclamationmark.triangle.fill", color: .orange, text: "DOT medical expires in 60 days — schedule your physical")
                    NotifPreview(icon: "clipboard.fill", color: AppColors.dotBlue, text: "Annual vehicle inspection due next month")
                    NotifPreview(icon: "checkmark.circle.fill", color: AppColors.compliant, text: "All certifications current — haul with confidence")
                }
                .padding(.horizontal, 8)
            }
            Spacer()
            VStack(spacing: 12) {
                OnboardingCTAButton(title: "Enable Notifications") { requestNotifications() }
                Button("Not now") { advancePage() }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var ratingScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "star.bubble.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.highwayYellow)
                Text("How is DOT Ready\nlooking so far?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                VStack(spacing: 12) {
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            AppStore.requestReview(in: scene)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { advancePage() }
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Rate App")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.dotBlue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    Button {
                        showFeedbackField = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Send Feedback")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.primary)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    if showFeedbackField {
                        VStack(spacing: 8) {
                            TextField("What could be better?", text: $feedbackText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)
                            Button("Submit & Continue") { advancePage() }
                                .font(.subheadline.weight(.medium))
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 24)
            Spacer()
            Button("Skip") { advancePage() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
    }

    private var profileReadyScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.compliant)
                    .symbolEffect(.bounce)
                Text("Your compliance\nprofile is ready")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                VStack(spacing: 14) {
                    ProfileRow(icon: "truck.box.fill", label: "Class", value: cdlClass?.rawValue ?? "A")
                    ProfileRow(icon: "checkmark.seal.fill", label: "Endorsements", value: selectedEndorsements.isEmpty ? "None" : selectedEndorsements.map(\.rawValue).joined(separator: ", "))
                    ProfileRow(icon: "map.fill", label: "States", value: stateCount?.rawValue ?? "1")
                    ProfileRow(icon: "clock.fill", label: "Tracking", value: "Active")
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            Spacer()
            OnboardingCTAButton(title: "Stay Compliant — Free for 7 Days") { advancePage() }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }

    private var trialReminderScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppColors.dotBlue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.dotBlue)
                }
                VStack(spacing: 8) {
                    Text("We'll remind you before\nyour free trial ends")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text("Day 6 of 7: Reminder scheduled")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                }
                VStack(alignment: .leading, spacing: 14) {
                    BulletRow(text: "Full access for 7 days — compliance tracking unlocked")
                    BulletRow(text: "Cancel anytime with one tap")
                    BulletRow(text: "We'll remind you 24 hours before your trial ends")
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            OnboardingCTAButton(title: "Continue") { advancePage() }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }

    private var paywallScreen: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkmark.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.dotBlue)
                    Text("DOT Ready Pro")
                        .font(.title.bold())
                    Text("An expired DOT medical = automatic CDL downgrade = no income.\nDOT Ready is $5/month.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                VStack(spacing: 10) {
                    PlanCard(plan: .annual, isSelected: selectedPlan == .annual) { selectedPlan = .annual }
                    PlanCard(plan: .monthly, isSelected: selectedPlan == .monthly) { selectedPlan = .monthly }
                }

                Text("80% of drivers choose annual — cancel anytime.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                let trialEnd = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                Text("Your free trial starts today. You'll be charged \(selectedPlan == .annual ? "$59.99" : "$9.99") on \(trialEnd.formatted(date: .abbreviated, time: .omitted)) unless you cancel. Cancel anytime in Settings.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)

                OnboardingCTAButton(title: "Start Free Trial") {
                    subscriptionManager.startTrial()
                    completeOnboarding()
                }

                HStack(spacing: 16) {
                    Button("Restore Purchases") { Task { await subscriptionManager.restorePurchases() } }
                    Text("·").foregroundStyle(.tertiary)
                    Button("Terms of Service") {}
                    Text("·").foregroundStyle(.tertiary)
                    Button("Privacy Policy") {}
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                Button("Not now") {
                    subscriptionManager.dismissPaywall()
                    completeOnboarding()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

                Text("DOT Ready helps track compliance dates and documents. It does not certify FMCSA/DOT/state compliance. Drivers and carriers are responsible for all required records and program participation.")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions

    private func advancePage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = min(currentPage + 1, totalPages - 1)
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async { advancePage() }
        }
    }

    private func startProcessingAnimation() {
        let messages = [
            "Configuring your CDL class requirements...",
            "Setting up endorsement-specific renewals...",
            "Preparing multi-state compliance tracking...",
            "Building your reminder timeline..."
        ]
        currentProcessingMessage = messages[0]
        for (index, message) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.9) {
                withAnimation {
                    currentProcessingMessage = message
                    processingProgress = Double(index + 1) / Double(messages.count)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) { advancePage() }
    }
}

// MARK: - Paywall Plan

nonisolated enum PaywallPlan: String, Sendable {
    case annual, monthly

    var price: String {
        switch self {
        case .annual: return "$59.99/yr"
        case .monthly: return "$9.99/mo"
        }
    }

    var perMonth: String {
        switch self {
        case .annual: return "$5.00/month"
        case .monthly: return "$9.99/month"
        }
    }
}

// MARK: - Subviews

struct OnboardingCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.dotBlue)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
        }
    }
}

struct BulletRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(AppColors.compliant)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct OnboardingOptionCard: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : AppColors.dotBlue)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? AppColors.dotBlue : AppColors.dotBlue.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.body.weight(.medium)).foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppColors.dotBlue : Color(.systemGray3))
            }
            .padding(14)
            .background(isSelected ? AppColors.dotBlue.opacity(0.08) : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? AppColors.dotBlue : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct OnboardingCheckCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).font(.body.weight(.medium))
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppColors.dotBlue : Color(.systemGray3))
            }
            .padding(14)
            .background(isSelected ? AppColors.dotBlue.opacity(0.08) : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingQuestionScreen<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(title).font(.title2.bold()).multilineTextAlignment(.center)
                    if let subtitle {
                        Text(subtitle).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                content
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct NotifPreview: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 6))
            Text(text).font(.caption).lineLimit(2)
            Spacer()
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.body).foregroundStyle(AppColors.dotBlue).frame(width: 24)
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }
}

struct PlanCard: View {
    let plan: PaywallPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                if plan == .annual {
                    Text("Save 50%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(AppColors.compliant)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(plan == .annual ? "Annual" : "Monthly").font(.headline)
                            if plan == .annual {
                                Text("7-day trial")
                                    .font(.caption2.weight(.medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.dotBlue.opacity(0.12))
                                    .foregroundStyle(AppColors.dotBlue)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(plan.perMonth).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(plan.price).font(.title3.bold())
                        if plan == .monthly {
                            Text("$119.88/year").font(.caption).foregroundStyle(.tertiary).strikethrough()
                        }
                    }
                }
                .padding(16)
            }
            .background(isSelected ? AppColors.dotBlue.opacity(0.06) : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? AppColors.dotBlue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}
