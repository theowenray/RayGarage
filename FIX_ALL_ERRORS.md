# Fix All Xcode Errors - Step by Step

## The Main Problem: "Cannot find type 'Vehicle' in scope"

This means Xcode can't see your Model files. Here's how to fix it:

### Step 1: Verify Files Are in Xcode

1. In Xcode's left sidebar, look for:
   - `Models` folder (should be yellow)
   - Inside it: `Vehicle.swift` and `ServiceRecord.swift`

2. If you DON'T see them:
   - They weren't added properly
   - Go back and drag them from Finder again

### Step 2: Check Target Membership (MOST IMPORTANT!)

For EACH file that has errors:

1. **Click on `Vehicle.swift`** in the left sidebar
2. Look at the **right panel** (if you don't see it, press ⌘⌥1)
3. Find **"Target Membership"** section
4. Make sure **✅ RayGarage** is CHECKED
5. Repeat for:
   - `ServiceRecord.swift`
   - `GarageStore.swift`
   - `NotificationManager.swift`
   - ALL files in the `Views` folder

### Step 3: Clean Build Folder

1. In Xcode menu: **Product → Clean Build Folder** (or press ⌘⇧K)
2. Wait for it to finish
3. Build again: **⌘B**

### Step 4: If Still Not Working - Re-add Files

If files show in red or errors persist:

1. **Delete the files from Xcode** (right-click → Delete → Remove Reference)
2. **Re-add them properly:**
   - Drag from Finder
   - Make sure "Copy items if needed" is **UNCHECKED**
   - Make sure "Add to targets: RayGarage" is **CHECKED**

### Step 5: Check Build Phases

1. Click the **blue project icon** (top of left sidebar)
2. Select **RayGarage** target
3. Go to **Build Phases** tab
4. Expand **Compile Sources**
5. Make sure ALL your `.swift` files are listed there
6. If any are missing, click **+** and add them

## Quick Checklist

- [ ] All files visible in Xcode (not red)
- [ ] Target Membership checked for all files
- [ ] Clean build folder done
- [ ] All files in Compile Sources
- [ ] Build again (⌘B)

## If You're Still Stuck

The most common issue is **Target Membership**. Make absolutely sure every `.swift` file has the RayGarage target checked in the File Inspector (right panel).

