import SwiftUI
import AppKit
import Foundation

@main
struct XRPLResultCodesMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "XRPL Result Codes")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 450)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc func togglePopover() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

struct ResultCodeData: Codable {
    let type: String
    let count: Int
    let share: Double
}

struct XRPLData: Codable {
    let resultCodes: [ResultCodeData]
    let transactionTypes: [ResultCodeData]
    let totalTransactions: Int
    let lastUpdated: String
    let mostCommonResultCode: String?
    let mostCommonTransactionType: String?
    let averageResultCodes: Double
    let averageTransactionTypes: Double
    let latestLedger: Int
    let ledgerRange: String
    let networkName: String
}

enum DisplayMode: String, CaseIterable {
    case resultCodes = "Result Codes"
    case transactionTypes = "Tx Types"
}

enum DataMode: String, CaseIterable {
    case live = "Live"
    case historical100 = "Last 100"

    var ledgerCount: Int {
        switch self {
        case .live:
            return 1
        case .historical100:
            return 100
        }
    }

    var refreshInterval: TimeInterval {
        switch self {
        case .live:
            return 15
        case .historical100:
            return 300
        }
    }
}

enum XRPLNetwork: String, CaseIterable {
    case xrpl = "XRPL Mainnet"
    case xahau = "Xahau Network"
    
    var wsURL: String {
        switch self {
        case .xrpl:
            return "wss://xrpl1.panicbot.app"
        case .xahau:
            return "wss://xahau2.panicbot.app"
        }
    }
    
    var shortName: String {
        switch self {
        case .xrpl:
            return "XRPL"
        case .xahau:
            return "Xahau"
        }
    }
}

// XRPL WebSocket client
class XRPLClient: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var isConnected = false
    private var requestId = 0
    private var pendingRequests: [Int: (Result<[String: Any], Error>) -> Void] = [:]
    var onLedgerClosed: ((Int) -> Void)?
    
    override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    func connect(to network: XRPLNetwork) async throws {
        guard let url = URL(string: network.wsURL) else {
            throw XRPLError.invalidURL
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start listening for messages
        receiveMessage()
        
        // Wait a bit for connection to establish
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        isConnected = true
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        pendingRequests.removeAll()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue listening
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }

        if let id = json["id"] as? Int,
           let completion = pendingRequests[id] {
            pendingRequests.removeValue(forKey: id)

            if let error = json["error"] as? [String: Any] {
                completion(.failure(XRPLError.serverError(error["error_message"] as? String ?? "Unknown error")))
            } else {
                completion(.success(json))
            }
            return
        }

        if let type = json["type"] as? String, type == "ledgerClosed" {
            if let ledgerIndex = json["ledger_index"] as? Int {
                onLedgerClosed?(ledgerIndex)
            } else if let ledgerString = json["ledger_index"] as? String,
                      let ledgerIndex = Int(ledgerString) {
                onLedgerClosed?(ledgerIndex)
            }
        }
    }
    
    func request(_ command: [String: Any]) async throws -> [String: Any] {
        guard isConnected else {
            throw XRPLError.notConnected
        }
        
        requestId += 1
        var requestData = command
        requestData["id"] = requestId
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestData)
        let message = URLSessionWebSocketTask.Message.string(String(data: jsonData, encoding: .utf8)!)
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[requestId] = { result in
                continuation.resume(with: result)
            }
            
            webSocketTask?.send(message) { error in
                if let error = error {
                    self.pendingRequests.removeValue(forKey: self.requestId)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func subscribeToLedgerClosed() async throws {
        _ = try await request([
            "command": "subscribe",
            "streams": ["ledger"]
        ])
    }
}

extension XRPLClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
        isConnected = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
        isConnected = false
    }
}

enum XRPLError: Error, LocalizedError {
    case invalidURL
    case notConnected
    case serverError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .notConnected:
            return "Not connected to XRPL"
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// XRPL Data Service
@MainActor
class XRPLDataService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedNetwork: XRPLNetwork = .xrpl
    @Published var dataMode: DataMode = .historical100
    @Published var lastDataUpdate = Date() // Trigger UI updates
    
