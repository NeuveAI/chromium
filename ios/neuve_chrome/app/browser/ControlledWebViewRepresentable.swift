import SwiftUI
import WebKit
import Combine

/// A controlled web view component that uses WKWebView with custom navigation policies
/// This is the iOS 17 compatible version using UIViewRepresentable
public struct ControlledWebViewRepresentable: View {
    /// The initial URL to load
    private let initialURL: URL
    
    /// Configuration options
    private let configuration: Configuration
    
    /// Navigation delegate for policy decisions
    @StateObject private var navigationDelegate: ControlledNavigationDelegate
    
    /// Web view state
    @StateObject private var webViewState = WebViewState()
    
    /// Alert presentation
    @State private var showBlockedNavigationAlert = false
    @State private var showExportMenu = false
    
    /// Configuration for the controlled web view
    public struct Configuration {
        public var navigationPolicy: NavigationPolicy
        public var allowsBackForwardGestures: Bool
        public var allowsLinkPreview: Bool
        public var javascriptEnabled: Bool
        public var httpsUpgradeEnabled: Bool
        
        public init(
            navigationPolicy: NavigationPolicy = .defaultPolicy,
            allowsBackForwardGestures: Bool = true,
            allowsLinkPreview: Bool = true,
            javascriptEnabled: Bool = true,
            httpsUpgradeEnabled: Bool = true
        ) {
            self.navigationPolicy = navigationPolicy
            self.allowsBackForwardGestures = allowsBackForwardGestures
            self.allowsLinkPreview = allowsLinkPreview
            self.javascriptEnabled = javascriptEnabled
            self.httpsUpgradeEnabled = httpsUpgradeEnabled
        }
    }
    
