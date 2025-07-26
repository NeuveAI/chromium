import SwiftUI

struct SearchView: View {
    @ObservedObject var framework: NeuveUIFramework
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                // Search header
                VStack(spacing: 16) {
                    Text("Search or Enter URL")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    // Search input
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search the web or enter URL", text: $framework.searchText)
                            .focused($isSearchFocused)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !framework.searchText.isEmpty {
                            Button(action: {
                                framework.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            framework.isVoiceInputActive.toggle()
                        }) {
                            Image(systemName: framework.isVoiceInputActive ? "mic.fill" : "mic")
                                .foregroundColor(framework.isVoiceInputActive ? .red : .blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }
                
                // Quick suggestions
                if framework.searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Popular searches
                            SectionHeader(title: "Popular", icon: "flame")
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                QuickSearchCard(title: "Weather", icon: "cloud.sun", color: .blue)
                                QuickSearchCard(title: "News", icon: "newspaper", color: .red)
                                QuickSearchCard(title: "Maps", icon: "map", color: .green)
                                QuickSearchCard(title: "Translate", icon: "translate", color: .orange)
                            }
                            .padding(.horizontal)
                            
                            // Recent searches
                            SectionHeader(title: "Recent", icon: "clock")
                            
                            VStack(spacing: 8) {
                                RecentSearchItem(text: "SwiftUI navigation")
                                RecentSearchItem(text: "iOS development tutorials")
                                RecentSearchItem(text: "WebKit integration")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                } else {
                    // Search suggestions
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(searchSuggestions, id: \.self) { suggestion in
                                SearchSuggestionRow(suggestion: suggestion) {
                                    framework.searchText = suggestion
                                    performSearch()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private var searchSuggestions: [String] {
        if framework.searchText.isEmpty {
            return []
        }
        
        let suggestions = [
            "\(framework.searchText) tutorial",
            "\(framework.searchText) documentation",
            "\(framework.searchText) examples",
            "\(framework.searchText) best practices"
        ]
        
        return suggestions.filter { $0.lowercased().contains(framework.searchText.lowercased()) }
    }
    
    private func performSearch() {
        guard !framework.searchText.isEmpty else { return }
        
        let url: URL
        if framework.searchText.contains(".") && !framework.searchText.contains(" ") {
            // Treat as URL
            if framework.searchText.hasPrefix("http://") || framework.searchText.hasPrefix("https://") {
                url = URL(string: framework.searchText) ?? URL(string: "https://www.google.com/search?q=\(framework.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            } else {
                url = URL(string: "https://\(framework.searchText)") ?? URL(string: "https://www.google.com/search?q=\(framework.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            }
        } else {
            // Treat as search
            url = URL(string: "https://www.google.com/search?q=\(framework.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        }
        
        framework.createNewTab(url: url)
        framework.selectedTab = .home
        framework.searchText = ""
        isSearchFocused = false
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct QuickSearchCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle quick search
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentSearchItem: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                // Remove from recent
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            // Select recent search
        }
    }
}

struct SearchSuggestionRow: View {
    let suggestion: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(suggestion)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}