    // Cache data for both networks
    private var cachedData: [XRPLNetwork: XRPLData] = [:]
    private var refreshTimer: Timer?
    private var liveClients: [XRPLNetwork: XRPLClient] = [:]
    
    init() {
        // Timer will be started by the ContentView
    }
    
    deinit {
        refreshTimer?.invalidate()
        Task { @MainActor in
            self.stopLiveListeners()
        }
    }
    
    func getCurrentData() -> XRPLData? {
        return cachedData[selectedNetwork]
    }
    
    func startAutoRefresh() {
        refreshTimer?.invalidate()

        if dataMode == .live {
            stopLiveListeners()
            Task { @MainActor in
                await startLiveListeners()
            }
            return
        }

        stopLiveListeners()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: dataMode.refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchAllNetworks()
            }
        }
    }

    private func startLiveListeners() async {
        for network in XRPLNetwork.allCases {
            let client = XRPLClient()
            liveClients[network] = client

            client.onLedgerClosed = { [weak self] _ in
                Task { @MainActor in
                    await self?.refreshLiveData(for: network)
                }
            }

            do {
                try await client.connect(to: network)
                try await client.subscribeToLedgerClosed()
            } catch {
                print("❌ Live subscribe failed for \(network.shortName): \(error)")
            }
        }
    }

    private func stopLiveListeners() {
        for (_, client) in liveClients {
            client.disconnect()
        }
        liveClients.removeAll()
    }

    private func refreshLiveData(for network: XRPLNetwork) async {
        guard dataMode == .live else { return }

        let client = XRPLClient()
        if let data = await fetchResultCodes(for: network, using: client) {
            cachedData[network] = data
            lastDataUpdate = Date()
        }
    }
    
    func fetchAllNetworks() async -> XRPLData? {
        isLoading = true
        error = nil
        
        // Fetch both networks concurrently with separate clients
        async let xrplTask = fetchResultCodes(for: .xrpl, using: XRPLClient())
        async let xahauTask = fetchResultCodes(for: .xahau, using: XRPLClient())
        
        let (xrplData, xahauData) = await (xrplTask, xahauTask)
        
        // Update cached data
        if let xrplData = xrplData {
            cachedData[.xrpl] = xrplData
        }
        if let xahauData = xahauData {
            cachedData[.xahau] = xahauData
        }
        
        // Trigger UI update
        lastDataUpdate = Date()
        isLoading = false
        return cachedData[selectedNetwork]
    }
    
    @available(*, deprecated, message: "Use fetchAllNetworks() instead")
    func fetchResultCodes() async -> XRPLData? {
        return await fetchAllNetworks()
    }
    
    private func fetchResultCodes(for network: XRPLNetwork, using client: XRPLClient) async -> XRPLData? {
        do {
            print("🔄 Starting concurrent fetch for \(network.shortName)")
            try await client.connect(to: network)
            defer { 
                client.disconnect()
                print("✅ Completed fetch for \(network.shortName)")
            }
            
            // Get latest ledger
            let ledgerResponse = try await client.request([
                "command": "ledger",
                "ledger_index": "validated"
            ])
            
            guard let result = ledgerResponse["result"] as? [String: Any],
                  let latestLedger = result["ledger_index"] as? Int else {
                throw XRPLError.invalidResponse
            }
            
            let startLedger = max(latestLedger - dataMode.ledgerCount + 1, 1)
            let ledgerRange = "\(startLedger) to \(latestLedger)"
            
            var resultCounts: [String: Int] = [:]
            var transactionTypeCounts: [String: Int] = [:]
            var totalTransactions = 0
            
            // Fetch ledgers sequentially to avoid complex concurrency issues
            for ledgerIndex in stride(from: latestLedger, through: startLedger, by: -1) {
                do {
                    let transactions = try await fetchLedgerTransactions(ledgerIndex: ledgerIndex, using: client)
                    for tx in transactions {
                        totalTransactions += 1
                        let resultCode = extractResultCode(from: tx)
                        resultCounts[resultCode, default: 0] += 1

                        let transactionType = extractTransactionType(from: tx)
                        transactionTypeCounts[transactionType, default: 0] += 1
                    }
                } catch {
                    print("⚠️ Failed to fetch ledger \(ledgerIndex) for \(network.shortName): \(error)")
                }
            }
            
            return processResultCounts(resultCounts,
                                       transactionTypeCounts: transactionTypeCounts,
                                       totalTransactions: totalTransactions,
                                       latestLedger: latestLedger,
                                       ledgerRange: ledgerRange,
                                       network: network)
            
        } catch {
            print("❌ Error fetching \(network.shortName) result codes: \(error)")
            return nil
        }
    }
    
    private func fetchLedgerTransactions(ledgerIndex: Int, using client: XRPLClient) async throws -> [[String: Any]] {
        let response = try await client.request([
            "command": "ledger",
            "ledger_index": ledgerIndex,
            "transactions": true,
            "expand": true,
            "binary": false
        ])
        
        guard let result = response["result"] as? [String: Any],
              let ledger = result["ledger"] as? [String: Any],
              let transactions = ledger["transactions"] as? [[String: Any]] else {
            return []
        }
        
        return transactions
    }
    
    private func extractResultCode(from tx: [String: Any]) -> String {
        // Check meta.TransactionResult
        if let meta = tx["meta"] as? [String: Any],
           let result = meta["TransactionResult"] as? String {
            return result
        }
        
        // Check meta.transaction_result
        if let meta = tx["meta"] as? [String: Any],
           let result = meta["transaction_result"] as? String {
            return result
        }
        
        // Check metaData variants
        if let metaData = tx["metaData"] as? [String: Any] {
            if let result = metaData["TransactionResult"] as? String {
                return result
            }
            if let result = metaData["transaction_result"] as? String {
                return result
            }
        }
        
        return "Unknown"
    }

    private func extractTransactionType(from tx: [String: Any]) -> String {
        if let type = tx["TransactionType"] as? String {
            return type
        }

        if let txJson = tx["tx"] as? [String: Any],
           let type = txJson["TransactionType"] as? String {
            return type
        }

        return "Unknown"
    }
    
    private func processResultCounts(_ counts: [String: Int],
                                     transactionTypeCounts: [String: Int],
                                     totalTransactions: Int,
                                     latestLedger: Int,
                                     ledgerRange: String,
                                     network: XRPLNetwork) -> XRPLData {
        let resultEntries = counts.sorted { $0.value > $1.value }
        let typeEntries = transactionTypeCounts.sorted { $0.value > $1.value }

        let resultCodes = resultEntries.map { (type, count) in
            ResultCodeData(
                type: type,
                count: count,
                share: totalTransactions > 0 ? Double(count) / Double(totalTransactions) * 100 : 0
            )
        }

        let transactionTypes = typeEntries.map { (type, count) in
            ResultCodeData(
                type: type,
                count: count,
                share: totalTransactions > 0 ? Double(count) / Double(totalTransactions) * 100 : 0
            )
        }

        let mostCommonResultCode = resultEntries.first?.key
        let mostCommonTransactionType = typeEntries.first?.key
        let averageResultCodes = resultEntries.isEmpty ? 0 : Double(totalTransactions) / Double(resultEntries.count)
        let averageTransactionTypes = typeEntries.isEmpty ? 0 : Double(totalTransactions) / Double(typeEntries.count)

        return XRPLData(
            resultCodes: resultCodes,
            transactionTypes: transactionTypes,
            totalTransactions: totalTransactions,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            mostCommonResultCode: mostCommonResultCode,
            mostCommonTransactionType: mostCommonTransactionType,
            averageResultCodes: averageResultCodes,
            averageTransactionTypes: averageTransactionTypes,
            latestLedger: latestLedger,
            ledgerRange: ledgerRange,
            networkName: network.rawValue
        )
    }
}

