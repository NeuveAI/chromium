import SwiftUI
import UIKit

// SwiftUI wrapper for Chrome's WebState content
struct WebContentView: UIViewRepresentable {
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

// Simple web view for testing when Chrome WebState is not available
struct SimpleWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        
        // Create a simple label showing the URL for now
        let label = UILabel()
        label.text = "Loading: \(url.absoluteString)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update loading state if needed
    }
}

// SwiftUI integration for web content in tabs
struct WebTabContentView: View {
    let tab: WebTab
    @ObservedObject var framework: NeuveUIFramework
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if let webStateBridge = framework.webStateBridge {
                WebContentView(
                    tabIndex: framework.activeTabIndex, 
                    webStateBridge: webStateBridge
                )
            } else {
                SimpleWebView(url: tab.url, isLoading: $isLoading)
            }
            
            // Loading indicator overlay
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
            }
        }
        .onAppear {
            // Simulate loading for the simple web view
            if framework.webStateBridge == nil {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
        }
    }
}