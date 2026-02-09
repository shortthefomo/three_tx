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
    let totalTransactions: Int
    let lastUpdated: String
    let mostCommon: String?
    let averagePerType: Double
    let ledgerRange: String
    let networkName: String
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
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id = json["id"] as? Int,
              let completion = pendingRequests[id] else {
            return
        }
        
        pendingRequests.removeValue(forKey: id)
        
        if let error = json["error"] as? [String: Any] {
            completion(.failure(XRPLError.serverError(error["error_message"] as? String ?? "Unknown error")))
        } else {
            completion(.success(json))
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
    let client = XRPLClient()
    private let ledgerCount = 50 // Reduced for faster loading
    
    func fetchResultCodes() async -> XRPLData? {
        isLoading = true
        error = nil
        
        do {
            try await client.connect(to: selectedNetwork)
            defer { client.disconnect() }
            
            // Get latest ledger
            let ledgerResponse = try await client.request([
                "command": "ledger",
                "ledger_index": "validated"
            ])
            
            guard let result = ledgerResponse["result"] as? [String: Any],
                  let latestLedger = result["ledger_index"] as? Int else {
                throw XRPLError.invalidResponse
            }
            
            let startLedger = max(latestLedger - ledgerCount + 1, 1)
            let ledgerRange = "\(startLedger) to \(latestLedger)"
            
            var resultCounts: [String: Int] = [:]
            
            // Fetch ledgers
            for ledgerIndex in stride(from: latestLedger, through: startLedger, by: -1) {
                let transactions = try await fetchLedgerTransactions(ledgerIndex: ledgerIndex)
                
                for tx in transactions {
                    let resultCode = extractResultCode(from: tx)
                    resultCounts[resultCode, default: 0] += 1
                }
            }
            
            let data = processResultCounts(resultCounts, ledgerRange: ledgerRange)
            isLoading = false
            return data
            
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }
    
    private func fetchLedgerTransactions(ledgerIndex: Int) async throws -> [[String: Any]] {
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
    
    private func processResultCounts(_ counts: [String: Int], ledgerRange: String) -> XRPLData {
        let entries = counts.sorted { $0.value > $1.value }
        let total = entries.reduce(0) { $0 + $1.value }
        
        let resultCodes = entries.map { (type, count) in
            ResultCodeData(
                type: type,
                count: count,
                share: total > 0 ? Double(count) / Double(total) * 100 : 0
            )
        }
        
        let mostCommon = entries.first?.key
        let averagePerType = entries.isEmpty ? 0 : Double(total) / Double(entries.count)
        
        return XRPLData(
            resultCodes: resultCodes,
            totalTransactions: total,
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            mostCommon: mostCommon,
            averagePerType: averagePerType,
            ledgerRange: ledgerRange,
            networkName: selectedNetwork.rawValue
        )
    }
}

struct ContentView: View {
    @StateObject private var dataService = XRPLDataService()
    @State private var data: XRPLData?
    @State private var lastRefresh = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text("Result Codes")
                        .font(.headline)
                        .foregroundColor(.primary)
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
                
                // Network toggle
                HStack {
                    Text("Network:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Network", selection: $dataService.selectedNetwork) {
                        ForEach(XRPLNetwork.allCases, id: \.self) { network in
                            Text(network.shortName)
                                .tag(network)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(dataService.isLoading)
                    .onChange(of: dataService.selectedNetwork) { oldValue, newValue in
                        if oldValue != newValue {
                            Task {
                                await refreshData()
                            }
                        }
                    }
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
                // Statistics
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Total: \(data.totalTransactions)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let mostCommon = data.mostCommon {
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
                        Text("Ledgers: \(data.ledgerRange)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Result codes list
                if data.resultCodes.isEmpty {
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
                            ForEach(Array(data.resultCodes.enumerated()), id: \.offset) { index, resultCode in
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
                    if data.averagePerType > 0 {
                        Text("Avg: \(String(format: "%.1f", data.averagePerType))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
            } else if dataService.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Fetching \(dataService.selectedNetwork.shortName) data...")
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
            Task {
                await refreshData()
            }
            
            // Auto-refresh every 5 minutes
            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                Task {
                    await refreshData()
                }
            }
        }
    }
    
    private func refreshData() async {
        if let newData = await dataService.fetchResultCodes() {
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