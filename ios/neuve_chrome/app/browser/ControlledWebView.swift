import SwiftUI
import WebKit

/// A controlled web view component using iOS 26 WebKit for SwiftUI APIs
@available(iOS 26.0, *)
public struct ControlledWebView: View {
    /// Navigation delegate for policy decisions  
    @StateObject private var navigationDelegate: WKNavigationDelegate & ObservableObject
    
    /// Web view state management
    @State private var webView: WKWebView?
    
    /// The initial URL to load
    private let initialURL: URL
    
    /// Configuration options
    private let configuration: Configuration
    
    /// Progress tracking
    @State private var loadingProgress: Double = 0.0
    @State private var isLoading: Bool = false
    
    /// Navigation state
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var currentTitle: String = ""
    @State private var currentURL: URL?
    
    /// Alert presentation
    @State private var showBlockedNavigationAlert = false
    @State private var showExportMenu = false
    
    /// Configuration for the controlled web view
    @available(iOS 26.0, *)
    public struct Configuration {
        public var navigationPolicy: NavigationPolicy
        public var allowsBackForwardGestures: Bool
        public var allowsLinkPreview: Bool
        public var javascriptEnabled: Bool
        public var deviceSensorAuthorization: DeviceSensorAuthorization
        
        public init(
            navigationPolicy: NavigationPolicy = .defaultPolicy,
            allowsBackForwardGestures: Bool = true,
            allowsLinkPreview: Bool = true,
            javascriptEnabled: Bool = true,
            deviceSensorAuthorization: DeviceSensorAuthorization = .default
        ) {
            self.navigationPolicy = navigationPolicy
            self.allowsBackForwardGestures = allowsBackForwardGestures
            self.allowsLinkPreview = allowsLinkPreview
            self.javascriptEnabled = javascriptEnabled
            self.deviceSensorAuthorization = deviceSensorAuthorization
        }
    }
    
    /// Device sensor authorization configuration
    @available(iOS 26.0, *)
    public struct DeviceSensorAuthorization: Sendable {
        public var allowsMotionSensors: Bool
        public var allowsCameraAccess: Bool
        public var allowsMicrophoneAccess: Bool
        
        public init(allowsMotionSensors: Bool = true, allowsCameraAccess: Bool = false, allowsMicrophoneAccess: Bool = false) {
            self.allowsMotionSensors = allowsMotionSensors
            self.allowsCameraAccess = allowsCameraAccess
            self.allowsMicrophoneAccess = allowsMicrophoneAccess
        }
        
        public static let `default` = DeviceSensorAuthorization(
            allowsMotionSensors: true,
            allowsCameraAccess: false,
            allowsMicrophoneAccess: false
        )
        
        public static let restrictive = DeviceSensorAuthorization(
            allowsMotionSensors: false,
            allowsCameraAccess: false,
            allowsMicrophoneAccess: false
        )
    }
    
    /// Initialize with URL and optional configuration
    public init(url: URL, configuration: Configuration = Configuration()) {
        self.initialURL = url
        self.configuration = configuration
        
        // Create WebPage configuration
        var pageConfig = WebPage.Configuration()
        
        // Set navigation preferences
        pageConfig.defaultNavigationPreferences.allowsContentJavaScript = configuration.javascriptEnabled
        pageConfig.defaultNavigationPreferences.preferredContentMode = configuration.contentMode
        pageConfig.defaultNavigationPreferences.preferredHTTPSNavigationPolicy = configuration.httpsUpgradePolicy
        
        // Configure device sensor authorization
        pageConfig.deviceSensorAuthorization = WebPage.DeviceSensorAuthorization(
            allowsMotionSensors: configuration.deviceSensorAuthorization.allowsMotionSensors,
            allowsCameraAccess: configuration.deviceSensorAuthorization.allowsCameraAccess,
            allowsMicrophoneAccess: configuration.deviceSensorAuthorization.allowsMicrophoneAccess
        )
        
        // Register custom scheme handler
        if let scheme = URLScheme(CustomSchemeHandler.scheme) {
            pageConfig.urlSchemeHandlers = [scheme: CustomSchemeHandler()]
        }
        
        // Create navigation delegate
        let navDelegate = ControlledNavigationDelegate(navigationPolicy: configuration.navigationPolicy)
        
        // Create WebPage with configuration and delegate
        let webpage = WebPage(configuration: pageConfig, navigationDecider: navDelegate)
        
        self._page = StateObject(wrappedValue: webpage)
        self._navigationDelegate = StateObject(wrappedValue: navDelegate)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Navigation toolbar
            navigationToolbar
            
            // Progress bar
            if isLoading {
                ProgressView(value: loadingProgress)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
            }
            
            // Web content
            WebView(webPage)
                .allowsBackForwardNavigationGestures(configuration.allowsBackForwardGestures)
                .allowsLinkPreview(configuration.allowsLinkPreview)
                .onAppear {
                    loadInitialURL()
                }
                .onChange(of: webPage.estimatedProgress) { progress in
                    loadingProgress = progress
                }
                .onChange(of: webPage.isLoading) { loading in
                    isLoading = loading
                }
                .onChange(of: webPage.title) { title in
                    currentTitle = title ?? ""
                }
                .onChange(of: webPage.url) { url in
                    currentURL = url
                }
                .onChange(of: webPage.backForwardList) { list in
                    canGoBack = !list.backList.isEmpty
                    canGoForward = !list.forwardList.isEmpty
                }
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
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
            }
            .disabled(!canGoBack)
            
