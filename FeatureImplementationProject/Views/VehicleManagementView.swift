import SwiftUI

struct VehicleManagementView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showAddVehicle = false
    @State private var editingVehicle: Vehicle?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.vehicles) { vehicle in
                    Button { editingVehicle = vehicle } label: {
                        VehicleRow(vehicle: vehicle)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.deleteVehicle(vehicle)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Vehicles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddVehicle = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if store.vehicles.isEmpty {
                    ContentUnavailableView("No Vehicles", systemImage: "truck.box", description: Text("Add your first vehicle."))
                }
            }
            .sheet(isPresented: $showAddVehicle) {
                AddVehicleView()
            }
            .sheet(item: $editingVehicle) { vehicle in
                AddVehicleView(editVehicle: vehicle)
            }
        }
    }
}

struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "truck.box.fill")
                .font(.title3)
                .foregroundStyle(AppColors.navy)
                .frame(width: 40, height: 40)
                .background(AppColors.navy.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.displayName)
                    .font(.body.weight(.medium))
                HStack(spacing: 8) {
                    if !vehicle.plateNumber.isEmpty {
                        Text(vehicle.plateNumber)
                    }
                    if !vehicle.dotNumber.isEmpty {
                        Text("DOT: \(vehicle.dotNumber)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }
}

struct AddVehicleView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let editVehicle: Vehicle?

    @State private var name: String
    @State private var vin: String
    @State private var plateNumber: String
    @State private var year: String
    @State private var make: String
    @State private var model: String
    @State private var dotNumber: String
    @State private var notes: String

    init(editVehicle: Vehicle? = nil) {
        self.editVehicle = editVehicle
        _name = State(initialValue: editVehicle?.name ?? "")
        _vin = State(initialValue: editVehicle?.vin ?? "")
        _plateNumber = State(initialValue: editVehicle?.plateNumber ?? "")
        _year = State(initialValue: editVehicle?.year ?? "")
        _make = State(initialValue: editVehicle?.make ?? "")
        _model = State(initialValue: editVehicle?.model ?? "")
        _dotNumber = State(initialValue: editVehicle?.dotNumber ?? "")
        _notes = State(initialValue: editVehicle?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Info") {
                    TextField("Nickname (optional)", text: $name)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                }

                Section("Registration") {
                    TextField("VIN", text: $vin)
                    TextField("Plate Number", text: $plateNumber)
                        .textInputAutocapitalization(.characters)
                    TextField("DOT Number", text: $dotNumber)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle(editVehicle == nil ? "Add Vehicle" : "Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVehicle()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveVehicle() {
        var vehicle = editVehicle ?? Vehicle()
        vehicle.name = name
        vehicle.vin = vin
        vehicle.plateNumber = plateNumber
        vehicle.year = year
        vehicle.make = make
        vehicle.model = model
        vehicle.dotNumber = dotNumber
        vehicle.notes = notes

        if editVehicle != nil {
            store.updateVehicle(vehicle)
        } else {
            store.addVehicle(vehicle)
        }
    }
}
