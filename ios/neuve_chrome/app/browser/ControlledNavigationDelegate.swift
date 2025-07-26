import Foundation
import WebKit
import Combine

/// Delegate that controls web navigation based on policies
/// Implements iOS 26's NavigationDeciding protocol for WebPage
@available(iOS 26.0, *)
@MainActor
public class ControlledNavigationDelegate: NSObject, ObservableObject, NavigationDeciding {
    /// The navigation policy to enforce
    private let navigationPolicy: NavigationPolicy
    
    /// Published property for alerts when navigation is blocked
    @Published public var blockedNavigationAlert: BlockedNavigationAlert?
    
    /// Published property for tracking navigation events
    @Published public var lastNavigationEvent: NavigationEvent?
    
    /// Alert information for blocked navigation
    public struct BlockedNavigationAlert: Identifiable {
        public let id = UUID()
        public let blockedURL: URL
        public let reason: BlockReason
        public let timestamp = Date()
        
        public enum BlockReason {
            case domainNotAllowed
            case blockedPattern
            case downloadBlocked
            case invalidURL
        }
    }
    
    /// Navigation event tracking
    public struct NavigationEvent {
        public let url: URL
        public let type: NavigationType
        public let timestamp = Date()
        
        public enum NavigationType {
            case allowed
            case blocked(BlockedNavigationAlert.BlockReason)
        }
    }
    
    /// Initialize with a navigation policy
    public init(navigationPolicy: NavigationPolicy = .defaultPolicy) {
        self.navigationPolicy = navigationPolicy
        super.init()
    }
    
    // MARK: - NavigationDeciding Protocol Methods
    
    /// Decide whether to allow a navigation action (iOS 26 WebKit for SwiftUI API)
    public func decidePolicy(
        for action: WebPage.NavigationAction,
        preferences: WebPage.NavigationPreferences
    ) async -> WKNavigationActionPolicy {
        // Extract the URL from the request
        guard let url = action.request.url else {
            // No URL, cancel navigation
            publishBlockedAlert(
                url: URL(string: "about:blank")!,
                reason: .invalidURL
            )
            return .cancel
        }
        
        // Check if this should trigger a download
        if action.shouldPerformDownload {
            if navigationPolicy.blockDownloads {
                publishBlockedAlert(url: url, reason: .downloadBlocked)
                return .cancel
            } else {
                // Allow download to proceed
                return .download
            }
        }
        
        // Check if this is a download URL based on extension
        if navigationPolicy.shouldBlockAsDownload(url) {
            publishBlockedAlert(url: url, reason: .downloadBlocked)
            return .cancel
        }
        
        // Check navigation policy
        if !navigationPolicy.isAllowed(url: url) {
            // Determine the reason for blocking
            let reason: BlockedNavigationAlert.BlockReason
            if !navigationPolicy.blockedURLPatterns.isEmpty &&
               navigationPolicy.blockedURLPatterns.contains(where: { url.absoluteString.contains($0) }) {
                reason = .blockedPattern
            } else {
                reason = .domainNotAllowed
            }
            
            publishBlockedAlert(url: url, reason: reason)
            return .cancel
        }
        
        // Track allowed navigation
        lastNavigationEvent = NavigationEvent(url: url, type: .allowed)
        
        // Allow navigation
        return .allow
    }
    
    /// Decide whether to allow a navigation response (iOS 26 WebKit for SwiftUI API)
    public func decidePolicy(
        for response: WebPage.NavigationResponse
    ) async -> WKNavigationResponsePolicy {
        
        // Check if WebKit can display this content type
        guard response.canShowMimeType else {
            // Can't display, offer as download if allowed
            if navigationPolicy.blockDownloads {
                if let url = response.response.url {
                    publishBlockedAlert(url: url, reason: .downloadBlocked)
                }
                return .cancel
            } else {
                return .download
            }
        }
        
        // Check for specific MIME types that should be downloaded
        if let mimeType = response.response.mimeType {
            let downloadableMimeTypes = [
                "application/zip",
                "application/x-zip-compressed",
                "application/octet-stream",
                "application/x-msdownload"
            ]
            
            if downloadableMimeTypes.contains(mimeType) {
                if navigationPolicy.blockDownloads {
                    if let url = response.response.url {
                        publishBlockedAlert(url: url, reason: .downloadBlocked)
                    }
                    return .cancel
                } else {
                    return .download
                }
            }
        }
        
        // Allow the response
        return .allow
    }
    
    /// Handle authentication challenges (iOS 26 WebKit for SwiftUI API)
    public func decideAuthenticationChallengeDisposition(
        for challenge: AuthenticationChallenge
    ) async -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
        
        // For now, use default handling
        // In production, you might want to handle specific authentication types
        return (.performDefaultHandling, nil)
    }
    
    // MARK: - Helper Methods
    
    /// Publish a blocked navigation alert
    private func publishBlockedAlert(url: URL, reason: BlockedNavigationAlert.BlockReason) {
        let alert = BlockedNavigationAlert(blockedURL: url, reason: reason)
        blockedNavigationAlert = alert
        lastNavigationEvent = NavigationEvent(url: url, type: .blocked(reason))
    }
    
    /// Clear the current blocked navigation alert
    public func clearBlockedAlert() {
        blockedNavigationAlert = nil
    }
    
    /// Get a user-friendly description of why navigation was blocked
    public static func blockReasonDescription(_ reason: BlockedNavigationAlert.BlockReason) -> String {
        switch reason {
        case .domainNotAllowed:
            return "This domain is not allowed by the current navigation policy."
        case .blockedPattern:
            return "This URL matches a blocked pattern."
        case .downloadBlocked:
            return "Downloads are not allowed by the current policy."
        case .invalidURL:
            return "The URL is invalid or missing."
        }
    }
}