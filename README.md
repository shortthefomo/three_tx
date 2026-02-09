# XRPL & Xahau Result Codes - macOS Menu Bar App

A native macOS menu bar application that displays real-time XRPL (XRP Ledger) and Xahau Network transaction result codes and statistics.

![macOS App](https://img.shields.io/badge/macOS-14.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.1+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📊 Features

- **Dual network support** - Switch between XRPL mainnet and Xahau network
- **Real-time connectivity** - Direct WebSocket connections to both networks
- **Network toggle** - Easy switching with segmented control interface
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
- **Dual WebSocket clients** - Direct XRPL and Xahau network connections
- **Network switching** - Dynamic network selection with state management
- **App bundle structure** - Standard macOS application format

## 📱 Usage

1. **Launch** the app (look for chart icon in menu bar)
2. **Select network** - Choose between XRPL or Xahau using the toggle
3. **Click icon** to view result codes for selected network
4. **Switch networks** - Toggle automatically refreshes data
5. **Refresh** manually or wait for auto-refresh
6. **View statistics** including totals, percentages, and trends

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

## 🌐 Network Support

The app connects directly to both networks:

**XRPL Mainnet:**
- **Endpoint:** Three-dev XRPL node
- **Data source:** Last 50 XRPL ledgers (configurable)
- **Result codes:** Standard XRPL transaction results

**Xahau Network:**
- **Endpoint:** Three-dev Xahau node
- **Data source:** Last 50 Xahau ledgers (configurable)
- **Result codes:** Xahau-specific transaction results

- **Update frequency:** Every 5 minutes for selected network
- **Fallback configuration:** Can be modified in source code

## 🔒 Privacy & Security

- **No data collection** - Everything stays on your device
- **Direct network connections** - Connects to XRPL and Xahau networks directly
- **No third-party servers** - No intermediary services involved
- **Open source** - Inspect all code in `Source/`
- **Minimal permissions** - Only needs network access

## 🛠️ Customization

Edit `Source/XRPLMenuBarApp.swift` to customize:

- **WebSocket URLs** - Change XRPL or Xahau node endpoints
- **Default network** - Set which network loads on startup
- **Ledger count** - Adjust number of ledgers to analyze (per network)
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