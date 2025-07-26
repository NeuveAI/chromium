import SwiftUI
import WebKit

struct WebTabsView: View {
    @ObservedObject var framework: NeuveUIFramework
    @State private var showingNewTabSheet = false
    @State private var showingTabGrid = true
    
    var body: some View {
        ZStack {
            if showingTabGrid || framework.webTabs.isEmpty {
                // Tab Grid View
                NavigationView {
                    VStack {
                        // Header
                        HStack {
                            Text("Tabs")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                showingNewTabSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Tab Grid
                        if framework.webTabs.isEmpty {
                            // Empty state
                            VStack(spacing: 20) {
                                Image(systemName: "square.on.square")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No open tabs")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Button("Open New Tab") {
                                    showingNewTabSheet = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Tab grid
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(Array(framework.webTabs.enumerated()), id: \.element.id) { index, tab in
                                        TabCard(
                                            tab: tab,
                                            isActive: index == framework.activeTabIndex,
                                            onTap: {
                                                framework.switchToTab(at: index)
                                                showingTabGrid = false
                                            },
                                            onClose: {
                                                framework.closeTab(at: index)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                    .navigationBarHidden(true)
                }
            } else {
                // Web Content View
                if let activeTab = framework.webTabs.first(where: { $0.isActive }) {
                    VStack(spacing: 0) {
                        // Web navigation toolbar
                        webNavigationToolbar
                        
                        // Web content - simple placeholder for now
                        VStack {
                            Text("Web Content: \(activeTab.title)")
                                .font(.title2)
                            Text("URL: \(activeTab.url.absoluteString)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.1))
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .sheet(isPresented: $showingNewTabSheet) {
            NewTabSheet(framework: framework) {
                // Switch to web content view after tab creation
                showingTabGrid = false
            }
        }
    }
    
    private var webNavigationToolbar: some View {
        HStack {
            // Back to tabs button
            Button(action: {
                showingTabGrid = true
            }) {
                Image(systemName: "square.on.square")
                    .font(.title2)
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                Button(action: {
                    framework.goBack(inTabAt: framework.activeTabIndex)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .disabled(!canGoBack)
                
                Button(action: {
                    framework.goForward(inTabAt: framework.activeTabIndex)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                .disabled(!canGoForward)
                
                Button(action: {
                    framework.reload(tabAt: framework.activeTabIndex)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
            }
            
            Spacer()
            
            // New tab button
            Button(action: {
                showingNewTabSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
    
    private var canGoBack: Bool {
        guard framework.activeTabIndex < framework.webTabs.count else { return false }
        // This would need to be updated from the WebStateBridge
        return false // Placeholder
    }
    
    private var canGoForward: Bool {
        guard framework.activeTabIndex < framework.webTabs.count else { return false }
        // This would need to be updated from the WebStateBridge
        return false // Placeholder
    }
}

struct TabCard: View {
    let tab: WebTab
    let isActive: Bool
    let onTap: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Tab preview (placeholder)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "globe")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text(tab.url.host ?? "New Tab")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
                .overlay(
                    // Close button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onClose) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .background(Color.white.clipShape(Circle()))
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                )
            
            // Tab title
            Text(tab.title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .foregroundColor(isActive ? .blue : .primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct NewTabSheet: View {
    @ObservedObject var framework: NeuveUIFramework
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""
    @FocusState private var isTextFieldFocused: Bool
    let onTabCreated: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // URL input
                TextField("Enter URL or search", text: $urlText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .onSubmit {
                        createNewTab()
                    }
                
                Spacer()
            }
            .navigationTitle("New Tab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Go") {
                        createNewTab()
                    }
                    .disabled(urlText.isEmpty)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func createNewTab() {
        let url: URL
        if urlText.contains(".") && !urlText.contains(" ") {
            // Looks like a URL
            if urlText.hasPrefix("http://") || urlText.hasPrefix("https://") {
                url = URL(string: urlText) ?? URL(string: "https://www.google.com/search?q=\(urlText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            } else {
                url = URL(string: "https://\(urlText)") ?? URL(string: "https://www.google.com/search?q=\(urlText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            }
        } else {
            // Treat as search query
            url = URL(string: "https://www.google.com/search?q=\(urlText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        }
        
        framework.createNewTab(url: url)
        dismiss()
        onTabCreated()
    }
}