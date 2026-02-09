# XRPL & Xahau Result Codes Menu Bar App v1.0

A native macOS menu bar application for monitoring transaction result codes on both XRPL and Xahau networks.

## ✨ Key Features

- **Dual Network Support**: Monitor both XRPL and Xahau networks simultaneously
- **Concurrent Data Fetching**: Optimized performance with parallel network processing  
- **Instant Network Switching**: Cached data for immediate display when toggling networks
- **Auto-Refresh**: Automatic background updates every 5 minutes
- **Native Integration**: Clean macOS menu bar interface with popover display
- **Real-time Monitoring**: Live transaction result code statistics
- **Interactive Visualization**: Progress bars and detailed breakdowns

## 🔧 Technical Highlights

- Native Swift 6.1+ with SwiftUI framework
- WebSocket connections to XRPL and Xahau networks
- Concurrent processing with separate client instances
- Enhanced threading and crash prevention
- Background data synchronization with UI updates

## 📥 Installation Options

1. **Automatic Install**: Run `./install.sh` to install to Applications folder
2. **Direct Launch**: Run `./launch.sh` to test without installing  
3. **Manual Install**: Drag `XRPLResultCodes.app` to Applications folder

## 💻 System Requirements

- macOS 14.0 (Sonoma) or later
- Internet connection for network data fetching

## 🛠️ Usage

1. Launch the app (appears in menu bar)
2. Click the menu bar icon to open the interface
3. Use the network toggle to switch between XRPL and Xahau
4. Data refreshes automatically every 5 minutes
5. Click Refresh button for manual updates

## 🐛 Bug Fixes in v1.0

- Fixed app crashes related to threading conflicts
- Resolved auto-refresh display update issues
- Improved concurrency handling for better stability
- Enhanced error handling for network operations

## 📦 Download

Download `XRPL-Result-Codes-v1.0.zip` from the releases section and extract it to get started.