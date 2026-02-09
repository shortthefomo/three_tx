# XRPL Result Codes - macOS Menu Bar App v1.0

A native macOS application for monitoring transaction result codes on both XRPL and Xahau networks.

## 🚨 IMPORTANT: macOS Security Warning Fix

**If you see a "damaged" or "can't be opened" error**, this is a normal macOS security warning for apps not distributed through the Mac App Store. The app is completely safe to use.

### ✅ Quick Solutions (Choose One):

#### Method 1: Enhanced Installer (Recommended)
```bash
# Extract the download and run:
./enhanced_install.sh
```
*This automatically handles the security warning and installs the app.*

#### Method 2: Right-Click Method
1. Right-click on `XRPLResultCodes.app`
2. Select "Open" from the context menu  
3. Click "Open" when macOS asks for confirmation
4. The app will launch and be trusted for future use

#### Method 3: Command Line
```bash
# Remove the quarantine flag:
xattr -dr com.apple.quarantine XRPLResultCodes.app

# Then launch normally:
open XRPLResultCodes.app
```

#### Method 4: System Preferences
1. Go to System Preferences → Security & Privacy
2. Click "Open Anyway" if the warning appears there
3. Confirm by clicking "Open"

---

## 📥 Installation Options

### Option A: Enhanced Auto-Install
```bash
./enhanced_install.sh
```
- Automatically handles security warnings
- Installs to Applications folder
- Offers to launch immediately

### Option B: Quick Launch (No Install)
```bash
./launch.sh
```
- Test the app without installing
- Runs from current directory

### Option C: Manual Install
1. Handle security warning (see above)
2. Drag `XRPLResultCodes.app` to Applications folder
3. Launch from Launchpad or Applications

---

## 🚀 Features

- **Dual Network Support**: Monitor both XRPL and Xahau networks
- **Concurrent Fetching**: Parallel data processing for optimal performance
- **Instant Switching**: Cached data for immediate network toggling
- **Auto-Refresh**: Background updates every 5 minutes
- **Menu Bar Integration**: Native macOS interface
- **Real-time Monitoring**: Live transaction result code statistics

---

## 💻 System Requirements

- macOS 14.0 (Sonoma) or later
- Internet connection for network data

---

## 🛠️ Usage

1. Launch the app (it appears in your menu bar)
2. Click the menu bar icon to open the interface
3. Use the network toggle to switch between XRPL and Xahau
4. Data refreshes automatically every 5 minutes
5. Click "Refresh" for manual updates

---

## 🐛 Troubleshooting

### "App is damaged" Error
- This is a macOS Gatekeeper security warning
- Use any of the methods above to bypass it
- The app is safe and not actually damaged

### App Won't Start
- Make sure you're running macOS 14.0+
- Try the enhanced installer: `./enhanced_install.sh`
- Check that you have an internet connection

### Menu Bar Icon Missing
- The app runs in the menu bar (top-right of screen)
- Look for a small network/graph icon
- Try quitting and relaunching the app

---

## 🔧 Technical Details

- **Framework**: Native Swift 6.1+ with SwiftUI
- **Networks**: XRPL (wss://xrpl1.panicbot.app) & Xahau (wss://xahau2.panicbot.app)
- **Architecture**: Concurrent WebSocket processing
- **Data**: Monitors last 100 ledgers per network
- **Update Frequency**: Auto-refresh every 5 minutes

---

## 📞 Support

If you encounter issues:
1. Try the enhanced installer first
2. Check the troubleshooting section above
3. Ensure your macOS version is supported
4. Verify internet connectivity to XRPL/Xahau networks