import Foundation
import Combine
import UserNotifications

final class GarageStore: ObservableObject {
    @Published var vehicles: [Vehicle] {
        didSet {
            saveVehicles()
        }
    }
    
    private let vehiclesKey = "RayGarageVehicles"
    private let notificationManager = NotificationManager.shared

    init(vehicles: [Vehicle] = []) {
        if let savedVehicles = Self.loadVehicles() {
            self.vehicles = savedVehicles
        } else {
            self.vehicles = vehicles.isEmpty ? [Vehicle.sample] : vehicles
        }
        
        // Request notification permissions on init
        notificationManager.requestAuthorization()
    }
    
    private static func loadVehicles() -> [Vehicle]? {
        guard let data = UserDefaults.standard.data(forKey: "RayGarageVehicles") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Vehicle].self, from: data)
    }
    
    private func saveVehicles() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: vehiclesKey)
        }
    }

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
    
    func updateVehicle(_ vehicle: Vehicle) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else { return }
        vehicles[index] = vehicle
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        notificationManager.cancelAllReminders(for: vehicle.id)
    }

    func addRecord(_ record: ServiceRecord, to vehicleID: UUID) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        vehicles[index].records.insert(record, at: 0)
        
        // Schedule notification if reminder is set
        if let reminderDate = record.reminderDate, record.category == .oilChange {
            let vehicle = vehicles[index]
            notificationManager.scheduleOilChangeReminder(
                for: vehicle,
                record: record,
                reminderDate: reminderDate
            )
        }
    }
    
    func updateRecord(_ record: ServiceRecord, in vehicleID: UUID) {
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleID }),
              let recordIndex = vehicles[vehicleIndex].records.firstIndex(where: { $0.id == record.id }) else { return }
        
        // Cancel old reminder if it exists
        notificationManager.cancelReminder(for: vehicleID, recordID: record.id)
        
        vehicles[vehicleIndex].records[recordIndex] = record
        
        // Schedule new reminder if set
        if let reminderDate = record.reminderDate, record.category == .oilChange {
            let vehicle = vehicles[vehicleIndex]
            notificationManager.scheduleOilChangeReminder(
                for: vehicle,
                record: record,
                reminderDate: reminderDate
            )
        }
    }
    
    func deleteRecord(_ record: ServiceRecord, from vehicleID: UUID) {
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        vehicles[vehicleIndex].records.removeAll { $0.id == record.id }
        notificationManager.cancelReminder(for: vehicleID, recordID: record.id)
    }

    func updateVehicleMileage(_ mileage: Int, for vehicleID: UUID) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        vehicles[index].currentMileage = mileage
        
        // Check for mileage-based reminders
        checkMileageReminders(for: vehicleID)
    }
    
    private func checkMileageReminders(for vehicleID: UUID) {
        guard let vehicle = vehicles.first(where: { $0.id == vehicleID }) else { return }
        
        for record in vehicle.records {
            if let reminderMileage = record.reminderMileage,
               vehicle.currentMileage >= reminderMileage {
                // Trigger reminder notification
                let content = UNMutableNotificationContent()
                content.title = "Mileage Reminder"
                content.body = "\(vehicle.displayName) has reached \(reminderMileage) miles - time for \(record.title)"
                content.sound = .default
                
                let request = UNNotificationRequest(
                    identifier: "mileage-\(vehicleID.uuidString)-\(record.id.uuidString)",
                    content: content,
                    trigger: nil
                )
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
