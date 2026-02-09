# XRPL Result Codes Menu Bar App

A native macOS menu bar application that displays real-time XRPL (XRP Ledger) transaction result codes and statistics.

## 📊 Features

- **Real-time XRPL data** - Connects directly to XRPL network
- **Menu bar integration** - Always accessible from your menu bar
- **Color-coded visualizations** - Progress bars for each result code type
- **Live statistics** - Transaction counts, percentages, and trends
- **Auto-refresh** - Updates every 5 minutes automatically
- **No dependencies** - Self-contained native macOS application

## 📱 What You'll See

- **tesSUCCESS** - Successful transactions (usually majority)
- **tecPATH_DRY** - Payment path issues
- **tecUNFUNDED_PAYMENT** - Insufficient funds
- **tecNO_DST** - Destination account doesn't exist
- And other XRPL result codes with their frequencies

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
2. **View live data** - Result codes with progress bars and statistics
3. **Manual refresh** - Click "Refresh" button for instant updates
4. **Auto-updates** - Data refreshes automatically every 5 minutes

## 🔧 System Requirements

- **macOS 14.0** or later
- **Internet connection** for XRPL network access
- **Menu bar access** (the app runs in the background)

## 🌐 Network

The app connects directly to the XRPL network to fetch:
- Latest ledger transactions
- Transaction result codes and metadata  
- Real-time statistics and trends

No external APIs or services required beyond the XRPL network itself.

## 🔒 Privacy & Security

- **No data collection** - All data stays on your device
- **Direct XRPL connection** - No third-party servers involved
- **Open source approach** - Transparent functionality
- **Minimal permissions** - Only needs network access

## 🆘 Troubleshooting

### App Won't Launch
- Check macOS version (requires 14.0+)
- Try right-clicking app → "Open" to override security warnings
- Ensure the app has network permissions

### No Data Showing  
- Check internet connection
- Click "Refresh" to manually update
- Wait 30 seconds for initial connection to XRPL network

### Menu Bar Icon Missing
- The app runs in background - look for chart icon in menu bar
- Try relaunching the application
- Check System Preferences → Login Items

## 🗑️ Uninstall

Simply delete the `XRPL Result Codes` app from your Applications folder.

---

**Version:** 1.0  
**Compatible with:** macOS 14.0+  
**Network:** Connects to XRPL mainnet  
**Update Frequency:** Every 5 minutes