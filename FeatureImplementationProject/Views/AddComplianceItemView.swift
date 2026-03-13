import SwiftUI

struct AddComplianceItemView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let editItem: ComplianceItem?

    @State private var name: String
    @State private var category: ComplianceCategory
    @State private var issuingBody: String
    @State private var credentialNumber: String
    @State private var hasIssueDate: Bool
    @State private var issueDate: Date
    @State private var hasExpirationDate: Bool
    @State private var expirationDate: Date
    @State private var notes: String
    @State private var reminder90 = true
    @State private var reminder60 = true
    @State private var reminder30 = true
    @State private var reminder14 = true
    @State private var reminder7 = true
    @State private var reminderDay = true

    init(editItem: ComplianceItem? = nil) {
        self.editItem = editItem
        _name = State(initialValue: editItem?.name ?? "")
        _category = State(initialValue: editItem?.category ?? .other)
        _issuingBody = State(initialValue: editItem?.issuingBody ?? "")
        _credentialNumber = State(initialValue: editItem?.credentialNumber ?? "")
        _hasIssueDate = State(initialValue: editItem?.issueDate != nil)
        _issueDate = State(initialValue: editItem?.issueDate ?? Date())
        _hasExpirationDate = State(initialValue: editItem?.expirationDate != nil)
        _expirationDate = State(initialValue: editItem?.expirationDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date())!)
        _notes = State(initialValue: editItem?.notes ?? "")
        let days = editItem?.reminderDays ?? [90, 60, 30, 14, 7, 0]
        _reminder90 = State(initialValue: days.contains(90))
        _reminder60 = State(initialValue: days.contains(60))
        _reminder30 = State(initialValue: days.contains(30))
        _reminder14 = State(initialValue: days.contains(14))
        _reminder7 = State(initialValue: days.contains(7))
        _reminderDay = State(initialValue: days.contains(0))
    }

    private var isEditing: Bool { editItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Info") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(ComplianceCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Credential Details") {
                    TextField("Issuing Body (optional)", text: $issuingBody)
                    TextField("Credential Number (optional)", text: $credentialNumber)
                }

                Section("Dates") {
                    Toggle("Issue Date", isOn: $hasIssueDate)
                    if hasIssueDate {
                        DatePicker("Issue Date", selection: $issueDate, displayedComponents: .date)
                    }
                    Toggle("Expiration Date", isOn: $hasExpirationDate)
                    if hasExpirationDate {
                        DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                    }
                }

                if hasExpirationDate {
                    Section("Reminders") {
                        Toggle("90 days before", isOn: $reminder90)
                        Toggle("60 days before", isOn: $reminder60)
                        Toggle("30 days before", isOn: $reminder30)
                        Toggle("14 days before", isOn: $reminder14)
                        Toggle("7 days before", isOn: $reminder7)
                        Toggle("On expiration day", isOn: $reminderDay)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveItem() {
        var reminderDays: [Int] = []
        if reminder90 { reminderDays.append(90) }
        if reminder60 { reminderDays.append(60) }
        if reminder30 { reminderDays.append(30) }
        if reminder14 { reminderDays.append(14) }
        if reminder7 { reminderDays.append(7) }
        if reminderDay { reminderDays.append(0) }

        var item = editItem ?? ComplianceItem()
        item.name = name
        item.category = category
        item.issuingBody = issuingBody
        item.credentialNumber = credentialNumber
        item.issueDate = hasIssueDate ? issueDate : nil
        item.expirationDate = hasExpirationDate ? expirationDate : nil
        item.notes = notes
        item.reminderDays = reminderDays

        if isEditing {
            store.updateComplianceItem(item)
        } else {
            store.addComplianceItem(item)
        }
    }
}
