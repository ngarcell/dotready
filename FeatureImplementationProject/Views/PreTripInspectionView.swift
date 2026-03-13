import SwiftUI

struct PreTripInspectionView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var inspection: Inspection
    @State private var currentSectionIndex = 0
    @State private var elapsedSeconds: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var showSummary = false
    @State private var overallNotes = ""
    @State private var selectedVehicleID: UUID?

    init() {
        _inspection = State(initialValue: Inspection.createNew())
    }

    private var sections: [InspectionSection] { InspectionSection.allCases }
    private var currentSection: InspectionSection { sections[currentSectionIndex] }

    private var currentPoints: [InspectionPoint] {
        inspection.points.filter { $0.section == currentSection }
    }

    private var progress: Double {
        let total = Double(inspection.points.count)
        let checked = Double(inspection.points.filter { $0.status != .unchecked }.count)
        return total > 0 ? checked / total : 0
    }

    var body: some View {
        NavigationStack {
            if showSummary {
                InspectionSummaryView(inspection: inspection) {
                    var final = inspection
                    final.endTime = Date()
                    final.overallNotes = overallNotes
                    final.vehicleID = selectedVehicleID
                    if let v = store.vehicles.first(where: { $0.id == selectedVehicleID }) {
                        final.vehicleName = v.displayName
                    }
                    store.addInspection(final)
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    inspectionHeader
                    sectionContent
                    navigationFooter
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Pre-Trip Inspection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            timerTask?.cancel()
                            dismiss()
                        }
                    }
                }
                .onAppear { startTimer() }
                .onDisappear { timerTask?.cancel() }
            }
        }
    }

    private var inspectionHeader: some View {
        VStack(spacing: 10) {
            HStack {
                if !store.vehicles.isEmpty {
                    Menu {
                        Button("No Vehicle") { selectedVehicleID = nil }
                        ForEach(store.vehicles) { v in
                            Button(v.displayName) { selectedVehicleID = v.id }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "truck.box")
                            Text(selectedVehicleID.flatMap { id in store.vehicles.first { $0.id == id }?.displayName } ?? "Select Vehicle")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                    Text(formattedTime)
                        .font(.subheadline.monospacedDigit())
                }
                .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(AppColors.dotBlue)

            HStack {
                Text("Section \(currentSectionIndex + 1) of \(sections.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progress * 100))% complete")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.dotBlue)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var sectionContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: currentSection.icon)
                        .font(.title2)
                        .foregroundStyle(AppColors.dotBlue)
                    Text(currentSection.rawValue)
                        .font(.title3.bold())
                }
                .padding(.top, 4)

                ForEach(currentPoints) { point in
                    InspectionPointRow(point: point) { updatedPoint in
                        if let idx = inspection.points.firstIndex(where: { $0.id == updatedPoint.id }) {
                            inspection.points[idx] = updatedPoint
                        }
                    }
                }

                if inspection.points.filter({ $0.section == currentSection && $0.status == .fail }).count > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.expired)
                        Text("Vehicle must not be operated until defects are corrected (per 49 CFR 396.7)")
                            .font(.caption)
                            .foregroundStyle(AppColors.expired)
                    }
                    .padding(12)
                    .background(AppColors.expired.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding()
        }
    }

    private var navigationFooter: some View {
        HStack(spacing: 12) {
            if currentSectionIndex > 0 {
                Button {
                    withAnimation { currentSectionIndex -= 1 }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }

            if currentSectionIndex < sections.count - 1 {
                Button {
                    withAnimation { currentSectionIndex += 1 }
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.dotBlue)
            } else {
                Button {
                    timerTask?.cancel()
                    showSummary = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Finish")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.compliant)
                .sensoryFeedback(.success, trigger: showSummary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var formattedTime: String {
        let min = elapsedSeconds / 60
        let sec = elapsedSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    elapsedSeconds += 1
                }
            }
        }
    }
}

struct InspectionPointRow: View {
    let point: InspectionPoint
    let onUpdate: (InspectionPoint) -> Void
    @State private var showNotes = false
    @State private var noteText: String

    init(point: InspectionPoint, onUpdate: @escaping (InspectionPoint) -> Void) {
        self.point = point
        self.onUpdate = onUpdate
        _noteText = State(initialValue: point.notes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(point.name)
                    .font(.body)

                Spacer()

                HStack(spacing: 6) {
                    StatusToggle(label: "OK", isSelected: point.status == .pass, color: AppColors.compliant) {
                        var p = point; p.status = .pass; onUpdate(p)
                    }
                    StatusToggle(label: "X", isSelected: point.status == .fail, color: AppColors.expired) {
                        var p = point; p.status = .fail; onUpdate(p)
                    }
                    StatusToggle(label: "N/A", isSelected: point.status == .na, color: .secondary) {
                        var p = point; p.status = .na; onUpdate(p)
                    }
                }

                Button { showNotes.toggle() } label: {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundStyle(noteText.isEmpty ? Color.secondary.opacity(0.5) : AppColors.dotBlue)
                }
            }

            if showNotes {
                TextField("Notes...", text: $noteText, axis: .vertical)
                    .font(.caption)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: noteText) { _, newValue in
                        var p = point; p.notes = newValue; onUpdate(p)
                    }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
        .sensoryFeedback(.selection, trigger: point.status)
    }
}

struct StatusToggle: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.bold))
                .frame(width: 32, height: 28)
                .background(isSelected ? color : Color(.tertiarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .secondary)
                .clipShape(.rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
