# XRPL Result Codes - macOS Menu Bar App

A native macOS menu bar application that displays real-time XRPL (XRP Ledger) transaction result codes and statistics.

![macOS App](https://img.shields.io/badge/macOS-14.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.1+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📊 Features

- **Real-time XRPL connectivity** - Direct WebSocket connection to XRPL network
- **Menu bar integration** - Always accessible from your menu bar
- **Color-coded visualizations** - Progress bars for each result code type
- **Live statistics** - Transaction counts, percentages, and ledger ranges
- **Auto-refresh** - Updates every 5 minutes automatically
- **Native Swift app** - Optimized for macOS performance

## 🏗️ Project Structure

```
three-tx/
├── Source/                     # Swift source code
│   └── XRPLMenuBarApp.swift   # Main application code
├── Build/                      # Compiled application
│   └── XRPLResultCodes.app    # App bundle (after build)
├── Distribution/              # Distribution packages
│   └── XRPL-Result-Codes-v1.0.zip
├── Scripts/                   # Build and distribution scripts
│   ├── build.sh              # Build the application
│   ├── create_distribution.sh # Create distribution package
│   ├── create_dmg.sh         # Create DMG installer
│   └── install.sh            # User installation script
└── README.md                 # This file
```

## 🚀 Quick Start

### Build the Application

```bash
# Build the app
./Scripts/build.sh

# Test the app
open Build/XRPLResultCodes.app
```

### Create Distribution Package

```bash
# Create distributable zip package
./Scripts/create_distribution.sh

# Distribution will be in Distribution/ folder
```

## 🔨 Development

### Requirements

- macOS 14.0 or later
- Swift 6.1+ (included with Xcode Command Line Tools)
- No additional dependencies required

### Building from Source

1. **Clone the repository**
2. **Build the application:**
   ```bash
   ./Scripts/build.sh
   ```
3. **Run the app:**
   ```bash
   open Build/XRPLResultCodes.app
   ```

### Project Architecture

- **Single Swift file** - All code in `Source/XRPLMenuBarApp.swift`
- **SwiftUI interface** - Native macOS UI framework
- **WebSocket client** - Direct XRPL network connection
- **App bundle structure** - Standard macOS application format

## 📱 Usage

1. **Launch** the app (look for chart icon in menu bar)
2. **Click icon** to view XRPL result codes
3. **Refresh** manually or wait for auto-refresh
4. **View statistics** including totals, percentages, and trends

### Common Result Codes

- **tesSUCCESS** - Successful transactions (usually majority)
- **tecPATH_DRY** - Payment path issues  
- **tecUNFUNDED_PAYMENT** - Insufficient funds
- **tecNO_DST** - Destination account doesn't exist
- And many more XRPL-specific result codes

## 📦 Distribution

### For End Users

Download the latest release and run the installer:

```bash
./install.sh
```

### For Developers

Build and package your own distribution:

```bash
# Build the app
./Scripts/build.sh

# Create distribution package
./Scripts/create_distribution.sh

# Optional: Create DMG installer
./Scripts/create_dmg.sh
```

## 🌐 XRPL Network

The app connects directly to:
- **Primary:** XRPL and Xahau nodes run by three-dev
- **Fallback:** Can be configured in source code
- **Data source:** Last 50 ledgers (configurable)
- **Update frequency:** Every 5 minutes

## 🔒 Privacy & Security

- **No data collection** - Everything stays on your device
- **Direct XRPL connection** - No third-party servers
- **Open source** - Inspect all code in `Source/`
- **Minimal permissions** - Only needs network access

## 🛠️ Customization

Edit `Source/XRPLMenuBarApp.swift` to customize:

- **WebSocket URL** - Change XRPL node endpoint
- **Ledger count** - Adjust number of ledgers to analyze
- **Refresh interval** - Modify auto-refresh timing
- **UI colors** - Customize progress bar colors
- **Window size** - Adjust popover dimensions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes to `Source/XRPLMenuBarApp.swift`
4. Test with `./Scripts/build.sh`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **XRPL Community** - For the robust XRP Ledger network
- **Apple** - For SwiftUI and macOS development tools
- **Contributors** - All who help improve this project