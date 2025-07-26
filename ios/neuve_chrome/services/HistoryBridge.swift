import Foundation

// History entry information structure
@objc class HistoryEntry: NSObject {
    let id: String
    let url: URL
    let title: String
    let visitTime: Date
    let visitCount: Int
    let typedCount: Int
    
    init(id: String, url: URL, title: String, visitTime: Date, visitCount: Int = 1, typedCount: Int = 0) {
        self.id = id
        self.url = url
        self.title = title
        self.visitTime = visitTime
        self.visitCount = visitCount
        self.typedCount = typedCount
    }
}

// Protocol for History Management Bridge
@objc protocol HistoryBridge {
    func addHistoryEntry(url: URL, title: String)
    func getRecentHistory(limit: Int) -> [HistoryEntry]
    func searchHistory(query: String, limit: Int) -> [HistoryEntry]
    func deleteHistoryEntry(id: String) -> Bool
    func clearHistory(olderThan: Date?) -> Bool
    func getMostVisited(limit: Int) -> [HistoryEntry]
    func getHistoryForDate(_ date: Date) -> [HistoryEntry]
}

// Implementation that bridges to C++ HistoryService
class HistoryBridgeImpl: NSObject, HistoryBridge {
    // For now, we'll use a simple Swift implementation
    // In the real implementation, this would bridge to C++ HistoryService
    private var historyEntries: [HistoryEntry] = []
    private var nextId = 1
    
    override init() {
        super.init()
        initializeDefaultHistory()
    }
    
    private func initializeDefaultHistory() {
        // Create some sample history entries
        let now = Date()
        let calendar = Calendar.current
        
        let entries = [
            HistoryEntry(
                id: "hist_1",
                url: URL(string: "https://developer.apple.com/documentation/swiftui")!,
                title: "SwiftUI Documentation",
                visitTime: calendar.date(byAdding: .hour, value: -1, to: now)!,
                visitCount: 5,
                typedCount: 2
            ),
            HistoryEntry(
                id: "hist_2",
                url: URL(string: "https://github.com/chromium/chromium")!,
                title: "Chromium Source Code",
                visitTime: calendar.date(byAdding: .hour, value: -2, to: now)!,
                visitCount: 3,
                typedCount: 1
            ),
            HistoryEntry(
                id: "hist_3",
                url: URL(string: "https://webkit.org/")!,
                title: "WebKit",
                visitTime: calendar.date(byAdding: .hour, value: -3, to: now)!,
                visitCount: 2
            ),
            HistoryEntry(
                id: "hist_4",
                url: URL(string: "https://stackoverflow.com/questions/tagged/swiftui")!,
                title: "SwiftUI Questions - Stack Overflow",
                visitTime: calendar.date(byAdding: .day, value: -1, to: now)!,
                visitCount: 7,
                typedCount: 1
            ),
            HistoryEntry(
                id: "hist_5",
                url: URL(string: "https://news.ycombinator.com")!,
                title: "Hacker News",
                visitTime: calendar.date(byAdding: .day, value: -1, to: now)!,
                visitCount: 15,
                typedCount: 3
            )
        ]
        
        historyEntries = entries
    }
    
    func addHistoryEntry(url: URL, title: String) {
        // Check if entry already exists
        if let existingIndex = historyEntries.firstIndex(where: { $0.url == url }) {
            // Update existing entry
            let existing = historyEntries[existingIndex]
            let updated = HistoryEntry(
                id: existing.id,
                url: url,
                title: title,
                visitTime: Date(),
                visitCount: existing.visitCount + 1,
                typedCount: existing.typedCount
            )
            historyEntries[existingIndex] = updated
        } else {
            // Create new entry
            let newEntry = HistoryEntry(
                id: "hist_\(nextId)",
                url: url,
                title: title,
                visitTime: Date()
            )
            nextId += 1
            historyEntries.insert(newEntry, at: 0) // Insert at beginning for recent order
        }
        
        // In real implementation: cppHistoryService.addURL(url, title, visitTime)
    }
    
    func getRecentHistory(limit: Int) -> [HistoryEntry] {
        let sortedEntries = historyEntries.sorted { $0.visitTime > $1.visitTime }
        return Array(sortedEntries.prefix(limit))
        
        // In real implementation: return cppHistoryService.getRecentHistory(limit)
    }
    
    func searchHistory(query: String, limit: Int) -> [HistoryEntry] {
        let lowercaseQuery = query.lowercased()
        
        let matchingEntries = historyEntries.filter { entry in
            entry.title.lowercased().contains(lowercaseQuery) ||
            entry.url.absoluteString.lowercased().contains(lowercaseQuery)
        }
        
        // Sort by relevance (visit count) and recency
        let sortedMatches = matchingEntries.sorted { lhs, rhs in
            if lhs.visitCount != rhs.visitCount {
                return lhs.visitCount > rhs.visitCount
            }
            return lhs.visitTime > rhs.visitTime
        }
        
        return Array(sortedMatches.prefix(limit))
        
        // In real implementation: return cppHistoryService.searchHistory(query, limit)
    }
    
    func deleteHistoryEntry(id: String) -> Bool {
        if let index = historyEntries.firstIndex(where: { $0.id == id }) {
            historyEntries.remove(at: index)
            return true
        }
        return false
        
        // In real implementation: return cppHistoryService.deleteHistoryEntry(id)
    }
    
    func clearHistory(olderThan: Date?) -> Bool {
        if let cutoffDate = olderThan {
            historyEntries = historyEntries.filter { $0.visitTime > cutoffDate }
        } else {
            historyEntries.removeAll()
        }
        return true
        
        // In real implementation: return cppHistoryService.clearHistory(olderThan)
    }
    
    func getMostVisited(limit: Int) -> [HistoryEntry] {
        let sortedByVisits = historyEntries.sorted { $0.visitCount > $1.visitCount }
        return Array(sortedByVisits.prefix(limit))
        
        // In real implementation: return cppHistoryService.getMostVisited(limit)
    }
    
    func getHistoryForDate(_ date: Date) -> [HistoryEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let entriesForDate = historyEntries.filter { entry in
            entry.visitTime >= startOfDay && entry.visitTime < endOfDay
        }
        
        return entriesForDate.sorted { $0.visitTime > $1.visitTime }
        
        // In real implementation: return cppHistoryService.getHistoryForDate(date)
    }
    
    // Additional utility methods
    func getTopDomains(limit: Int) -> [(domain: String, count: Int)] {
        var domainCounts: [String: Int] = [:]
        
        for entry in historyEntries {
            if let host = entry.url.host {
                domainCounts[host, default: 0] += entry.visitCount
            }
        }
        
        let sortedDomains = domainCounts.sorted { $0.value > $1.value }
        return Array(sortedDomains.prefix(limit)).map { (domain: $0.key, count: $0.value) }
    }
    
    func getVisitCountForURL(_ url: URL) -> Int {
        return historyEntries.first { $0.url == url }?.visitCount ?? 0
    }
    
    func hasVisited(_ url: URL) -> Bool {
        return historyEntries.contains { $0.url == url }
    }
}