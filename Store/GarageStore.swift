import Combine
import Foundation

final class GarageStore: ObservableObject {
    @Published var vehicles: [Vehicle]

    init(vehicles: [Vehicle] = [Vehicle.sample]) {
        self.vehicles = vehicles
    }

    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }

    func addRecord(_ record: ServiceRecord, to vehicleID: UUID) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        vehicles[index].records.insert(record, at: 0)
    }

    func updateVehicleMileage(_ mileage: Int, for vehicleID: UUID) {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicleID }) else { return }
        vehicles[index].currentMileage = mileage
    }
}