            // Forward button
            Button(action: goForward) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
            }
            .disabled(!canGoForward)
            
            // Reload button
            Button(action: reload) {
                Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                    .font(.system(size: 18))
            }
            
            Spacer()
            
            // Current page info
            VStack(alignment: .center, spacing: 2) {
                Text(currentTitle)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                if let url = currentURL {
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
            
            // Settings button (placeholder)
            Button(action: showSettings) {
                Image(systemName: "gearshape")
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
                    
                    Button(action: exportAsWebArchive) {
                        Label("Export as Web Archive", systemImage: "doc.zipper")
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
    
    private func loadInitialURL() {
        Task {
            // Load the initial URL
            _ = await webPage.load(URLRequest(url: initialURL))
        }
    }
    
    private func goBack() {
        guard let lastItem = webPage.backForwardList.backList.last else { return }
        // Note: In actual implementation, we'd use WebView's go(to:) method
        // For now, we'll load the URL directly
        Task {
            _ = await webPage.load(URLRequest(url: lastItem.url))
        }
    }
    
    private func goForward() {
        guard let firstItem = webPage.backForwardList.forwardList.first else { return }
        // Note: In actual implementation, we'd use WebView's go(to:) method
        Task {
            _ = await webPage.load(URLRequest(url: firstItem.url))
        }
    }
    
    private func reload() {
        if isLoading {
            webPage.stopLoading()
        } else {
            Task {
                await webPage.reload()
            }
        }
    }
    
    private func exportAsPDF() {
        Task {
            do {
                // Use iOS 26 WebPage export functionality
                let pdfData = try await webPage.export(as: .pdf)
                
                // Save to Documents directory
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(currentTitle.isEmpty ? "webpage" : currentTitle)_\(Date().timeIntervalSince1970).pdf"
                let fileURL = documentsPath.appendingPathComponent(fileName)
                
                try pdfData.write(to: fileURL)
                
                // Show success feedback
                // TODO: Present document picker or share sheet with saved PDF
                print("PDF saved to: \(fileURL)")
                
            } catch {
                print("PDF export failed: \(error)")
                // TODO: Show error alert
            }
        }
        showExportMenu = false
    }
    
    private func exportAsWebArchive() {
        Task {
            do {
                // Use iOS 26 WebPage export functionality for web archive
                let webArchiveData = try await webPage.export(as: .webArchive)
                
                // Save to Documents directory
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(currentTitle.isEmpty ? "webpage" : currentTitle)_\(Date().timeIntervalSince1970).webarchive"
                let fileURL = documentsPath.appendingPathComponent(fileName)
                
                try webArchiveData.write(to: fileURL)
                
                print("Web archive saved to: \(fileURL)")
                
            } catch {
                print("Web archive export failed: \(error)")
            }
        }
        showExportMenu = false
    }
    
    private func shareURL() {
        guard let url = currentURL else { return }
        
        // Create activity view controller for sharing
        let activityViewController = UIActivityViewController(
            activityItems: [url, currentTitle],
            applicationActivities: nil
        )
        
        // Present share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // Configure for iPad
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityViewController, animated: true)
        }
        
        showExportMenu = false
    }
    
    private func showSettings() {
        // TODO: Present settings view
    }
}

// MARK: - Preview

struct ControlledWebView_Previews: PreviewProvider {
    static var previews: some View {
        ControlledWebView(
            url: URL(string: "neuvebrowser://welcome")!,
            configuration: ControlledWebView.Configuration(
                navigationPolicy: .defaultPolicy,
                javascriptEnabled: true
            )
        )
    }
}