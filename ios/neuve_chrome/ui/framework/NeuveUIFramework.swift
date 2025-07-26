import SwiftUI
import WebKit

// Tab Types for navigation
enum TabType: String, CaseIterable {
    case home = "home"
    case tabs = "tabs"
    case memories = "memories"
    case search = "search"
}

// Web Tab model
struct WebTab: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
    var isActive: Bool = false
}

// Core UI Framework
@MainActor
class NeuveUIFramework: ObservableObject {
    // UI State
    @Published var selectedTab: TabType = .home
    @Published var userInput: String = ""
    @Published var isVoiceInputActive: Bool = false
    
    // Tab Management
    @Published var tabManager = TabModelManager()
    
    // Chrome WebState Bridge (optional for gradual integration)
    var webStateBridge: WebStateBridge?
    
    var webTabs: [WebTab] {
        return tabManager.tabs
    }
    
    var activeTabIndex: Int {
        return tabManager.activeTabIndex
    }
    
    init() {
        // Initialize WebState bridge
        webStateBridge = WebStateBridge()
        
        // Tab manager is initialized with default tab
        updateTabsFromBridge()
    }
    
    // Update tabs from Chrome WebState bridge
    private func updateTabsFromBridge() {
        guard let bridge = webStateBridge else { return }
        
        let bridgeTabs = bridge.getAllTabs()!
        let updatedTabs = bridgeTabs.map { tabInfo in
            WebTab(
                title: tabInfo.title,
                url: tabInfo.url,
                isActive: false
            )
        }
        
        tabManager.updateTabs(updatedTabs)
        tabManager.activeTabIndex = Int(bridge.getActiveTabIndex())
    }
    
    // Tab Management
    func createNewTab(url: URL) {
        if let bridge = webStateBridge {
            bridge.createNewTab(with: url)
            updateTabsFromBridge()
        } else {
            tabManager.createNewTab(url: url)
        }
    }
    
    func closeTab(at index: Int) {
        if let bridge = webStateBridge {
            bridge.closeTab(at: index)
            updateTabsFromBridge()
        } else {
            tabManager.closeTab(at: index)
        }
    }
    
    func switchToTab(at index: Int) {
        if let bridge = webStateBridge {
            bridge.switchToTab(at: index)
            updateTabsFromBridge()
        } else {
            tabManager.switchToTab(at: index)
        }
    }
    
    // Navigation methods
    func loadURL(_ url: URL, inTabAt index: Int) {
        webStateBridge?.load(url, inTabAt: index)
        updateTabsFromBridge()
    }
    
    func goBack(inTabAt index: Int) {
        webStateBridge?.goBackInTab(at: index)
        updateTabsFromBridge()
    }
    
    func goForward(inTabAt index: Int) {
        webStateBridge?.goForwardInTab(at: index)
        updateTabsFromBridge()
    }
    
    func reload(tabAt index: Int) {
        webStateBridge?.reloadTab(at: index)
        updateTabsFromBridge()
    }
}

// Main App View matching the architecture guide
struct NeuveChromeBrowserView: View {
    @StateObject private var framework = NeuveUIFramework()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                TabView(selection: $framework.selectedTab) {
                    
                    StartPageView()
                        .environmentObject(framework)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(TabType.home)
                    
                    WebTabsView(framework: framework)
                        .tabItem {
                            Image(systemName: "square.on.square") 
                            Text("Tabs")
                        }
                        .tag(TabType.tabs)
                        .badge(framework.webTabs.count)
                    
                    MemoriesView(framework: framework)
                        .tabItem {
                            Image(systemName: "sparkles")
                            Text("Memories")
                        }
                        .tag(TabType.memories)
                    
                    SearchView(framework: framework)
                        .tabItem {
                            Image(systemName: "mic")
                            Text("Search")
                        }
                        .tag(TabType.search)
                }
            }
        }
        .ignoresSafeArea(edges: .all)
    }
}

// StartPageView implementation from architecture guide
struct StartPageView: View {
    @State private var searchText = ""
    @EnvironmentObject var framework: NeuveUIFramework
    
    var body: some View {
        // Always show the start page content - web content should be in tabs view
        startPageContent
    }
    
    private var startPageContent: some View {
NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with profile
                    headerView
                    
                    // Recents Section
                    recentsSection
                    
                    // Personal Section (collapsed in image)
                    personalSection
                    
                    // Easels & Notes Section
                    easelsSection
                    
                    Spacer(minLength: 120) // Account for bottom nav
                    
                    // Bottom hint text
                    bottomHintView
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .all)
        }
    }
    
    private var headerView: some View {
        HStack {
            // Left icon (browser/app icon)
            Image(systemName: "safari.fill")
                .foregroundColor(.gray)
                .font(.title2)
            
            Spacer()
            
            // Profile image
            Button(action: {}) {
                AsyncImage(url: URL(string: "https://via.placeholder.com/40")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.orange)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
    
    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recents")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                ForEach(0..<4) { index in
                    recentTileView(index: index)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private func recentTileView(index: Int) -> some View {
        let titles = ["ChatGPT", "Gmail", "GitHub", "Stack Overflow"]
        let colors: [Color] = [.green, .red, .black, .orange]
        let icons = ["bubble.left.fill", "envelope.fill", "chevron.left.forwardslash.chevron.right", "questionmark.circle.fill"]
        
        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(colors[index])
                .frame(height: 80)
                .overlay(
                    Image(systemName: icons[index])
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            Text(titles[index])
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Personal")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Button("See all") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3) { index in
                        personalBookmarkView(index: index)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.bottom, 30)
    }
    
    private func personalBookmarkView(index: Int) -> some View {
        let titles = ["My Documents", "Photos", "Music"]
        let colors: [Color] = [.blue, .purple, .pink]
        let icons = ["doc.fill", "photo.fill", "music.note"]
        
        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(colors[index])
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icons[index])
                        .foregroundColor(.white)
                        .font(.title3)
                )
            
            Text(titles[index])
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
    
    private var easelsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Easels & Notes")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(0..<2) { index in
                    easelItemView(index: index)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private func easelItemView(index: Int) -> some View {
        let titles = ["Project Ideas", "Meeting Notes"]
        let subtitles = ["3 items", "5 items"]
        
        return HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "note.text")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titles[index])
                    .font(.body)
                    .fontWeight(.medium)
                Text(subtitles[index])
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
    
    private var bottomHintView: some View {
        Text("Swipe up for search or voice input")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
    }
}