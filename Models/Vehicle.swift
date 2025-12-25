import Foundation

enum VehicleType: String, CaseIterable, Identifiable, Codable {
    case car = "Car"
    case boat = "Boat"
    case motorcycle = "Motorcycle"
    case other = "Other"

    var id: String { rawValue }
}

struct TireInfo: Codable, Hashable {
    var installedDate: Date?
    var installedMileage: Int?
    var expectedLifeMiles: Int?
    var brand: String
    var model: String
    var notes: String
    
    init(
        installedDate: Date? = nil,
        installedMileage: Int? = nil,
        expectedLifeMiles: Int? = nil,
        brand: String = "",
        model: String = "",
        notes: String = ""
    ) {
        self.installedDate = installedDate
        self.installedMileage = installedMileage
        self.expectedLifeMiles = expectedLifeMiles
        self.brand = brand
        self.model = model
        self.notes = notes
    }
    
    var remainingLifePercentage: Double? {
        guard let installedMileage = installedMileage,
              let expectedLifeMiles = expectedLifeMiles,
              expectedLifeMiles > 0 else { return nil }
        return max(0, min(100, Double(expectedLifeMiles) / Double(expectedLifeMiles) * 100))
    }
}

struct InsuranceInfo: Codable, Hashable {
    var company: String
    var policyNumber: String
    var expirationDate: Date?
    var phoneNumber: String
    var notes: String
    
    init(
        company: String = "",
        policyNumber: String = "",
        expirationDate: Date? = nil,
        phoneNumber: String = "",
        notes: String = ""
    ) {
        self.company = company
        self.policyNumber = policyNumber
        self.expirationDate = expirationDate
        self.phoneNumber = phoneNumber
        self.notes = notes
    }
}

struct Vehicle: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: VehicleType
    var year: Int
    var make: String
    var model: String
    var currentMileage: Int
    var notes: String
    var records: [ServiceRecord]
    var tireInfo: TireInfo?
    var insuranceInfo: InsuranceInfo?

    init(
        id: UUID = UUID(),
        name: String,
        type: VehicleType,
        year: Int,
        make: String,
        model: String,
        currentMileage: Int,
        notes: String = "",
        records: [ServiceRecord] = [],
        tireInfo: TireInfo? = nil,
        insuranceInfo: InsuranceInfo? = nil
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
        self.tireInfo = tireInfo
        self.insuranceInfo = insuranceInfo
    }

    var displayName: String {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(year) \(make) \(model)"
        }
        return name
    }
    
    var lastOilChange: ServiceRecord? {
        records.filter { $0.category == .oilChange }
            .sorted { $0.date > $1.date }
            .first
    }
    
    var nextOilChangeReminder: ServiceRecord? {
        records.filter { $0.category == .oilChange }
            .filter { record in
                if let reminderDate = record.reminderDate {
                    return reminderDate > Date()
                }
                if let reminderMileage = record.reminderMileage {
                    return reminderMileage > currentMileage
                }
                return false
            }
            .sorted { record1, record2 in
                let date1 = record1.reminderDate ?? Date.distantFuture
                let date2 = record2.reminderDate ?? Date.distantFuture
                return date1 < date2
            }
            .first
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
