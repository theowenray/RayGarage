import SwiftUI

struct TireInfoView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showingEdit = false
    
    let vehicleID: UUID
    let tireInfo: TireInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tireInfo.brand.isEmpty {
                HStack {
                    Text("Brand:")
                        .foregroundStyle(.secondary)
                    Text(tireInfo.brand)
                }
            }
            
            if !tireInfo.model.isEmpty {
                HStack {
                    Text("Model:")
                        .foregroundStyle(.secondary)
                    Text(tireInfo.model)
                }
            }
            
            if let installedDate = tireInfo.installedDate {
                HStack {
                    Text("Installed:")
                        .foregroundStyle(.secondary)
                    Text(installedDate.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            if let installedMileage = tireInfo.installedMileage {
                HStack {
                    Text("Mileage:")
                        .foregroundStyle(.secondary)
                    Text("\(installedMileage) miles")
                }
                
                if let expectedLife = tireInfo.expectedLifeMiles,
                   let vehicle = store.vehicles.first(where: { $0.id == vehicleID }) {
                    let milesUsed = max(0, vehicle.currentMileage - installedMileage)
                    let milesRemaining = max(0, expectedLife - milesUsed)
                    let percentage = expectedLife > 0 ? Double(milesRemaining) / Double(expectedLife) * 100 : 0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Remaining Life:")
                                .foregroundStyle(.secondary)
                            Text("\(Int(percentage))%")
                                .font(.headline)
                                .foregroundStyle(percentage > 50 ? .green : percentage > 20 ? .orange : .red)
                        }
                        
                        ProgressView(value: percentage, total: 100)
                            .tint(percentage > 50 ? .green : percentage > 20 ? .orange : .red)
                        
                        Text("\(milesRemaining) miles remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            
            if !tireInfo.notes.isEmpty {
                Text(tireInfo.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditTireInfoView(vehicleID: vehicleID, tireInfo: tireInfo)
        }
    }
}

struct EditTireInfoView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    
    let vehicleID: UUID
    let tireInfo: TireInfo
    
    @State private var brand: String
    @State private var model: String
    @State private var installedDate: Date?
    @State private var hasInstalledDate = false
    @State private var installedMileageText: String
    @State private var expectedLifeText: String
    @State private var notes: String
    
    init(vehicleID: UUID, tireInfo: TireInfo) {
        self.vehicleID = vehicleID
        self.tireInfo = tireInfo
        _brand = State(initialValue: tireInfo.brand)
        _model = State(initialValue: tireInfo.model)
        _installedDate = State(initialValue: tireInfo.installedDate)
        _hasInstalledDate = State(initialValue: tireInfo.installedDate != nil)
        _installedMileageText = State(initialValue: tireInfo.installedMileage.map(String.init) ?? "")
        _expectedLifeText = State(initialValue: tireInfo.expectedLifeMiles.map(String.init) ?? "")
        _notes = State(initialValue: tireInfo.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tire Details") {
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $model)
                    TextField("Installed Mileage", text: $installedMileageText)
                        .keyboardType(.numberPad)
                    TextField("Expected Life (miles)", text: $expectedLifeText)
                        .keyboardType(.numberPad)
                }
                
                Section("Installation Date") {
                    Toggle("Set Installation Date", isOn: $hasInstalledDate)
                    if hasInstalledDate {
                        DatePicker("Date", selection: Binding(
                            get: { installedDate ?? Date() },
                            set: { installedDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Tire Information")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTireInfo()
                    }
                }
            }
        }
    }
    
    private func saveTireInfo() {
        guard var vehicle = store.vehicles.first(where: { $0.id == vehicleID }) else { return }
        
        let updatedTireInfo = TireInfo(
            installedDate: hasInstalledDate ? (installedDate ?? Date()) : nil,
            installedMileage: installedMileageText.isEmpty ? nil : Int(installedMileageText),
            expectedLifeMiles: expectedLifeText.isEmpty ? nil : Int(expectedLifeText),
            brand: brand,
            model: model,
            notes: notes
        )
        
        vehicle.tireInfo = updatedTireInfo
        store.updateVehicle(vehicle)
        dismiss()
    }
}

#Preview {
    TireInfoView(vehicleID: UUID(), tireInfo: TireInfo(installedMileage: 10000, expectedLifeMiles: 50000, brand: "Michelin", model: "Pilot Sport"))
        .environmentObject(GarageStore())
}

