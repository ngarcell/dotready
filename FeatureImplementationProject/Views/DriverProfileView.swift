import SwiftUI

struct DriverProfileView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var cdlNumber: String = ""
    @State private var cdlState: String = ""
    @State private var cdlClass: CDLClass = .classA
    @State private var endorsements: String = ""
    @State private var hasMedicalExp = false
    @State private var medicalExpiration: Date = Date()
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var showVehicles = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }

                Section("CDL Information") {
                    TextField("CDL Number", text: $cdlNumber)
                    TextField("State", text: $cdlState)
                    Picker("CDL Class", selection: $cdlClass) {
                        ForEach(CDLClass.allCases, id: \.self) { cls in
                            Text(cls.rawValue).tag(cls)
                        }
                    }
                    TextField("Endorsements (e.g., H, N, T, P, X)", text: $endorsements)
                }

                Section("Medical Card") {
                    Toggle("Medical Card Expiration", isOn: $hasMedicalExp)
                    if hasMedicalExp {
                        DatePicker("Expiration Date", selection: $medicalExpiration, displayedComponents: .date)
                    }
                }

                Section {
                    Button { showVehicles = true } label: {
                        HStack {
                            Label("Manage Vehicles", systemImage: "truck.box")
                            Spacer()
                            Text("\(store.vehicles.count)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("Driver Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showVehicles) {
                VehicleManagementView()
            }
            .onAppear { loadProfile() }
        }
    }

    private func loadProfile() {
        let p = store.driverProfile
        name = p.name
        cdlNumber = p.cdlNumber
        cdlState = p.cdlState
        cdlClass = p.cdlClass
        endorsements = p.endorsements
        hasMedicalExp = p.medicalCardExpiration != nil
        medicalExpiration = p.medicalCardExpiration ?? Date()
        phoneNumber = p.phoneNumber
        email = p.email
    }

    private func saveProfile() {
        let profile = DriverProfile(
            name: name,
            cdlNumber: cdlNumber,
            cdlState: cdlState,
            cdlClass: cdlClass,
            endorsements: endorsements,
            medicalCardExpiration: hasMedicalExp ? medicalExpiration : nil,
            phoneNumber: phoneNumber,
            email: email
        )
        store.updateProfile(profile)
    }
}
