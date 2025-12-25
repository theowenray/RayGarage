# How to Link Files to Xcode (So Changes Auto-Update)

## The Goal
Make Xcode reference your source files (not copy them), so when files are edited in the source folder, Xcode automatically sees the changes.

## Step 1: Remove Current Files from Xcode

1. In Xcode's left sidebar, find all your source files:
   - `RayGarageApp.swift`
   - `Models` folder
   - `Views` folder  
   - `Store` folder
   - `Managers` folder

2. **Delete them from Xcode** (but NOT from disk):
   - Right-click on each file/folder
   - Choose **"Delete"**
   - When asked, choose **"Remove Reference"** (NOT "Move to Trash")
   - This removes them from Xcode but keeps them on your computer

## Step 2: Re-add Files as References (Linked)

1. **Open Finder** and navigate to:
   ```
   /Users/owen.ray/Documents/Documents - owen-mbpro/OWEN/YT/RayGarage
   ```

2. **Drag files into Xcode:**
   - Drag `RayGarageApp.swift` from Finder
   - Drop it on the **blue project icon** (top of Xcode's left sidebar)
   - **IMPORTANT:** In the dialog that appears:
     - ✅ **"Copy items if needed"** = **UNCHECKED** (this is the key!)
     - ✅ **"Create groups"** = Selected
     - ✅ **"Add to targets: RayGarage"** = Checked
   - Click **Finish**

3. **Repeat for folders:**
   - Drag `Models` folder → Drop on blue project icon
   - Same settings: **UNCHECK** "Copy items if needed"
   - Drag `Views` folder → Same thing
   - Drag `Store` folder → Same thing
   - Drag `Managers` folder → Same thing

## Step 3: Verify They're Linked

After adding, the files should:
- Show in Xcode's left sidebar
- **NOT** have a blue folder icon (that means they're copied)
- When you click a file, the path in the right panel should point to your source folder

## Step 4: Test It Works

1. Make a small change to a file in Xcode (add a comment)
2. Save it
3. Check the file in Finder - it should be updated
4. Now I can edit files here, and Xcode will see the changes!

## What "Copy items if needed" Does

- **CHECKED** = Xcode copies files into the project folder (I can't edit those)
- **UNCHECKED** = Xcode links to your original files (I CAN edit those!)

## If You Already Copied Files

If you already added files with "Copy items if needed" checked:

1. Delete them from Xcode (Remove Reference)
2. Go to your Xcode project folder and delete the copied files there
3. Re-add them using the steps above with "Copy items if needed" UNCHECKED

## Quick Visual Guide

```
Finder:                    Xcode:
─────────────────          ─────────────────
📁 RayGarage                📁 RayGarage (blue)
  📄 RayGarageApp.swift  →    📄 RayGarageApp.swift (linked)
  📁 Models              →      📁 Models (linked)
  📁 Views               →      📁 Views (linked)
```

The arrow means "reference" - Xcode points to your files, doesn't copy them.

