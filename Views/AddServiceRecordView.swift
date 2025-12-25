import SwiftUI

struct AddServiceRecordView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    let vehicleID: UUID

    @State private var title = ""
    @State private var category: ServiceCategory = .oilChange
    @State private var date = Date()
    @State private var mileageText = ""
    @State private var costText = ""
    @State private var notes = ""
    @State private var addReminderDate = false
    @State private var reminderDate = Date()
    @State private var addReminderMileage = false
    @State private var reminderMileageText = ""
    @State private var receiptImageData: Data?
    @State private var receiptFileName: String?
    @State private var showingReceiptScanner = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Details") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(ServiceCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Mileage", text: $mileageText)
                        .keyboardType(.numberPad)
                    TextField("Cost", text: $costText)
                        .keyboardType(.decimalPad)
                }

                Section("Reminders") {
                    Toggle("Reminder by date", isOn: $addReminderDate)
                    if addReminderDate {
                        DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: .date)
                    }
                    Toggle("Reminder by mileage", isOn: $addReminderMileage)
                    if addReminderMileage {
                        TextField("Reminder Mileage", text: $reminderMileageText)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Receipt") {
                    if receiptImageData != nil {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.green)
                            if let fileName = receiptFileName {
                                Text(fileName)
                                    .font(.subheadline)
                            } else {
                                Text("Receipt attached")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button("Remove") {
                                receiptImageData = nil
                                receiptFileName = nil
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    Button {
                        showingReceiptScanner = true
                    } label: {
                        Label("Scan or Add Receipt", systemImage: "camera.fill")
                    }
                    .buttonStyle(.bordered)
                }

                Section("Notes") {
                    TextField("Parts replaced, shop details, or warranty info", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Add Record")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let mileage = Int(mileageText) ?? 0
                        let cost = Double(costText)
                        let reminderMileage = addReminderMileage ? Int(reminderMileageText) : nil
                        let record = ServiceRecord(
                            title: title,
                            category: category,
                            date: date,
                            mileage: mileage,
                            cost: cost,
                            notes: notes,
                            reminderDate: addReminderDate ? reminderDate : nil,
                            reminderMileage: reminderMileage,
                            receiptImageData: receiptImageData,
                            receiptFileName: receiptFileName
                        )
                        store.addRecord(record, to: vehicleID)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingReceiptScanner) {
                NavigationStack {
                    ReceiptScannerView(receiptImageData: $receiptImageData, receiptFileName: $receiptFileName)
                        .navigationTitle("Add Receipt")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    showingReceiptScanner = false
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    AddServiceRecordView(vehicleID: UUID())
        .environmentObject(GarageStore())
}
