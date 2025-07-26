import Foundation
import WebKit

/// Handles custom URL schemes for the browser (e.g., neuvebrowser://)
/// Uses iOS 26 WebKit for SwiftUI URLSchemeHandler protocol
@available(iOS 26.0, *)
public struct CustomSchemeHandler: URLSchemeHandler {
    /// The custom scheme this handler manages
    public static let scheme = "neuvebrowser"
    
    /// Result type for the async sequence
    public typealias TaskResult = URLSchemeTaskResult
    
    /// Async sequence type for responses
    public struct TaskSequence: AsyncSequence {
        public typealias Element = TaskResult
        
        let request: URLRequest
        
        public struct AsyncIterator: AsyncIteratorProtocol {
            let request: URLRequest
            var hasYieldedResponse = false
            var hasYieldedData = false
            
            public mutating func next() async throws -> TaskResult? {
                // First yield the response
                if !hasYieldedResponse {
                    hasYieldedResponse = true
                    
                    guard let url = request.url else {
                        throw URLError(.badURL)
                    }
                    
                    // Determine content based on path
                    let (mimeType, contentLength) = try await contentInfo(for: url)
                    
                    let response = URLResponse(
                        url: url,
                        mimeType: mimeType,
                        expectedContentLength: contentLength,
                        textEncodingName: "utf-8"
                    )
                    
                    return .response(response)
                }
                
                // Then yield the data
                if !hasYieldedData {
                    hasYieldedData = true
                    
                    guard let url = request.url else {
                        throw URLError(.badURL)
                    }
                    
                    let data = try await loadContent(for: url)
                    return .data(data)
                }
                
                // No more data
                return nil
            }
            
            /// Get content info for the URL
            private func contentInfo(for url: URL) async throws -> (mimeType: String, contentLength: Int) {
                let path = url.path
                
                switch path {
                case "/welcome", "/":
                    let content = CustomSchemeHandler.welcomePageHTML
                    return ("text/html", content.count)
                    
                case "/about":
                    let content = CustomSchemeHandler.aboutPageHTML
                    return ("text/html", content.count)
                    
                case "/help":
                    let content = CustomSchemeHandler.helpPageHTML
                    return ("text/html", content.count)
                    
                case "/logo.png":
                    // For images, we'd load from bundle
                    return ("image/png", 1024) // Placeholder size
                    
                default:
                    throw URLError(.fileDoesNotExist)
                }
            }
            
