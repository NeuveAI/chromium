import SwiftUI

struct MemoriesView: View {
    @ObservedObject var framework: NeuveUIFramework
    @State private var selectedFilter: MemoryFilter = .all
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search bar
                    searchBarView
                    
                    // Filter tabs
                    filterTabsView
                    
                    // Memories content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMemories) { memory in
                                MemoryCardView(memory: memory)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Memories")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(sampleMemories.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var searchBarView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search memories...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MemoryFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        title: filter.title,
                        count: getFilterCount(filter),
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    private var filteredMemories: [MemoryItem] {
        var memories = sampleMemories
        
        if !searchText.isEmpty {
            memories = memories.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedFilter {
        case .all:
            return memories
        case .recent:
            return memories.filter { Calendar.current.isDateInToday($0.date) }
        case .bookmarks:
            return memories.filter { $0.type == .bookmark }
        case .notes:
            return memories.filter { $0.type == .note }
        case .collections:
            return memories.filter { $0.type == .collection }
        }
    }
    
    private func getFilterCount(_ filter: MemoryFilter) -> Int {
        switch filter {
        case .all:
            return sampleMemories.count
        case .recent:
            return sampleMemories.filter { Calendar.current.isDateInToday($0.date) }.count
        case .bookmarks:
            return sampleMemories.filter { $0.type == .bookmark }.count
        case .notes:
            return sampleMemories.filter { $0.type == .note }.count
        case .collections:
            return sampleMemories.filter { $0.type == .collection }.count
        }
    }
}

enum MemoryFilter: CaseIterable {
    case all, recent, bookmarks, notes, collections
    
    var title: String {
        switch self {
        case .all: return "All"
        case .recent: return "Recent"
        case .bookmarks: return "Bookmarks"
        case .notes: return "Notes"
        case .collections: return "Collections"
        }
    }
}

struct FilterTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color(.systemGray4))
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(20)
        }
    }
}

struct MemoryCardView: View {
    let memory: MemoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Type icon
                Image(systemName: memory.type.icon)
                    .foregroundColor(memory.type.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(memory.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(memory.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(memory.date, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !memory.description.isEmpty {
                Text(memory.description)
                    .font(.body)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            // Tags
            if !memory.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(memory.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Data models
enum MemoryType {
    case bookmark, note, collection, webpage
    
    var icon: String {
        switch self {
        case .bookmark: return "bookmark.fill"
        case .note: return "note.text"
        case .collection: return "folder.fill"
        case .webpage: return "safari.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bookmark: return .blue
        case .note: return .orange
        case .collection: return .purple
        case .webpage: return .green
        }
    }
}

struct MemoryItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let type: MemoryType
    let date: Date
    let tags: [String]
}

// Sample data
private let sampleMemories: [MemoryItem] = [
    MemoryItem(
        title: "Swift UI Tutorial",
        subtitle: "developer.apple.com",
        description: "Comprehensive guide to building iOS apps with SwiftUI and modern development practices.",
        type: .bookmark,
        date: Date().addingTimeInterval(-3600), // 1 hour ago
        tags: ["iOS", "Swift", "Tutorial"]
    ),
    MemoryItem(
        title: "Project Ideas",
        subtitle: "Personal Notes",
        description: "Collection of app ideas including AR shopping assistant, voice-controlled home automation, and AI-powered study companion.",
        type: .note,
        date: Date().addingTimeInterval(-7200), // 2 hours ago
        tags: ["Ideas", "Projects", "Innovation"]
    ),
    MemoryItem(
        title: "Design Resources",
        subtitle: "8 bookmarks",
        description: "Curated collection of design inspiration, UI patterns, and prototyping tools for mobile app development.",
        type: .collection,
        date: Date().addingTimeInterval(-86400), // 1 day ago
        tags: ["Design", "UI/UX", "Resources"]
    ),
    MemoryItem(
        title: "GitHub Repository",
        subtitle: "github.com",
        description: "Open source iOS browser project with advanced features and modern architecture patterns.",
        type: .webpage,
        date: Date().addingTimeInterval(-172800), // 2 days ago
        tags: ["GitHub", "Open Source", "iOS"]
    ),
    MemoryItem(
        title: "Meeting Notes",
        subtitle: "Work Documents",
        description: "Discussion about new browser features, user feedback analysis, and roadmap planning for Q2.",
        type: .note,
        date: Date().addingTimeInterval(-259200), // 3 days ago
        tags: ["Work", "Planning", "Features"]
    )
]