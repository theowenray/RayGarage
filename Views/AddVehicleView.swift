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
    @State private var showTireInfo = false
    @State private var showInsuranceInfo = false
    @State private var tireInfo: TireInfo?
    @State private var insuranceInfo: InsuranceInfo?

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

                Section("Tire Information") {
                    if let tireInfo = tireInfo {
                        HStack {
                            Text("Tire info added")
                                .foregroundStyle(.green)
                            Spacer()
                            Button("Edit") {
                                showTireInfo = true
                            }
                        }
                    } else {
                        Button("Add Tire Information") {
                            showTireInfo = true
                        }
                    }
                }
                
                Section("Insurance Information") {
                    if let insuranceInfo = insuranceInfo {
                        HStack {
                            Text("Insurance info added")
                                .foregroundStyle(.green)
                            Spacer()
                            Button("Edit") {
                                showInsuranceInfo = true
                            }
                        }
                    } else {
                        Button("Add Insurance Information") {
                            showInsuranceInfo = true
                        }
                    }
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
                            notes: notes,
                            records: [],
                            tireInfo: tireInfo,
                            insuranceInfo: insuranceInfo
                        )
                        store.addVehicle(vehicle)
                        dismiss()
                    }
                    .disabled(make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showTireInfo) {
                AddTireInfoView(tireInfo: $tireInfo)
            }
            .sheet(isPresented: $showInsuranceInfo) {
                AddInsuranceInfoView(insuranceInfo: $insuranceInfo)
            }
        }
    }
}

struct AddTireInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var tireInfo: TireInfo?
    
    @State private var brand = ""
    @State private var model = ""
    @State private var installedDate: Date?
    @State private var hasInstalledDate = false
    @State private var installedMileageText = ""
    @State private var expectedLifeText = ""
    @State private var notes = ""
    
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
                        tireInfo = TireInfo(
                            installedDate: hasInstalledDate ? (installedDate ?? Date()) : nil,
                            installedMileage: installedMileageText.isEmpty ? nil : Int(installedMileageText),
                            expectedLifeMiles: expectedLifeText.isEmpty ? nil : Int(expectedLifeText),
                            brand: brand,
                            model: model,
                            notes: notes
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddInsuranceInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var insuranceInfo: InsuranceInfo?
    
    @State private var company = ""
    @State private var policyNumber = ""
    @State private var expirationDate: Date?
    @State private var hasExpirationDate = false
    @State private var phoneNumber = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Insurance Details") {
                    TextField("Insurance Company", text: $company)
                    TextField("Policy Number", text: $policyNumber)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Expiration") {
                    Toggle("Set Expiration Date", isOn: $hasExpirationDate)
                    if hasExpirationDate {
                        DatePicker("Expiration Date", selection: Binding(
                            get: { expirationDate ?? Date() },
                            set: { expirationDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Insurance Information")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        insuranceInfo = InsuranceInfo(
                            company: company,
                            policyNumber: policyNumber,
                            expirationDate: hasExpirationDate ? (expirationDate ?? Date()) : nil,
                            phoneNumber: phoneNumber,
                            notes: notes
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddVehicleView()
        .environmentObject(GarageStore())
}
