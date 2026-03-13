import SwiftUI

struct ComplianceDetailView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let item: ComplianceItem
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: item.category.icon)
                            .font(.largeTitle)
                            .foregroundStyle(AppColors.statusColor(for: item.status))
                            .frame(width: 60, height: 60)
                            .background(AppColors.statusColor(for: item.status).opacity(0.12))
                            .clipShape(.rect(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.title3.bold())
                            StatusBadge(status: item.status)
                        }
                        .padding(.leading, 4)
                    }
                    .listRowBackground(Color.clear)
                }

                if let days = item.daysRemaining {
                    Section {
                        HStack {
                            Label("Days Remaining", systemImage: "clock")
                            Spacer()
                            Text("\(days)")
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(AppColors.statusColor(for: item.status))
                        }
                    }
                }

                Section("Details") {
                    LabeledRow(label: "Category", value: item.category.rawValue)
                    if !item.issuingBody.isEmpty {
                        LabeledRow(label: "Issuing Body", value: item.issuingBody)
                    }
                    if !item.credentialNumber.isEmpty {
                        LabeledRow(label: "Credential #", value: item.credentialNumber)
                    }
                    if let issueDate = item.issueDate {
                        LabeledRow(label: "Issue Date", value: issueDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let expDate = item.expirationDate {
                        LabeledRow(label: "Expiration Date", value: expDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }

                if !item.notes.isEmpty {
                    Section("Notes") {
                        Text(item.notes)
                            .font(.body)
                    }
                }

                let linkedDocs = store.documentsForItem(item)
                if !linkedDocs.isEmpty {
                    Section("Linked Documents") {
                        ForEach(linkedDocs) { doc in
                            Label(doc.name, systemImage: doc.category.icon)
                        }
                    }
                }

                Section("Reminders") {
                    ForEach(item.reminderDays.sorted(by: >), id: \.self) { day in
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(AppColors.dotBlue)
                                .font(.caption)
                            Text(day == 0 ? "On expiration day" : "\(day) days before")
                                .font(.subheadline)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Item", systemImage: "trash")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showEdit = true }
                }
            }
            .sheet(isPresented: $showEdit) {
                AddComplianceItemView(editItem: item)
            }
            .alert("Delete Item?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    store.deleteComplianceItem(item)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \"\(item.name)\".")
            }
        }
    }
}

struct LabeledRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
