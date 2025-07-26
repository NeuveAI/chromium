import Foundation

/// Defines the navigation policy for controlling allowed and blocked domains
public struct NavigationPolicy {
    /// List of domains that are explicitly allowed for navigation
    public var allowedDomains: [String]
    
    /// Whether to block file downloads
    public var blockDownloads: Bool
    
    /// List of URL patterns that are explicitly blocked
    public var blockedURLPatterns: [String]
    
    /// Initialize with default browser behavior (allow all)
    public init() {
        self.allowedDomains = []  // Empty means allow all domains
        self.blockDownloads = false
        self.blockedURLPatterns = []
    }
    
    /// Initialize with specific allowed domains
    public init(allowedDomains: [String], blockDownloads: Bool = false, blockedURLPatterns: [String] = []) {
        self.allowedDomains = allowedDomains
        self.blockDownloads = blockDownloads
        self.blockedURLPatterns = blockedURLPatterns
    }
    
    /// Check if a URL is allowed based on the policy
    public func isAllowed(url: URL) -> Bool {
        // Check if URL matches any blocked patterns first
        let urlString = url.absoluteString
        for pattern in blockedURLPatterns {
            if urlString.contains(pattern) {
                return false
            }
        }
        
        // If no allowed domains specified, allow all (browser default)
        if allowedDomains.isEmpty {
            return true
        }
        
        // Check if the host is in the allowed list
        guard let host = url.host else { return false }
        
        // Check exact match or subdomain match
        return allowedDomains.contains { allowedDomain in
            return host == allowedDomain || host.hasSuffix("." + allowedDomain)
        }
    }
    
    /// Check if this is a download URL
    public func isDownloadURL(_ url: URL) -> Bool {
        // Check common download file extensions
        let downloadExtensions = ["zip", "dmg", "exe", "pkg", "iso", "rar", "7z", "tar", "gz"]
        let pathExtension = url.pathExtension.lowercased()
        return downloadExtensions.contains(pathExtension)
    }
    
    /// Should block this navigation based on download policy
    public func shouldBlockAsDownload(_ url: URL) -> Bool {
        return blockDownloads && isDownloadURL(url)
    }
}

// MARK: - Common Policies

extension NavigationPolicy {
    /// Policy that allows only specific domains (e.g., for kiosk mode)
    public static func restrictedDomains(_ domains: [String]) -> NavigationPolicy {
        return NavigationPolicy(allowedDomains: domains, blockDownloads: true)
    }
    
    /// Policy that blocks common ad/tracking domains
    public static func adBlockingPolicy() -> NavigationPolicy {
        return NavigationPolicy(
            allowedDomains: [],  // Allow all domains
            blockDownloads: false,
            blockedURLPatterns: [
                "doubleclick.net",
                "googleadservices.com",
                "googlesyndication.com",
                "facebook.com/tr",
                "amazon-adsystem.com",
                "google-analytics.com"
            ]
        )
    }
    
    /// Default browser policy (allow everything)
    public static var defaultPolicy: NavigationPolicy {
        return NavigationPolicy()
    }
}