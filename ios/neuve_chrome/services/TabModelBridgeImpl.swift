import Foundation

// Temporary tab info structure for bridge communication
struct TabInfo {
    let title: String
    let url: URL
}

// Simple implementation of TabModelBridgeImpl for testing
// This will be replaced with proper Objective-C++ bridge later
class TabModelBridgeImpl {
    private var internalTabs: [TabInfo] = []
    private var currentActiveIndex: Int = 0
    
    init() {
        // Start with a default tab
        internalTabs.append(TabInfo(title: "New Tab", url: URL(string: "about:blank")!))
    }
    
    var tabs: [TabInfo] {
        return internalTabs
    }
    
    var tabCount: Int {
        return internalTabs.count
    }
    
    func createNewTab(with url: URL) {
        let title = url.host ?? "New Tab"
        internalTabs.append(TabInfo(title: title, url: url))
        currentActiveIndex = internalTabs.count - 1
    }
    
    func closeTab(at index: Int) {
        guard index >= 0 && index < internalTabs.count else { return }
        internalTabs.remove(at: index)
        
        if internalTabs.isEmpty {
            // Always keep at least one tab
            internalTabs.append(TabInfo(title: "New Tab", url: URL(string: "about:blank")!))
            currentActiveIndex = 0
        } else if currentActiveIndex >= internalTabs.count {
            currentActiveIndex = internalTabs.count - 1
        }
    }
    
    func switchToTab(at index: Int) {
        guard index >= 0 && index < internalTabs.count else { return }
        currentActiveIndex = index
    }
}