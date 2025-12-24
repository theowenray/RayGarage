import SwiftUI

struct AddVehicleView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: VehicleType = .car
    @State private var yearText = ""
    @State private var make = ""
    @State private var model = ""
    @State private var mileageText = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Info") {
                    TextField("Nickname", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(VehicleType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Year", text: $yearText)
                        .keyboardType(.numberPad)
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Current Mileage", text: $mileageText)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextField("Storage location, VIN, or quick notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("New Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let year = Int(yearText) ?? 0
                        let mileage = Int(mileageText) ?? 0
                        let vehicle = Vehicle(
                            name: name,
                            type: type,
                            year: year,
                            make: make,
                            model: model,
                            currentMileage: mileage,
                            notes: notes
                        )
                        store.addVehicle(vehicle)
                        dismiss()
                    }
                    .disabled(make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddVehicleView()
        .environmentObject(GarageStore())
}
