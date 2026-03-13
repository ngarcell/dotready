import SwiftUI

struct InspectionSummaryView: View {
    let inspection: Inspection
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultHeader
                statsGrid
                sectionBreakdown
                Button(action: onSave) {
                    Text("Save Inspection")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.dotBlue)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Inspection Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: inspection.failCount == 0 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(inspection.failCount == 0 ? AppColors.compliant : AppColors.expired)

            Text(inspection.result)
                .font(.title.bold())
                .foregroundStyle(inspection.failCount == 0 ? AppColors.compliant : AppColors.expired)

            if let duration = inspection.duration {
                Text("Duration: \(formattedDuration(duration))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(inspection.passCount)", label: "Pass", color: AppColors.compliant)
            StatCard(value: "\(inspection.failCount)", label: "Fail", color: AppColors.expired)
            StatCard(value: "\(inspection.naCount)", label: "N/A", color: .secondary)
        }
    }

    private var sectionBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Section Breakdown")
                .font(.headline)

            ForEach(InspectionSection.allCases, id: \.rawValue) { section in
                let sectionPoints = inspection.points.filter { $0.section == section }
                let fails = sectionPoints.filter { $0.status == .fail }.count
                let hasFails = fails > 0

                HStack {
                    Image(systemName: section.icon)
                        .font(.subheadline)
                        .foregroundStyle(hasFails ? AppColors.expired : AppColors.compliant)
                        .frame(width: 24)
                    Text(section.rawValue)
                        .font(.subheadline)
                    Spacer()
                    if hasFails {
                        Text("\(fails) issue\(fails == 1 ? "" : "s")")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppColors.expired)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.compliant)
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 8))
            }
        }
    }

    private func formattedDuration(_ interval: TimeInterval) -> String {
        let min = Int(interval) / 60
        let sec = Int(interval) % 60
        return "\(min)m \(sec)s"
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
