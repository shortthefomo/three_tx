# XRPL & Xahau Result Codes Menu Bar App

A native macOS menu bar application that displays real-time XRPL (XRP Ledger) and Xahau Network transaction result codes and statistics.

## 📊 Features

- **Dual network support** - Switch between XRPL mainnet and Xahau network
- **Real-time data** - Connects directly to both XRPL and Xahau networks
- **Filters panel** - Collapsible controls to keep the menu clean
- **Network toggle** - Easy switching between networks with segmented control
- **View toggle** - Switch between Result Codes and Tx Types
- **Data mode toggle** - Live (current ledger) or Last 100 ledgers
- **Menu bar integration** - Always accessible from your menu bar
- **Color-coded visualizations** - Progress bars for each result code type
- **Live statistics** - Transaction counts, percentages, and ledger info
- **Auto-refresh** - 15s in Live mode, 5m in Last 100 mode
- **No dependencies** - Self-contained native macOS application

## 📱 What You'll See

- **Filters panel** - Expand to show controls
- **Network selector** - Toggle between XRPL mainnet and Xahau network
- **View selector** - Result Codes or Tx Types
- **Data selector** - Live (current ledger) or Last 100 ledgers
- **tesSUCCESS** - Successful transactions (usually majority)
- **tecPATH_DRY** - Payment path issues
- **tecUNFUNDED_PAYMENT** - Insufficient funds
- **tecNO_DST** - Destination account doesn't exist
- And other result codes with their frequencies on both networks

## 🚀 Installation

### Automatic Installation (Recommended)

1. **Download** the installer package
2. **Run the installer**:
   ```bash
   ./install.sh
   ```
3. **Launch the app** when prompted, or find it in Applications

### Alternative: Direct Launch

1. **Run directly** without installing:
   ```bash
   ./launch.sh
   ```
2. **Look for** the chart icon in your menu bar

### Manual Installation

1. **Copy** `XRPLResultCodes.app` to your `/Applications` folder
2. **Double-click** the app to launch
3. **Look for** the chart icon in your menu bar

## 💻 Usage

1. **Click the chart icon** in your menu bar
2. **Open Filters** - Click the Filters disclosure
3. **Select network** - Choose between XRPL or Xahau
4. **Choose view** - Result Codes or Tx Types
5. **Choose data mode** - Live or Last 100 ledgers
6. **Manual refresh** - Click "Refresh" button for instant updates
7. **Auto-updates** - 15 seconds in Live, 5 minutes in Last 100

## 🔧 System Requirements

- **macOS 14.0** or later
- **Internet connection** for XRPL and Xahau network access
- **Menu bar access** (the app runs in the background)

## 🌐 Network

The app connects directly to both networks:

**XRPL Mainnet:**
- Latest XRPL ledger transactions
- Transaction result codes and metadata  
- Real-time XRPL statistics and trends
- Live mode shows the current ledger only
- Last 100 mode aggregates recent ledgers

**Xahau Network:**
- Latest Xahau ledger transactions
- Xahau-specific result codes and metadata
- Real-time Xahau network statistics
- Live mode shows the current ledger only
- Last 100 mode aggregates recent ledgers

No external APIs or services required beyond the native network connections.

## 🔒 Privacy & Security

- **No data collection** - All data stays on your device
- **Direct network connections** - Connects to XRPL and Xahau networks directly
- **No third-party servers** - No intermediary services involved
- **Open source approach** - Transparent functionality
- **Minimal permissions** - Only needs network access

## 🆘 Troubleshooting

### App Won't Launch
- Check macOS version (requires 14.0+)
- Try right-clicking app → "Open" to override security warnings
- Ensure the app has network permissions

### No Data Showing  
- Check internet connection
- Try switching between XRPL and Xahau networks using the toggle
- Click "Refresh" to manually update
- Wait 30 seconds for initial connection to selected network

### Menu Bar Icon Missing
- The app runs in background - look for chart icon in menu bar
- Try relaunching the application
- Check System Preferences → Login Items

## 🗑️ Uninstall

Simply delete the `XRPL & Xahau Result Codes` app from your Applications folder.

---

**Version:** 1.0  
**Compatible with:** macOS 14.0+  
**Networks:** XRPL Mainnet & Xahau Network  
**Update Frequency:** 15s (Live) or 5m (Last 100)