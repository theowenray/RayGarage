import SwiftUI
import Foundation
import UserNotifications
import PhotosUI
import UIKit

struct EditVehicleView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    
    let vehicle: Vehicle
    
    @State private var friendlyName: String
    @State private var type: VehicleType
    @State private var yearText: String
    @State private var make: String
    @State private var model: String
    @State private var mileageText: String
    @State private var notes: String
    @State private var lastOilChangeDate: Date?
    @State private var hasLastOilChange = false
    @State private var lastOilChangeMileageText = ""
    @State private var vehiclePhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _friendlyName = State(initialValue: vehicle.name)
        _type = State(initialValue: vehicle.type)
        _yearText = State(initialValue: String(vehicle.year))
        _make = State(initialValue: vehicle.make)
        _model = State(initialValue: vehicle.model)
        _mileageText = State(initialValue: String(vehicle.currentMileage))
        _notes = State(initialValue: vehicle.notes)
        
        // Set oil change fields if there's a recent oil change record
        if let lastOilChange = vehicle.records.first(where: { $0.category == .oilChange }) {
            _lastOilChangeDate = State(initialValue: lastOilChange.date)
            _hasLastOilChange = State(initialValue: true)
            _lastOilChangeMileageText = State(initialValue: String(lastOilChange.mileage))
        }
        
        // Set photo data if exists
        _vehiclePhotoData = State(initialValue: vehicle.photoImageData)
    }
    
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
                    if vehicle.tireInfo != nil {
                        HStack {
                            Text("Tire info added")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("Edit from vehicle detail view")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Add tire info from vehicle detail view")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Insurance Information") {
                    if vehicle.insuranceInfo != nil {
                        HStack {
                            Text("Insurance info added")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("Edit from vehicle detail view")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Add insurance info from vehicle detail view")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Notes") {
                    TextField("Storage location, VIN, or quick notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Edit Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let year = Int(yearText) ?? vehicle.year
                        let mileage = Int(mileageText) ?? vehicle.currentMileage
                        
                        var updatedVehicle = vehicle
                        updatedVehicle.name = friendlyName
                        updatedVehicle.type = type
                        updatedVehicle.year = year
                        updatedVehicle.make = make
                        updatedVehicle.model = model
                        updatedVehicle.currentMileage = mileage
                        updatedVehicle.notes = notes
                        updatedVehicle.photoImageData = vehiclePhotoData
                        
                        // Update or create oil change record if provided
                        if hasLastOilChange, let oilChangeDate = lastOilChangeDate {
                            let oilChangeMileage = Int(lastOilChangeMileageText) ?? mileage
                            let reminderDate = Calendar.current.date(byAdding: .month, value: 2, to: oilChangeDate) ?? Date()
                            
                            // Find existing oil change record or create new one
                            if let existingIndex = updatedVehicle.records.firstIndex(where: { $0.category == .oilChange }) {
                                // Update existing record
                                updatedVehicle.records[existingIndex].date = oilChangeDate
                                updatedVehicle.records[existingIndex].mileage = oilChangeMileage
                                updatedVehicle.records[existingIndex].reminderDate = reminderDate
                            } else {
                                // Create new record
                                let oilChangeRecord = ServiceRecord(
                                    title: "Oil Change",
                                    category: .oilChange,
                                    date: oilChangeDate,
                                    mileage: oilChangeMileage,
                                    notes: "Oil change entry",
                                    reminderDate: reminderDate
                                )
                                updatedVehicle.records.insert(oilChangeRecord, at: 0)
                            }
                        }
                        
                        store.updateVehicle(updatedVehicle)
                        
                        // Schedule notification if oil change was set
                        if hasLastOilChange, let oilChangeDate = lastOilChangeDate,
                           let reminderDate = Calendar.current.date(byAdding: .month, value: 2, to: oilChangeDate),
                           let oilChangeRecord = updatedVehicle.records.first(where: { $0.category == .oilChange }) {
                            NotificationManager.shared.scheduleOilChangeReminder(
                                for: updatedVehicle,
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
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        vehiclePhotoData = data
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                VehicleCameraView(capturedImage: $capturedImage)
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

struct VehicleCameraView: UIViewControllerRepresentable {
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
        let parent: VehicleCameraView
        
        init(_ parent: VehicleCameraView) {
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

#Preview {
    EditVehicleView(vehicle: .sample)
        .environmentObject(GarageStore())
}

