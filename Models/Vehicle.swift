import Foundation

enum VehicleType: String, CaseIterable, Identifiable {
    case car = "Car"
    case boat = "Boat"
    case motorcycle = "Motorcycle"
    case other = "Other"

    var id: String { rawValue }
}

struct Vehicle: Identifiable {
    let id: UUID
    var name: String
    var type: VehicleType
    var year: Int
    var make: String
    var model: String
    var currentMileage: Int
    var notes: String
    var records: [ServiceRecord]

    init(
        id: UUID = UUID(),
        name: String,
        type: VehicleType,
        year: Int,
        make: String,
        model: String,
        currentMileage: Int,
        notes: String = "",
        records: [ServiceRecord] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.year = year
        self.make = make
        self.model = model
        self.currentMileage = currentMileage
        self.notes = notes
        self.records = records
    }

    var displayName: String {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(year) \(make) \(model)"
        }
        return name
    }
}

extension Vehicle {
    static let sample = Vehicle(
        name: "Weekend Cruiser",
        type: .boat,
        year: 2018,
        make: "Sea Ray",
        model: "SPX 210",
        currentMileage: 320,
        notes: "Stored at Harbor Marina",
        records: [
            ServiceRecord(
                title: "Spring service",
                category: .inspection,
                date: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
                mileage: 300,
                cost: 420.00,
                notes: "Changed filters and inspected hull.",
                reminderDate: Calendar.current.date(byAdding: .month, value: 5, to: Date())
            )
        ]
    )
}