struct ContentView: View {
    @StateObject private var dataService = XRPLDataService()
    @State private var data: XRPLData?
    @State private var lastRefresh = Date()
    @State private var displayMode: DisplayMode = .resultCodes
    @State private var showFilters = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(spacing: 6) {
                HStack {
                    DisclosureGroup("Filters", isExpanded: $showFilters) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Network")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Picker("", selection: $dataService.selectedNetwork) {
                                ForEach(XRPLNetwork.allCases, id: \.self) { network in
                                    Text(network.shortName)
                                        .tag(network)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            .disabled(dataService.isLoading)
                            .onChange(of: dataService.selectedNetwork) { oldValue, newValue in
                                if oldValue != newValue {
                                    // Update display with cached data immediately
                                    updateDisplayData()

                                    // Refresh if no cached data exists for the new network
                                    if dataService.getCurrentData() == nil {
                                        Task {
                                            await refreshData()
                                        }
                                    }
                                }
                            }

                            Text("View")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Picker("", selection: $displayMode) {
                                ForEach(DisplayMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()

                            Text("Data")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Picker("", selection: $dataService.dataMode) {
                                ForEach(DataMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            .onChange(of: dataService.dataMode) { _, _ in
                                dataService.startAutoRefresh()
                                Task {
                                    await refreshData()
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await refreshData()
                        }
                    }) {
                        HStack(spacing: 4) {
                            if dataService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                            }
                            Text("Refresh")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(dataService.isLoading)
                }
            }
            
            // Error message
            if let error = dataService.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            
            if let data = data {
                let entries = displayMode == .resultCodes ? data.resultCodes : data.transactionTypes
                let mostCommon = displayMode == .resultCodes ? data.mostCommonResultCode : data.mostCommonTransactionType
                let average = displayMode == .resultCodes ? data.averageResultCodes : data.averageTransactionTypes
                // Statistics
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Total: \(data.totalTransactions)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let mostCommon = mostCommon {
                            Text("Top: \(mostCommon)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Network: \(data.networkName)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        if dataService.dataMode == .live {
                            Text("Ledger: \(data.latestLedger)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Ledgers: \(data.ledgerRange)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                // List
                if entries.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No transactions found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(entries.enumerated()), id: \.offset) { index, resultCode in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(resultCode.type)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(resultCode.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("(\(String(format: "%.1f", resultCode.share))%)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Progress bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 6)
                                            
                                            Rectangle()
                                                .fill(barColor(for: index))
                                                .frame(width: geometry.size.width * CGFloat(resultCode.share / 100.0), height: 6)
                                        }
                                    }
                                    .frame(height: 6)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Footer
                HStack {
                    Text("Updated: \(formatDate(data.lastUpdated))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if average > 0 {
                        Text("Avg: \(String(format: "%.1f", average))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
            } else if dataService.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Fetching \(dataService.selectedNetwork.shortName) \(dataService.dataMode.rawValue.lowercased()) data...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Connecting to \(dataService.selectedNetwork.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "network")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Ready to fetch \(dataService.selectedNetwork.shortName) data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Start Loading") {
                        Task {
                            await refreshData()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .frame(width: 350, height: 450)
        .onAppear {
            updateDisplayData()
            
            Task {
                await refreshData()
            }
            
            // Start auto-refresh timer
            dataService.startAutoRefresh()
        }
        .onChange(of: dataService.lastDataUpdate) { _, _ in
            // Update display when background refresh completes
            updateDisplayData()
        }
    }
    
    @MainActor
    private func updateDisplayData() {
        data = dataService.getCurrentData()
    }
    
    @MainActor
    private func refreshData() async {
        if let newData = await dataService.fetchAllNetworks() {
            data = newData
            lastRefresh = Date()
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .short
            displayFormatter.dateStyle = .none
            return displayFormatter.string(from: date)
        }
        return "Unknown"
    }
    
    private func barColor(for index: Int) -> Color {
        let colors: [Color] = [.green, .blue, .orange, .red, .purple, .pink, .yellow, .cyan]
        return colors[index % colors.count]
    }
}