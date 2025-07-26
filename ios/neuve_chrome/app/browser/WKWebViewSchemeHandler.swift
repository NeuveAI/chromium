import Foundation
import WebKit

/// WKURLSchemeHandler implementation for custom neuvebrowser:// URLs
public class WKWebViewSchemeHandler: NSObject, WKURLSchemeHandler {
    /// The custom scheme this handler manages
    public static let scheme = "neuvebrowser"
    
    /// Handle the start of a URL scheme task
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }
        
        // Get content for the URL
        let (data, response, error) = loadContent(for: url)
        
        if let error = error {
            urlSchemeTask.didFailWithError(error)
            return
        }
        
        if let response = response {
            urlSchemeTask.didReceive(response)
        }
        
        if let data = data {
            urlSchemeTask.didReceive(data)
        }
        
        urlSchemeTask.didFinish()
    }
    
    /// Handle the stop of a URL scheme task
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Task was cancelled, nothing to do
    }
    
    /// Load content for the given URL
    private func loadContent(for url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        let path = url.path
        
        let htmlContent: String
        let mimeType = "text/html"
        
        switch path {
        case "/welcome", "/", "":
            htmlContent = CustomSchemeHandler.welcomePageHTML
            
        case "/about":
            htmlContent = CustomSchemeHandler.aboutPageHTML
            
        case "/help":
            htmlContent = CustomSchemeHandler.helpPageHTML
            
        case "/logo.png":
            // For images, return PNG data
            let data = CustomSchemeHandler.placeholderImageData()
            let response = URLResponse(
                url: url,
                mimeType: "image/png",
                expectedContentLength: data.count,
                textEncodingName: nil
            )
            return (data, response, nil)
            
        default:
            return (nil, nil, URLError(.fileDoesNotExist))
        }
        
        // Convert HTML to data
        guard let data = htmlContent.data(using: .utf8) else {
            return (nil, nil, URLError(.cannotDecodeContentData))
        }
        
        // Create response
        let response = URLResponse(
            url: url,
            mimeType: mimeType,
            expectedContentLength: data.count,
            textEncodingName: "utf-8"
        )
        
        return (data, response, nil)
    }
}