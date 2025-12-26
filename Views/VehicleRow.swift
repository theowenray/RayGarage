import SwiftUI

struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.displayName)
                    .font(.headline)

                Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let reminder = nextReminderText {
                    Label(reminder, systemImage: "bell")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("No reminders set")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch vehicle.type {
        case .car:
            return "car.fill"
        case .truck:
            return "truck.box.fill"
        case .boat:
            return "sailboat.fill"
        case .motorcycle:
            return "motorcycle.fill"
        case .other:
            return "wrench.and.screwdriver.fill"
        }
    }

    private var nextReminderText: String? {
        let upcoming = vehicle.records.compactMap { record -> String? in
            if let reminderDate = record.reminderDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "\(record.title) on \(formatter.string(from: reminderDate))"
            }
            if let reminderMileage = record.reminderMileage {
                return "\(record.title) at \(reminderMileage) mi"
            }
            return nil
        }
        return upcoming.first
    }
}

#Preview {
    List {
        VehicleRow(vehicle: .sample)
    }
}
