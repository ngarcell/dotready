import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "shield.checkmark.fill", value: 0) {
                DashboardView()
            }
            Tab("Compliance", systemImage: "checklist", value: 1) {
                ComplianceListView()
            }
            Tab("Documents", systemImage: "doc.text.fill", value: 2) {
                DocumentsGalleryView()
            }
            Tab("History", systemImage: "clock.fill", value: 3) {
                HistoryView()
            }
        }
        .tint(AppColors.dotBlue)
    }
}
