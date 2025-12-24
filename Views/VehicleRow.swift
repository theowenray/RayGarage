import SwiftUI

struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.displayName)
                    .font(.headline)

                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label("\(vehicle.currentMileage) mi", systemImage: "speedometer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let reminder = nextReminderText {
                        Label(reminder, systemImage: "bell")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else {
                        Text("No reminders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var iconName: String {
        switch vehicle.type {
        case .car:
            return "car.fill"
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
