import SwiftUI

struct DrugTestLogView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showAddTest = false

    var body: some View {
        NavigationStack {
            List {
                if store.drugTests.isEmpty {
                    Section {
                        VStack(spacing: 8) {
                            Text("No drug tests logged")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Only dates and test types are stored — never results.")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }

                ForEach(store.drugTests) { test in
                    HStack(spacing: 12) {
                        Image(systemName: test.type.icon)
                            .font(.body)
                            .foregroundStyle(AppColors.dotBlue)
                            .frame(width: 32, height: 32)
                            .background(AppColors.dotBlue.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(test.type.rawValue)
                                .font(.subheadline.weight(.medium))
                            Text(test.testDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !test.notes.isEmpty {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.deleteDrugTest(test)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                if let lastRandom = store.lastRandomTestDate {
                    Section("Info") {
                        HStack {
                            Text("Last Random Test")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(lastRandom.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Drug & Alcohol Tests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddTest = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTest) {
                AddDrugTestView()
            }
        }
    }
}

struct AddDrugTestView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var testType: DrugTestType = .random
    @State private var testDate: Date = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Test Info") {
                    Picker("Test Type", selection: $testType) {
                        ForEach(DrugTestType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DatePicker("Test Date", selection: $testDate, displayedComponents: .date)
                }

                Section("Notes (optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }

                Section {
                    Text("Only the date and test type are stored. Test results are never recorded for your privacy.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Log Drug Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let test = DrugTest(type: testType, testDate: testDate, notes: notes)
                        store.addDrugTest(test)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
