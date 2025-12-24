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
    @State private var attachmentName: String?

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

                Section("Attachments") {
                    if let attachmentName {
                        Label(attachmentName, systemImage: "doc.text")
                    }
                    Button("Scan Service Record") {
                        attachmentName = "Scanned service record"
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
                            attachmentName: attachmentName
                        )
                        store.addRecord(record, to: vehicleID)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddServiceRecordView(vehicleID: UUID())
        .environmentObject(GarageStore())
}
