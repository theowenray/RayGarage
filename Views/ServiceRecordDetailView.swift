import SwiftUI
import UIKit

struct ServiceRecordDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    
    let vehicleID: UUID
    let record: ServiceRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Receipt Image
                if let imageData = record.receiptImageData,
                   let uiImage = UIImage(data: imageData) {
                    Section {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding()
                    }
                }
                
                // Service Details
                VStack(alignment: .leading, spacing: 12) {
                    Text(record.title)
                        .font(.title2)
                        .bold()
                    
                    Label(record.category.rawValue, systemImage: categoryIcon)
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Divider()
                    
                    InfoRow(label: "Date", value: record.date.formatted(date: .long, time: .omitted))
                    InfoRow(label: "Mileage", value: "\(record.mileage) miles")
                    
                    if let cost = record.cost {
                        InfoRow(label: "Cost", value: String(format: "$%.2f", cost))
                    }
                    
                    if let reminderDate = record.reminderDate {
                        InfoRow(label: "Reminder Date", value: reminderDate.formatted(date: .long, time: .omitted))
                            .foregroundStyle(.orange)
                    }
                    
                    if let reminderMileage = record.reminderMileage {
                        InfoRow(label: "Reminder Mileage", value: "\(reminderMileage) miles")
                            .foregroundStyle(.orange)
                    }
                    
                    if !record.notes.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(record.notes)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Service Record")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var categoryIcon: String {
        switch record.category {
        case .oilChange: return "drop.fill"
        case .inspection: return "checkmark.seal.fill"
        case .repair: return "wrench.and.screwdriver.fill"
        case .tires: return "circle.fill"
        case .battery: return "battery.100"
        case .detailing: return "sparkles"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    NavigationStack {
        ServiceRecordDetailView(
            vehicleID: UUID(),
            record: ServiceRecord(
                title: "Oil Change",
                category: .oilChange,
                date: Date(),
                mileage: 50000,
                cost: 45.99,
                notes: "Used synthetic oil"
            )
        )
    }
    .environmentObject(GarageStore())
}

