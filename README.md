# RayGarage

A comprehensive vehicle maintenance tracking app for iOS built with SwiftUI. Track maintenance records, oil changes, tire life, insurance information, and more for your cars, boats, and motorcycles.

## Features

### Vehicle Management
- Support for multiple vehicle types: Car, Boat, Motorcycle, and Other
- Track vehicle details: year, make, model, current mileage
- Add custom notes for each vehicle

### Maintenance Records
- Track various service categories:
  - Oil Changes
  - Inspections
  - Repairs
  - Tire Services
  - Battery Replacements
  - Detailing
  - Other Services
- Add dates, mileage, costs, and detailed notes
- Scan or photograph receipts and attach them to service records
- View detailed service record history

### Oil Change Reminders
- Set reminders by date or mileage
- Automatic notifications when reminders are due
- Track last oil change and next scheduled service

### Tire Life Tracking
- Record tire brand, model, and installation details
- Track installation date and mileage
- Set expected tire life in miles
- Visual progress indicator showing remaining tire life
- Automatic calculation based on current vehicle mileage

### Insurance Information
- Store insurance company and policy number
- Track expiration dates with visual warnings
- Store contact phone numbers
- Add notes and additional information
- Color-coded expiration warnings (red for expired, orange for expiring soon)

### Receipt Scanning
- Take photos with camera
- Import from photo library
- Attach receipts to service records
- View receipts in service record details

### Data Persistence
- All data automatically saved using UserDefaults
- Data persists between app launches
- No external dependencies required

## Setup Instructions

### Xcode Project Setup

1. **Create a new Xcode project:**
   - Open Xcode
   - Create a new iOS App project
   - Choose SwiftUI as the interface
   - Name it "RayGarage"

2. **Add the source files:**
   - Copy all files from this repository into your Xcode project
   - Maintain the folder structure:
     - `Models/` - Vehicle.swift, ServiceRecord.swift
     - `Views/` - All SwiftUI view files
     - `Store/` - GarageStore.swift
     - `Managers/` - NotificationManager.swift
     - `RayGarageApp.swift` - Main app file

3. **Configure Info.plist:**
   - Add the `Info.plist` file to your project
   - Or manually add these keys to your project's Info.plist:
     - `NSCameraUsageDescription`: "RayGarage needs access to your camera to scan receipts for service records."
     - `NSPhotoLibraryUsageDescription`: "RayGarage needs access to your photo library to add receipt images to service records."
     - `NSPhotoLibraryAddUsageDescription`: "RayGarage needs access to save receipt images to your photo library."

4. **Enable Capabilities:**
   - In Xcode, go to your target's "Signing & Capabilities"
   - Ensure "Push Notifications" capability is enabled (for reminders)

5. **Build and Run:**
   - Select your target device or simulator
   - Build and run the app (⌘R)

### Permissions

The app will request the following permissions:
- **Camera**: When you tap "Camera" to scan a receipt
- **Photo Library**: When you select "Photo Library" to add a receipt
- **Notifications**: On first launch, to enable oil change reminders

## Usage

### Adding a Vehicle
1. Tap the "+" button in the top right
2. Enter vehicle details (name, type, year, make, model, mileage)
3. Optionally add tire information and insurance information
4. Tap "Save"

### Adding a Service Record
1. Open a vehicle from the main list
2. Tap the "+" button in the top right
3. Fill in service details:
   - Title and category
   - Date and mileage
   - Cost (optional)
   - Notes
4. Optionally add a receipt by tapping "Scan or Add Receipt"
5. Set reminders for oil changes (by date or mileage)
6. Tap "Save"

### Managing Tire Information
1. Open a vehicle
2. Tap "Add Tire Information" or tap existing tire info to edit
3. Enter tire brand, model, installation date, and expected life
4. The app will automatically calculate remaining tire life based on current mileage

### Managing Insurance Information
1. Open a vehicle
2. Tap "Add Insurance Information" or tap existing insurance info to edit
3. Enter insurance company, policy number, expiration date, and contact info
4. The app will show warnings for expired or expiring soon policies

### Viewing Receipts
1. Open a service record that has a receipt attached
2. The receipt image will be displayed at the top of the record details

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: ViewModels via `@StateObject` and `@EnvironmentObject`
- **Codable**: For data persistence
- **UserDefaults**: For local data storage
- **UserNotifications**: For reminder notifications

### Data Models
- `Vehicle`: Main vehicle entity with tire and insurance info
- `ServiceRecord`: Individual maintenance/service records
- `TireInfo`: Tire tracking information
- `InsuranceInfo`: Insurance policy information

### Key Components
- `GarageStore`: Observable object managing all vehicle data and persistence
- `NotificationManager`: Handles scheduling and managing reminders
- `ReceiptScannerView`: Camera and photo library integration

## Future Enhancements

Potential features for future versions:
- Cloud sync (iCloud)
- Export data to PDF
- Service history charts and graphs
- Multiple reminder types
- Service templates
- Parts inventory tracking
- Fuel economy tracking

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

## License

This project is created for personal use.

