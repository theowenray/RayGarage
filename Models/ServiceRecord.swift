import Foundation

enum ServiceCategory: String, CaseIterable, Identifiable {
    case oilChange = "Oil Change"
    case inspection = "Inspection"
    case repair = "Repair"
    case tires = "Tires"
    case battery = "Battery"
    case detailing = "Detailing"
    case other = "Other"

    var id: String { rawValue }
}

struct ServiceRecord: Identifiable {
    let id: UUID
    var title: String
    var category: ServiceCategory
    var date: Date
    var mileage: Int
    var cost: Double?
    var notes: String
    var reminderDate: Date?
    var reminderMileage: Int?
    var attachmentName: String?

    init(
        id: UUID = UUID(),
        title: String,
        category: ServiceCategory,
        date: Date,
        mileage: Int,
        cost: Double? = nil,
        notes: String = "",
        reminderDate: Date? = nil,
        reminderMileage: Int? = nil,
        attachmentName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.date = date
        self.mileage = mileage
        self.cost = cost
        self.notes = notes
        self.reminderDate = reminderDate
        self.reminderMileage = reminderMileage
        self.attachmentName = attachmentName
    }
}
