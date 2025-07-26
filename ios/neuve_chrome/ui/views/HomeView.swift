import SwiftUI

struct HomeView: View {
    @ObservedObject var framework: NeuveUIFramework
    @State private var searchText = ""
    
    var body: some View {
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
        .padding(.vertical, 20)
    }
    
    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .font(.title3)
                
                Text("Recents")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("All") {
                    // Handle see all
                }
                .foregroundColor(.blue)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Recent items grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                RecentItemCard(
                    title: "Ultimate tool for the future of app development",
                    url: "codemancer.co",
                    color: .white
                )
                
                RecentItemCard(
                    title: "Explore and Ethereum in",
                    url: "family.co",
                    color: .yellow,
                    isColorful: true
                )
            }
        }
        .padding(.bottom, 32)
    }
    
    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
                    .font(.title3)
                
                Text("Personal")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Personal bookmarks
            HStack(spacing: 20) {
                PersonalBookmarkIcon(color: .red, icon: "bookmark.fill", label: "Bookmarks")
                PersonalBookmarkIcon(color: .orange, icon: "folder.fill", label: "Downloads")
                Spacer()
            }
        }
        .padding(.bottom, 32)
    }
    
    private var easelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.secondary)
                    .font(.title3)
                
                Text("Easels & Notes")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                EaselCard()
                AddEaselCard()
                Spacer()
            }
        }
    }
    
    private var bottomHintView: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.down")
                .foregroundColor(.secondary)
                .font(.title3)
            
            VStack(spacing: 4) {
                Text("Swipe down to")
                    .foregroundColor(.secondary)
                Text("Search or Enter URL")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.top, 40)
    }
}

// Supporting Views
struct RecentItemCard: View {
    let title: String
    let url: String
    let color: Color
    var isColorful: Bool = false
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                // Preview area
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isColorful ?
                        AnyShapeStyle(LinearGradient(colors: [.yellow, .orange, .red, .blue, .green],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing)) :
                            AnyShapeStyle(color)
                    )
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 4)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text(url)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(height: 50)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PersonalBookmarkIcon: View {
    let color: Color
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.title3)
                )
        }
    }
}

struct EaselCard: View {
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                // Chart preview area
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 120, height: 80)
                    .overlay(
                        // Simple pie chart representation
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.pink, lineWidth: 6)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 35, height: 35)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 3) {
                    Text("Guests list")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("for Iris'")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("birthday")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddEaselCard: View {
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 110, height: 80)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}