import Foundation

// Swift wrapper for the Objective-C++ TabModelBridge
class TabModelManager: ObservableObject {
    private let bridge: TabModelBridgeImpl
    
    @Published var tabs: [WebTab] = []
    @Published var activeTabIndex: Int = 0
    
    init() {
        self.bridge = TabModelBridgeImpl()
        updateTabs()
    }
    
    func createNewTab(url: URL) {
        bridge.createNewTab(with: url)
        updateTabs()
    }
    
    func closeTab(at index: Int) {
        bridge.closeTab(at: index)
        if activeTabIndex >= bridge.tabCount {
            activeTabIndex = max(0, Int(bridge.tabCount) - 1)
        }
        updateTabs()
    }
    
    func switchToTab(at index: Int) {
        if index >= 0 && index < bridge.tabCount {
            activeTabIndex = index
            bridge.switchToTab(at: index)
        }
    }
    
    // Allow external update of tabs (for WebState bridge integration)
    func updateTabs(_ newTabs: [WebTab]) {
        tabs = newTabs
        updateActiveStates()
    }
    
    private func updateTabs() {
        tabs = bridge.tabs.map { tabInfo in
            WebTab(
                title: tabInfo.title,
                url: tabInfo.url,
                isActive: false
            )
        }
        updateActiveStates()
    }
    
    private func updateActiveStates() {
        // Update active state
        for i in 0..<tabs.count {
            tabs[i] = WebTab(
                title: tabs[i].title,
                url: tabs[i].url,
                isActive: i == activeTabIndex
            )
        }
    }
}