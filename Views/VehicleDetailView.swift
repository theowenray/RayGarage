import SwiftUI

struct VehicleDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showingAddRecord = false

    let vehicle: Vehicle

    var body: some View {
        let currentVehicle = store.vehicles.first(where: { $0.id == vehicle.id }) ?? vehicle

        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentVehicle.displayName)
                            .font(.title2)
                        Text("\(currentVehicle.year) \(currentVehicle.make) \(currentVehicle.model)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(currentVehicle.type.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                }

                MileageEditor(vehicleID: currentVehicle.id, mileage: currentVehicle.currentMileage)

                if !currentVehicle.notes.isEmpty {
                    Text(currentVehicle.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Tire Information") {
                if let tireInfo = currentVehicle.tireInfo {
                    TireInfoView(vehicleID: currentVehicle.id, tireInfo: tireInfo)
                } else {
                    Button("Add Tire Information") {
                        // Add tire info
                        var updatedVehicle = currentVehicle
                        updatedVehicle.tireInfo = TireInfo()
                        store.updateVehicle(updatedVehicle)
                    }
                }
            }
            
            Section("Insurance Information") {
                if let insuranceInfo = currentVehicle.insuranceInfo {
                    InsuranceInfoView(vehicleID: currentVehicle.id, insuranceInfo: insuranceInfo)
                } else {
                    Button("Add Insurance Information") {
                        // Add insurance info
                        var updatedVehicle = currentVehicle
                        updatedVehicle.insuranceInfo = InsuranceInfo()
                        store.updateVehicle(updatedVehicle)
                    }
                }
            }
            
            Section("Service Records") {
                if currentVehicle.records.isEmpty {
                    Text("No service records yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(currentVehicle.records) { record in
                        NavigationLink {
                            ServiceRecordDetailView(vehicleID: currentVehicle.id, record: record)
                        } label: {
                            ServiceRecordRow(record: record)
                        }
                    }
                }
            }
            
            if let lastOilChange = currentVehicle.lastOilChange {
                Section("Last Oil Change") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lastOilChange.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                            Text("\(lastOilChange.mileage) miles")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let nextReminder = currentVehicle.nextOilChangeReminder {
                            VStack(alignment: .trailing, spacing: 4) {
                                if let reminderDate = nextReminder.reminderDate {
                                    Text("Next: \(reminderDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                                if let reminderMileage = nextReminder.reminderMileage {
                                    Text("At: \(reminderMileage) miles")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Vehicle")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddRecord = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add service record")
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            AddServiceRecordView(vehicleID: currentVehicle.id)
        }
    }
}

private struct ServiceRecordRow: View {
    let record: ServiceRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.title)
                    .font(.headline)
                Spacer()
                Text(record.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(record.mileage) mi", systemImage: "speedometer")
                if let cost = record.cost {
                    Label(String(format: "$%.2f", cost), systemImage: "dollarsign.circle")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let reminderText = reminderText {
                Label(reminderText, systemImage: "bell")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if record.receiptImageData != nil {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.green)
                    Text(record.receiptFileName ?? "Receipt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !record.notes.isEmpty {
                Text(record.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var reminderText: String? {
        if let reminderDate = record.reminderDate {
            return "Reminder on \(reminderDate.formatted(date: .abbreviated, time: .omitted))"
        }
        if let reminderMileage = record.reminderMileage {
            return "Reminder at \(reminderMileage) mi"
        }
        return nil
    }
}

private struct MileageEditor: View {
    @EnvironmentObject private var store: GarageStore
    @State private var mileageText: String

    let vehicleID: UUID
    let mileage: Int

    init(vehicleID: UUID, mileage: Int) {
        self.vehicleID = vehicleID
        self.mileage = mileage
        _mileageText = State(initialValue: String(mileage))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Mileage")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                TextField("Mileage", text: $mileageText)
                    .keyboardType(.numberPad)
                Spacer()
                Button("Update") {
                    let updatedMileage = Int(mileageText) ?? mileage
                    store.updateVehicleMileage(updatedMileage, for: vehicleID)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    NavigationStack {
        VehicleDetailView(vehicle: .sample)
            .environmentObject(GarageStore())
    }
}