            /// Load content for the URL
            private func loadContent(for url: URL) async throws -> Data {
                let path = url.path
                
                switch path {
                case "/welcome", "/":
                    return CustomSchemeHandler.welcomePageHTML.data(using: .utf8)!
                    
                case "/about":
                    return CustomSchemeHandler.aboutPageHTML.data(using: .utf8)!
                    
                case "/help":
                    return CustomSchemeHandler.helpPageHTML.data(using: .utf8)!
                    
                case "/logo.png":
                    // Load image from bundle
                    if let imageURL = Bundle.main.url(forResource: "neuve_logo", withExtension: "png"),
                       let data = try? Data(contentsOf: imageURL) {
                        return data
                    } else {
                        // Return a placeholder image
                        return CustomSchemeHandler.placeholderImageData()
                    }
                    
                default:
                    throw URLError(.fileDoesNotExist)
                }
            }
        }
        
        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(request: request)
        }
    }
    
    /// Reply to a URL request with an async sequence of responses
    public func reply(for request: URLRequest) -> TaskSequence {
        return TaskSequence(request: request)
    }
    
    // MARK: - Content Templates
    
    /// Welcome page HTML
    static let welcomePageHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Welcome to Neuve Browser</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 40px;
                background-color: #f5f5f7;
                color: #1d1d1f;
                text-align: center;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            }
            h1 {
                font-size: 48px;
                margin-bottom: 20px;
                background: linear-gradient(45deg, #007AFF, #5AC8FA);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .logo {
                width: 120px;
                height: 120px;
                margin: 0 auto 30px;
                background: linear-gradient(45deg, #007AFF, #5AC8FA);
                border-radius: 30px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 60px;
                color: white;
            }
            p {
                font-size: 18px;
                line-height: 1.6;
                color: #86868b;
                margin-bottom: 30px;
            }
            .links {
                display: flex;
                gap: 20px;
                justify-content: center;
                flex-wrap: wrap;
            }
            a {
                display: inline-block;
                padding: 12px 24px;
                background-color: #007AFF;
                color: white;
                text-decoration: none;
                border-radius: 10px;
                font-weight: 500;
                transition: all 0.3s ease;
            }
            a:hover {
                background-color: #0051D5;
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,122,255,0.3);
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo">🌐</div>
            <h1>Neuve Browser</h1>
            <p>Welcome to your modern browsing experience powered by SwiftUI and WebKit.</p>
            <p>This page is served locally using a custom URL scheme handler.</p>
            <div class="links">
                <a href="neuvebrowser://about">About</a>
                <a href="neuvebrowser://help">Help</a>
                <a href="https://www.apple.com">Browse the Web</a>
            </div>
        </div>
    </body>
    </html>
    """
    
    /// About page HTML
    static let aboutPageHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>About Neuve Browser</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 40px;
                background-color: #f5f5f7;
                color: #1d1d1f;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            }
            h1 {
                font-size: 36px;
                margin-bottom: 20px;
            }
            h2 {
                font-size: 24px;
                margin-top: 30px;
                margin-bottom: 15px;
                color: #007AFF;
            }
            p, li {
                font-size: 16px;
                line-height: 1.6;
                color: #86868b;
            }
            ul {
                padding-left: 20px;
            }
            .back-link {
                display: inline-block;
                margin-top: 30px;
                color: #007AFF;
                text-decoration: none;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>About Neuve Browser</h1>
            <p>Neuve Browser is a modern iOS browser built with SwiftUI and the latest WebKit APIs.</p>
            
            <h2>Features</h2>
            <ul>
                <li>Native SwiftUI interface</li>
                <li>Custom navigation policies</li>
                <li>Support for custom URL schemes</li>
                <li>Modern tab management</li>
                <li>Privacy-focused browsing</li>
            </ul>
            
            <h2>Technology</h2>
            <p>Built using iOS 26's WebKit for SwiftUI API, providing seamless integration between web content and native UI.</p>
            
            <a href="neuvebrowser://welcome" class="back-link">← Back to Welcome</a>
        </div>
    </body>
    </html>
    """
    
    /// Help page HTML
    static let helpPageHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Help - Neuve Browser</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 40px;
                background-color: #f5f5f7;
                color: #1d1d1f;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            }
            h1 {
                font-size: 36px;
                margin-bottom: 20px;
            }
            h2 {
                font-size: 20px;
                margin-top: 30px;
                margin-bottom: 10px;
                color: #007AFF;
            }
            p {
                font-size: 16px;
                line-height: 1.6;
                color: #86868b;
                margin-bottom: 15px;
            }
            code {
                background-color: #f5f5f7;
                padding: 2px 6px;
                border-radius: 4px;
                font-family: monospace;
                font-size: 14px;
            }
            .back-link {
                display: inline-block;
                margin-top: 30px;
                color: #007AFF;
                text-decoration: none;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Browser Help</h1>
            
            <h2>Navigation</h2>
            <p>Use the back and forward buttons to navigate through your browsing history.</p>
            
            <h2>Custom URLs</h2>
            <p>This browser supports custom <code>neuvebrowser://</code> URLs for internal pages.</p>
            
            <h2>Tab Management</h2>
            <p>Create new tabs with the + button, and switch between them in the tab view.</p>
            
            <h2>Privacy</h2>
            <p>Your browsing data is stored locally and can be cleared at any time from settings.</p>
            
            <a href="neuvebrowser://welcome" class="back-link">← Back to Welcome</a>
        </div>
    </body>
    </html>
    """
    
    /// Generate placeholder image data
    static func placeholderImageData() -> Data {
        // Create a simple 1x1 transparent PNG
        let pngData = Data([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,  // PNG signature
            0x00, 0x00, 0x00, 0x0D,  // IHDR chunk length
            0x49, 0x48, 0x44, 0x52,  // IHDR
            0x00, 0x00, 0x00, 0x01,  // width: 1
            0x00, 0x00, 0x00, 0x01,  // height: 1
            0x08, 0x06,              // bit depth: 8, color type: 6 (RGBA)
            0x00, 0x00, 0x00,        // compression, filter, interlace
            0x1F, 0x15, 0xC4, 0x89,  // CRC
            0x00, 0x00, 0x00, 0x0A,  // IDAT chunk length
            0x49, 0x44, 0x41, 0x54,  // IDAT
            0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01,  // compressed data
            0xE5, 0x27, 0xDE, 0xFC,  // CRC
            0x00, 0x00, 0x00, 0x00,  // IEND chunk length
            0x49, 0x45, 0x4E, 0x44,  // IEND
            0xAE, 0x42, 0x60, 0x82   // CRC
        ])
        return pngData
    }
}