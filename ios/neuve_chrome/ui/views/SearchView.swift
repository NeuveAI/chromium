import SwiftUI

struct SearchView: View {
    @ObservedObject var framework: NeuveUIFramework
    @State private var isListening = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Voice input button
                    voiceInputSection
                    
                    // Search suggestions
                    searchSuggestionsSection
                    
                    // Recent searches
                    recentSearchesSection
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .onTapGesture {
            isSearchFocused = false
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("Search")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 60)
            
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search or enter URL", text: $searchText)
                        .focused($isSearchFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private var voiceInputSection: some View {
        VStack(spacing: 16) {
            // Voice input button
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isListening.toggle()
                    framework.isVoiceInputActive = isListening
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isListening ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isListening ? 1.1 : 1.0)
                    
                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .animation(.spring(response: 0.3), value: isListening)
            
            Text(isListening ? "Listening..." : "Tap to speak")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isListening {
                // Voice wave animation placeholder
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 3, height: CGFloat.random(in: 10...30))
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.1),
                                value: isListening
                            )
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var searchSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !searchText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Suggestions")
                            .font(.headline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    ForEach(getSearchSuggestions(), id: \.self) { suggestion in
                        SearchSuggestionRow(
                            suggestion: suggestion,
                            searchText: searchText,
                            onTap: {
                                searchText = suggestion
                                performSearch()
                            }
                        )
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Clear") {
                    // Clear recent searches
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                ForEach(recentSearches, id: \.self) { search in
                    RecentSearchRow(
                        search: search,
                        onTap: {
                            searchText = search
                            performSearch()
                        },
                        onDelete: {
                            // Remove from recent searches
                        }
                    )
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // Create new tab with search or URL
        let url: URL
        if searchText.contains(".") && !searchText.contains(" ") {
            // Looks like a URL
            if searchText.hasPrefix("http://") || searchText.hasPrefix("https://") {
                url = URL(string: searchText) ?? URL(string: "https://www.google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            } else {
                url = URL(string: "https://\(searchText)") ?? URL(string: "https://www.google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            }
        } else {
            // Treat as search query
            url = URL(string: "https://www.google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        }
        
        framework.createNewTab(url: url)
        framework.selectedTab = .tabs // Switch to tabs to show the web content
        
        // Clear search and hide keyboard
        searchText = ""
        isSearchFocused = false
    }
    
    private func getSearchSuggestions() -> [String] {
        let suggestions = [
            "Apple Developer",
            "SwiftUI Tutorial",
            "iOS App Store",
            "GitHub",
            "Stack Overflow",
            "Developer Documentation"
        ]
        
        return suggestions.filter { $0.localizedCaseInsensitiveContains(searchText) }
                         .prefix(3)
                         .map { $0 }
    }
}

struct SearchSuggestionRow: View {
    let suggestion: String
    let searchText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.body)
                
                Text(highlightedText())
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .rotationEffect(.degrees(45))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    private func highlightedText() -> AttributedString {
        var attributedString = AttributedString(suggestion)
        
        if let range = suggestion.localizedStandardRange(of: searchText) {
            let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
            attributedString[attributedRange].foregroundColor = .blue
            attributedString[attributedRange].font = .body.bold()
        }
        
        return attributedString
    }
}

struct RecentSearchRow: View {
    let search: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
                .font(.body)
            
            Button(action: onTap) {
                HStack {
                    Text(search)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// Sample recent searches
private let recentSearches = [
    "SwiftUI navigation",
    "iOS 17 features",
    "Apple WWDC 2024",
    "GitHub repositories",
    "React vs SwiftUI"
]