    /// Initialize with URL and optional configuration
    public init(url: URL, configuration: Configuration = Configuration()) {
        self.initialURL = url
        self.configuration = configuration
        
        // Create navigation delegate
        let navDelegate = ControlledNavigationDelegate(navigationPolicy: configuration.navigationPolicy)
        self._navigationDelegate = StateObject(wrappedValue: navDelegate)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Navigation toolbar
            navigationToolbar
            
            // Progress bar
            if webViewState.isLoading {
                ProgressView(value: webViewState.estimatedProgress)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
            }
            
            // Web content
            WebViewRepresentable(
                url: initialURL,
                configuration: configuration,
                navigationDelegate: navigationDelegate,
                webViewState: webViewState
            )
        }
        .onChange(of: navigationDelegate.blockedNavigationAlert) { alert in
            showBlockedNavigationAlert = alert != nil
        }
        .alert("Navigation Blocked", isPresented: $showBlockedNavigationAlert) {
            Button("OK") {
                navigationDelegate.clearBlockedAlert()
            }
        } message: {
            if let alert = navigationDelegate.blockedNavigationAlert {
                Text(ControlledNavigationDelegate.blockReasonDescription(alert.reason))
                    .font(.body)
                Text("URL: \(alert.blockedURL.absoluteString)")
                    .font(.caption)
            }
        }
        .sheet(isPresented: $showExportMenu) {
            exportMenuView
        }
    }
    
    // MARK: - Navigation Toolbar
    
    private var navigationToolbar: some View {
        HStack(spacing: 20) {
            // Back button
            Button(action: { webViewState.goBack() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
            }
            .disabled(!webViewState.canGoBack)
            
            // Forward button
            Button(action: { webViewState.goForward() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
            }
            .disabled(!webViewState.canGoForward)
            
            // Reload button
            Button(action: { webViewState.reload() }) {
                Image(systemName: webViewState.isLoading ? "xmark" : "arrow.clockwise")
                    .font(.system(size: 18))
            }
            
            Spacer()
            
            // Current page info
            VStack(alignment: .center, spacing: 2) {
                Text(webViewState.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                if let url = webViewState.url {
                    Text(url.host ?? url.absoluteString)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Export button
            Button(action: { showExportMenu = true }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(UIColor.separator)),
            alignment: .bottom
        )
    }
    
    // MARK: - Export Menu
    
    private var exportMenuView: some View {
        NavigationView {
            List {
                Section("Export Options") {
                    Button(action: exportAsPDF) {
                        Label("Export as PDF", systemImage: "doc.richtext")
                    }
                    
                    Button(action: shareURL) {
                        Label("Share URL", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showExportMenu = false
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func exportAsPDF() {
        webViewState.exportAsPDF()
        showExportMenu = false
    }
    
    private func shareURL() {
        guard let url = webViewState.url else { return }
        // TODO: Present share sheet with URL
        showExportMenu = false
    }
}

// MARK: - WebView State

/// Observable state for the web view
@MainActor
class WebViewState: ObservableObject {
    @Published var isLoading = false
    @Published var estimatedProgress: Double = 0.0
    @Published var title = ""
    @Published var url: URL?
    @Published var canGoBack = false
    @Published var canGoForward = false
    
    weak var webView: WKWebView?
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func reload() {
        if isLoading {
            webView?.stopLoading()
        } else {
            webView?.reload()
        }
    }
    
    func exportAsPDF() {
        guard let webView = webView else { return }
        
        webView.createPDF { result in
            switch result {
            case .success(let data):
                // Save PDF data
                // TODO: Implement save functionality
                break
            case .failure(let error):
                print("PDF export failed: \(error)")
            }
        }
    }
}

// MARK: - WKWebView UIViewRepresentable

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    let configuration: ControlledWebViewRepresentable.Configuration
    let navigationDelegate: ControlledNavigationDelegate
    let webViewState: WebViewState
    
    func makeUIView(context: Context) -> WKWebView {
        // Create WKWebView configuration
        let webConfiguration = WKWebViewConfiguration()
        
        // Configure JavaScript
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = configuration.javascriptEnabled
        
        // Register custom scheme handler
        webConfiguration.setURLSchemeHandler(WKWebViewSchemeHandler(), forURLScheme: WKWebViewSchemeHandler.scheme)
        
        // Create web view
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = navigationDelegate
        webView.allowsBackForwardNavigationGestures = configuration.allowsBackForwardGestures
        webView.allowsLinkPreview = configuration.allowsLinkPreview
        
        // Set up observation
        context.coordinator.startObserving(webView: webView, state: webViewState)
        webViewState.webView = webView
        
        // Load initial URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update configuration if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        private var observations: [NSKeyValueObservation] = []
        
        func startObserving(webView: WKWebView, state: WebViewState) {
            // Observe loading state
            observations.append(
                webView.observe(\.isLoading) { webView, _ in
                    Task { @MainActor in
                        state.isLoading = webView.isLoading
                    }
                }
            )
            
            // Observe progress
            observations.append(
                webView.observe(\.estimatedProgress) { webView, _ in
                    Task { @MainActor in
                        state.estimatedProgress = webView.estimatedProgress
                    }
                }
            )
            
            // Observe title
            observations.append(
                webView.observe(\.title) { webView, _ in
                    Task { @MainActor in
                        state.title = webView.title ?? ""
                    }
                }
            )
            
            // Observe URL
            observations.append(
                webView.observe(\.url) { webView, _ in
                    Task { @MainActor in
                        state.url = webView.url
                    }
                }
            )
            
            // Observe navigation state
            observations.append(
                webView.observe(\.canGoBack) { webView, _ in
                    Task { @MainActor in
                        state.canGoBack = webView.canGoBack
                    }
                }
            )
            
            observations.append(
                webView.observe(\.canGoForward) { webView, _ in
                    Task { @MainActor in
                        state.canGoForward = webView.canGoForward
                    }
                }
            )
        }
        
        deinit {
            observations.forEach { $0.invalidate() }
        }
    }
}

// MARK: - Preview

struct ControlledWebViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        ControlledWebViewRepresentable(
            url: URL(string: "neuvebrowser://welcome")!,
            configuration: ControlledWebViewRepresentable.Configuration(
                navigationPolicy: .defaultPolicy,
                javascriptEnabled: true
            )
        )
    }
}