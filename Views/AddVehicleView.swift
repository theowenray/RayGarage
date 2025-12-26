import SwiftUI
import PhotosUI
import UIKit
import Foundation

struct AddVehicleView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    @State private var friendlyName = ""
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
    @State private var lastOilChangeDate: Date?
    @State private var hasLastOilChange = false
    @State private var lastOilChangeMileageText = ""
    @State private var vehiclePhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Photo") {
                    if let photoData = vehiclePhotoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                        
                        Button("Remove Photo") {
                            vehiclePhotoData = nil
                        }
                        .foregroundStyle(.red)
                    } else {
                        HStack(spacing: 16) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("Photo Library", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            
                            Button {
                                showingCamera = true
                            } label: {
                                Label("Camera", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                Section("Friendly Name") {
                    TextField("e.g., My Daily Driver, Weekend Cruiser", text: $friendlyName, prompt: Text("Give your vehicle a friendly name"))
                }
                
                Section("Vehicle Details") {
                    Picker("Type", selection: $type) {
                        ForEach(VehicleType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Year", text: $yearText)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Current Mileage", text: $mileageText)
                        .keyboardType(.numberPad)
                }
                
                Section("Last Oil Change") {
                    Toggle("Set Last Oil Change", isOn: $hasLastOilChange)
                    if hasLastOilChange {
                        DatePicker("Date", selection: Binding(
                            get: { lastOilChangeDate ?? Date() },
                            set: { lastOilChangeDate = $0 }
                        ), displayedComponents: .date)
                        TextField("Mileage at Oil Change", text: $lastOilChangeMileageText)
                            .keyboardType(.numberPad)
                    }
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
                        
                        // Create initial records array
                        var records: [ServiceRecord] = []
                        
                        // Add oil change record if provided
                        if hasLastOilChange, let oilChangeDate = lastOilChangeDate {
                            let oilChangeMileage = Int(lastOilChangeMileageText) ?? mileage
                            // Set reminder for 2 months from last oil change
                            let reminderDate = Calendar.current.date(byAdding: .month, value: 2, to: oilChangeDate) ?? Date()
                            
                            let oilChangeRecord = ServiceRecord(
                                title: "Oil Change",
                                category: .oilChange,
                                date: oilChangeDate,
                                mileage: oilChangeMileage,
                                notes: "Initial oil change entry",
                                reminderDate: reminderDate
                            )
                            records.append(oilChangeRecord)
                        }
                        
                        let vehicle = Vehicle(
                            name: friendlyName,
                            type: type,
                            year: year,
                            make: make,
                            model: model,
                            currentMileage: mileage,
                            notes: notes,
                            records: records,
                            tireInfo: tireInfo,
                            insuranceInfo: insuranceInfo,
                            photoImageData: vehiclePhotoData
                        )
                        store.addVehicle(vehicle)
                        
                        // Schedule notification for oil change if set
                        if hasLastOilChange, let oilChangeDate = lastOilChangeDate,
                           let reminderDate = Calendar.current.date(byAdding: .month, value: 2, to: oilChangeDate),
                           let oilChangeRecord = records.first(where: { $0.category == .oilChange }) {
                            // Schedule the notification for the oil change reminder
                            NotificationManager.shared.scheduleOilChangeReminder(
                                for: vehicle,
                                record: oilChangeRecord,
                                reminderDate: reminderDate
                            )
                        }
                        
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
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        vehiclePhotoData = data
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                AddVehicleCameraView(capturedImage: $capturedImage)
            }
            .onChange(of: capturedImage) {
                if let image = capturedImage,
                   let data = image.jpegData(compressionQuality: 0.8) {
                    vehiclePhotoData = data
                }
            }
        }
    }
}

struct AddVehicleCameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: AddVehicleCameraView
        
        init(_ parent: AddVehicleCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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
