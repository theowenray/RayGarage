# Quick Setup Guide for RayGarage

## Step 1: Create Xcode Project

1. **Open Xcode** (if you don't have it, download from the App Store or Apple Developer site)

2. **Create New Project:**
   - File → New → Project (or ⌘⇧N)
   - Select **iOS** → **App**
   - Click **Next**

3. **Configure Project:**
   - **Product Name:** `RayGarage`
   - **Team:** Select your Apple ID (or leave blank for simulator)
   - **Organization Identifier:** `com.yourname` (or whatever you prefer)
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Storage:** Leave default
   - **Include Tests:** Optional (you can uncheck if you want)
   - Click **Next**

4. **Choose Location:**
   - Navigate to: `/Users/owen.ray/Documents/Documents - owen-mbpro/OWEN/YT/`
   - **IMPORTANT:** Create the project in a **NEW folder** called `RayGarage-Xcode` (or similar)
   - This keeps the Xcode project separate from your source files
   - Click **Create**

## Step 2: Add Source Files to Xcode Project

1. **Delete the default files:**
   - In Xcode, delete the default `ContentView.swift` and `RayGarageApp.swift` that Xcode created
   - Right-click → Delete → Move to Trash

2. **Add your source files:**
   - In Finder, navigate to your source folder: `/Users/owen.ray/Documents/Documents - owen-mbpro/OWEN/YT/RayGarage`
   - **Drag and drop** the following into Xcode's Project Navigator (left sidebar):
     - `RayGarageApp.swift` → Drop in the root of the project
     - `Models/` folder → Drop in the project
     - `Views/` folder → Drop in the project
     - `Store/` folder → Drop in the project
     - `Managers/` folder → Drop in the project
   
   - When dragging, make sure:
     - ✅ **"Copy items if needed"** is **UNCHECKED** (since files are already there)
     - ✅ **"Create groups"** is selected (not "Create folder references")
     - ✅ **Add to targets:** RayGarage is checked

## Step 3: Configure Info.plist

1. **Add Info.plist to project:**
   - Drag `Info.plist` from your source folder into Xcode
   - OR manually add the keys:
     - Select your project in the navigator (top item)
     - Select the **RayGarage** target
     - Go to **Info** tab
     - Click the **+** button and add:
       - `Privacy - Camera Usage Description` = "RayGarage needs access to your camera to scan receipts for service records."
       - `Privacy - Photo Library Usage Description` = "RayGarage needs access to your photo library to add receipt images to service records."
       - `Privacy - Photo Library Additions Usage Description` = "RayGarage needs access to save receipt images to your photo library."

## Step 4: Enable Push Notifications (Optional but Recommended)

1. Select your project in navigator
2. Select **RayGarage** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Push Notifications**

## Step 5: Set Minimum iOS Version

1. Select your project in navigator
2. Select **RayGarage** target
3. Go to **General** tab
4. Set **Minimum Deployments** to **iOS 16.0** (or higher)

## Step 6: Run in Simulator

1. **Select a simulator:**
   - At the top of Xcode, click the device selector (next to the play button)
   - Choose any iPhone simulator (e.g., "iPhone 15 Pro" or "iPhone 14")

2. **Build and Run:**
   - Click the **Play button** (▶️) or press **⌘R**
   - Xcode will build the app and launch it in the simulator

3. **First Launch:**
   - The app will request notification permissions - click "Allow"
   - You'll see a sample boat vehicle
   - Start adding your vehicles!

## Troubleshooting

### "Cannot find type 'X' in scope"
- Make sure all files are added to the target
- Select the file → File Inspector (right panel) → Target Membership → ✅ RayGarage

### "Missing Info.plist keys"
- Make sure you added the camera/photo library permissions (Step 3)

### Build Errors
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Try building again: ⌘B

### Simulator Issues
- Make sure you have Xcode Command Line Tools installed
- Xcode → Settings → Locations → Command Line Tools → Select version

## Git (Optional)

You don't need to push to git to run the app, but if you want to:

```bash
cd "/Users/owen.ray/Documents/Documents - owen-mbpro/OWEN/YT/RayGarage"
git init  # if not already a git repo
git add .
git commit -m "Initial RayGarage app"
git branch -M main
# Then push to your remote if you have one
```

But this is **optional** - you can run the app without git!

