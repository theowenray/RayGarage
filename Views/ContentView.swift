import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showingAddVehicle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DashboardHeaderView()

                    SummaryCardsView(summary: summary)

                    if store.vehicles.isEmpty {
                        EmptyStateView(
                            title: "Add your first vehicle",
                            message: "Track oil changes, parts replacements, and service reminders in one place."
                        )
                    } else {
                        UpcomingRemindersView(reminders: upcomingReminders)

                        VehiclesSectionView(vehicles: store.vehicles)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("RayGarage")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddVehicle = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add vehicle")
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicle: vehicle)
            }
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
        }
    }

    private var summary: DashboardSummary {
        let totalVehicles = store.vehicles.count
        let totalRecords = store.vehicles.reduce(0) { $0 + $1.records.count }
        let reminders = store.vehicles.flatMap { $0.records }.filter { $0.reminderDate != nil || $0.reminderMileage != nil }.count
        return DashboardSummary(
            totalVehicles: totalVehicles,
            totalRecords: totalRecords,
            totalReminders: reminders
        )
    }

    private var upcomingReminders: [ReminderRowModel] {
        let reminders = store.vehicles.flatMap { vehicle in
            vehicle.records.compactMap { record -> ReminderRowModel? in
                if let reminderDate = record.reminderDate {
                    return ReminderRowModel(
                        title: record.title,
                        subtitle: vehicle.displayName,
                        detail: reminderDate.formatted(date: .abbreviated, time: .omitted)
                    )
                }
                if let reminderMileage = record.reminderMileage {
                    return ReminderRowModel(
                        title: record.title,
                        subtitle: vehicle.displayName,
                        detail: "\(reminderMileage) mi"
                    )
                }
                return nil
            }
        }
        return Array(reminders.prefix(3))
    }
}

#Preview {
    ContentView()
        .environmentObject(GarageStore())
}

private struct DashboardHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Keep every ride ready with simple reminders, service records, and parts costs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SummaryCardsView: View {
    let summary: DashboardSummary

    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(title: "Vehicles", value: "\(summary.totalVehicles)", icon: "car.fill")
            SummaryCard(title: "Records", value: "\(summary.totalRecords)", icon: "wrench.and.screwdriver.fill")
            SummaryCard(title: "Reminders", value: "\(summary.totalReminders)", icon: "bell.fill")
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct UpcomingRemindersView: View {
    let reminders: [ReminderRowModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                if reminders.isEmpty {
                    Text("All caught up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if reminders.isEmpty {
                Text("Add a reminder to keep tabs on oil changes, inspections, or seasonal prep.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(reminders) { reminder in
                    ReminderRow(reminder: reminder)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct ReminderRow: View {
    let reminder: ReminderRowModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(reminder.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(reminder.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct VehiclesSectionView: View {
    let vehicles: [Vehicle]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your garage")
                .font(.headline)

            ForEach(vehicles) { vehicle in
                NavigationLink(value: vehicle) {
                    VehicleRow(vehicle: vehicle)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct DashboardSummary {
    let totalVehicles: Int
    let totalRecords: Int
    let totalReminders: Int
}

private struct ReminderRowModel: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let detail: String
}
