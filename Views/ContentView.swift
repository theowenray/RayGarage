import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showingAddVehicle = false

    var body: some View {
        NavigationStack {
            Group {
                if store.vehicles.isEmpty {
                    EmptyStateView(
                        title: "Add your first vehicle",
                        message: "Track oil changes, parts replacements, and service reminders in one place."
                    )
                } else {
                    List {
                        ForEach(store.vehicles) { vehicle in
                            NavigationLink(value: vehicle) {
                                VehicleRow(vehicle: vehicle)
                            }
                        }
                        .onDelete(perform: deleteVehicles)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Garage")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddVehicle = true
                    } label: {
                        Image(systemName: "plus")
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
    
    private func deleteVehicles(at offsets: IndexSet) {
        for index in offsets {
            store.deleteVehicle(store.vehicles[index])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GarageStore())
}
