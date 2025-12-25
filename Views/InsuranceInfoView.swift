import SwiftUI

struct InsuranceInfoView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showingEdit = false
    
    let vehicleID: UUID
    let insuranceInfo: InsuranceInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !insuranceInfo.company.isEmpty {
                HStack {
                    Text("Company:")
                        .foregroundStyle(.secondary)
                    Text(insuranceInfo.company)
                }
            }
            
            if !insuranceInfo.policyNumber.isEmpty {
                HStack {
                    Text("Policy #:")
                        .foregroundStyle(.secondary)
                    Text(insuranceInfo.policyNumber)
                }
            }
            
            if let expirationDate = insuranceInfo.expirationDate {
                HStack {
                    Text("Expires:")
                        .foregroundStyle(.secondary)
                    let isExpired = expirationDate < Date()
                    let isExpiringSoon = expirationDate < Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                    
                    Text(expirationDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(isExpired ? .red : isExpiringSoon ? .orange : .primary)
                    
                    if isExpired {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    } else if isExpiringSoon {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            if !insuranceInfo.phoneNumber.isEmpty {
                HStack {
                    Text("Phone:")
                        .foregroundStyle(.secondary)
                    Link(insuranceInfo.phoneNumber, destination: URL(string: "tel:\(insuranceInfo.phoneNumber)")!)
                }
            }
            
            if !insuranceInfo.notes.isEmpty {
                Text(insuranceInfo.notes)
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
            EditInsuranceInfoView(vehicleID: vehicleID, insuranceInfo: insuranceInfo)
        }
    }
}

struct EditInsuranceInfoView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    
    let vehicleID: UUID
    let insuranceInfo: InsuranceInfo
    
    @State private var company: String
    @State private var policyNumber: String
    @State private var expirationDate: Date?
    @State private var hasExpirationDate = false
    @State private var phoneNumber: String
    @State private var notes: String
    
    init(vehicleID: UUID, insuranceInfo: InsuranceInfo) {
        self.vehicleID = vehicleID
        self.insuranceInfo = insuranceInfo
        _company = State(initialValue: insuranceInfo.company)
        _policyNumber = State(initialValue: insuranceInfo.policyNumber)
        _expirationDate = State(initialValue: insuranceInfo.expirationDate)
        _hasExpirationDate = State(initialValue: insuranceInfo.expirationDate != nil)
        _phoneNumber = State(initialValue: insuranceInfo.phoneNumber)
        _notes = State(initialValue: insuranceInfo.notes)
    }
    
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
                        saveInsuranceInfo()
                    }
                }
            }
        }
    }
    
    private func saveInsuranceInfo() {
        guard var vehicle = store.vehicles.first(where: { $0.id == vehicleID }) else { return }
        
        let updatedInsuranceInfo = InsuranceInfo(
            company: company,
            policyNumber: policyNumber,
            expirationDate: hasExpirationDate ? (expirationDate ?? Date()) : nil,
            phoneNumber: phoneNumber,
            notes: notes
        )
        
        vehicle.insuranceInfo = updatedInsuranceInfo
        store.updateVehicle(vehicle)
        dismiss()
    }
}

#Preview {
    InsuranceInfoView(vehicleID: UUID(), insuranceInfo: InsuranceInfo(company: "State Farm", policyNumber: "123456789", expirationDate: Date()))
        .environmentObject(GarageStore())
}

