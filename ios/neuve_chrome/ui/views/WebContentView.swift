import SwiftUI
import UIKit

// MARK: - Legacy UIViewRepresentable wrappers (for Chrome WebState integration)

// SwiftUI wrapper for Chrome's WebState content
struct LegacyWebContentView: UIViewRepresentable {
    let tabIndex: Int
    let webStateBridge: WebStateBridge
    
    func makeUIView(context: Context) -> UIView {
        let webView = webStateBridge.getWebViewForTab(at: tabIndex)
        webView?.backgroundColor = UIColor.systemBackground
        return webView ?? UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle updates if needed
    }
}

// MARK: - Modern WebTabContentView using ControlledWebView

/// SwiftUI integration for web content in tabs using the new WebKit for SwiftUI API
struct WebTabContentView: View {
    let tab: WebTab
    @ObservedObject var framework: NeuveUIFramework
    @State private var navigationPolicy: NavigationPolicy = .defaultPolicy
    @AppStorage("javascriptEnabled") private var javascriptEnabled = true
    @AppStorage("httpsUpgradeEnabled") private var httpsUpgradeEnabled = true
    
    var body: some View {
        Group {
            if framework.webStateBridge != nil {
                // Use legacy Chrome WebState integration if available
                LegacyWebContentView(
                    tabIndex: framework.activeTabIndex,
                    webStateBridge: framework.webStateBridge!
                )
            } else {
                // Use modern ControlledWebView with WebKit for SwiftUI (iOS 26+)
                if #available(iOS 26.0, *) {
                    ControlledWebView(
                        url: tab.url,
                        configuration: webViewConfiguration
                    )
                } else {
                    // Fallback for pre-iOS 26
                    Text("iOS 26 or later required for modern web view")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
    
    @available(iOS 26.0, *)
    private var webViewConfiguration: ControlledWebView.Configuration {
        ControlledWebView.Configuration(
            navigationPolicy: navigationPolicy,
            allowsBackForwardGestures: true,
            allowsLinkPreview: true,
            javascriptEnabled: javascriptEnabled,
            deviceSensorAuthorization: .default
        )
    }
}

// MARK: - Extension for Navigation Policy Management

extension WebTabContentView {
    /// Update navigation policy based on user preferences or security requirements
    mutating func updateNavigationPolicy(_ policy: NavigationPolicy) {
        self.navigationPolicy = policy
    }
    
    /// Apply a restricted domain policy for kiosk or managed environments
    mutating func applyRestrictedDomains(_ domains: [String]) {
        self.navigationPolicy = NavigationPolicy.restrictedDomains(domains)
    }
    
    /// Enable ad blocking policy
    mutating func enableAdBlocking() {
        self.navigationPolicy = NavigationPolicy.adBlockingPolicy()
    }
}