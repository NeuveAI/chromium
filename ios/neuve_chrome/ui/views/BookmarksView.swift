import SwiftUI

struct MemoriesView: View {
    @ObservedObject var framework: NeuveUIFramework
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Memories")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add new memory action
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Memory grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // Sample memories
                        MemoryCard(
                            title: "Research Session",
                            subtitle: "AI & Machine Learning",
                            color: .blue,
                            icon: "brain.head.profile"
                        )
                        
                        MemoryCard(
                            title: "Development Notes",
                            subtitle: "SwiftUI Best Practices",
                            color: .green,
                            icon: "swift"
                        )
                        
                        MemoryCard(
                            title: "Design Inspiration",
                            subtitle: "UI/UX Patterns",
                            color: .purple,
                            icon: "paintbrush"
                        )
                        
                        MemoryCard(
                            title: "Learning Path",
                            subtitle: "iOS Architecture",
                            color: .orange,
                            icon: "book"
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct MemoryCard: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon area
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.2))
                .frame(height: 100)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(color)
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            // Handle memory tap
        }
    }
}