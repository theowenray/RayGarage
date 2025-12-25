import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleOilChangeReminder(
        for vehicle: Vehicle,
        record: ServiceRecord,
        reminderDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Oil Change Reminder"
        content.body = "Time for an oil change on \(vehicle.displayName)"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "oilChange-\(vehicle.id.uuidString)-\(record.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Oil change reminder scheduled for \(reminderDate)")
            }
        }
    }
    
    func scheduleMileageReminder(
        for vehicle: Vehicle,
        record: ServiceRecord,
        reminderMileage: Int
    ) {
        // Note: Mileage-based reminders would need to be checked when mileage is updated
        // For now, we'll store the reminder and check it in the store
    }
    
    func cancelReminder(for vehicleID: UUID, recordID: UUID) {
        let identifier = "oilChange-\(vehicleID.uuidString)-\(recordID.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllReminders(for vehicleID: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.contains(vehicleID.uuidString) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

