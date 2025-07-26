# Chromium UI Architecture Guide

## Overview

This guide explains how UI components are organized in Chromium and provides instructions for creating a new iOS client with modern UI frameworks while maintaining the same capabilities as the current iOS client.

## Current Architecture

### iOS Client Structure

The iOS Chromium client is organized into several key directories:

```
ios/
├── chrome/                     # Main iOS Chrome application
│   ├── browser/               # Browser logic and services
│   │   ├── ui/               # UI components and controllers
│   │   │   ├── authentication/
│   │   │   ├── bookmarks/
│   │   │   ├── content_suggestions/
│   │   │   ├── history/
│   │   │   ├── new_tab_page/  # Current new tab page implementation
│   │   │   ├── omnibox/       # Address bar/search
│   │   │   ├── settings/
│   │   │   ├── tab_switcher/  # Tab management
│   │   │   ├── tabs/          # Tab grid and management
│   │   │   └── toolbar/       # Navigation toolbar
│   │   ├── net/              # iOS-specific networking
│   │   ├── sessions/         # Session management
│   │   └── tabs/             # Tab model and state
│   ├── app/                  # App lifecycle and main entry points
│   └── common/               # Shared iOS utilities
├── web/                      # iOS WebKit integration layer
│   ├── public/               # Public APIs for web content
│   ├── web_state/            # Web page state management
│   └── navigation/           # Navigation and URL handling
└── build/                    # iOS-specific build configuration
```

### Desktop Client Structure

Desktop clients (Windows, macOS, Linux) are organized differently:

```
chrome/
├── browser/
│   ├── ui/
│   │   ├── views/            # Views framework (Windows/Linux)
│   │   ├── cocoa/            # Cocoa framework (macOS)
│   │   ├── browser_dialogs/  # Common dialogs
│   │   ├── omnibox/          # Address bar
│   │   ├── tabs/             # Tab strip
│   │   └── toolbar/          # Browser toolbar
│   └── renderer_host/        # Communication with renderer
├── renderer/                 # Rendering process
└── common/                   # Shared code
```

## Key Services and Components

### Core Browser Services

1. **Tab Management** (`ios/chrome/browser/tabs/`)
   - Tab model and state
   - Tab switching logic
   - Session restoration

2. **Web State Management** (`ios/web/web_state/`)
   - WebKit integration
   - Page lifecycle
   - Navigation handling

3. **Networking** (`ios/chrome/browser/net/`)
   - HTTP stack
   - Cookie management
   - Certificate handling

4. **Bookmarks** (`ios/chrome/browser/bookmarks/`)
   - Bookmark storage
   - Sync integration
   - Import/export

5. **History** (`ios/chrome/browser/history/`)
   - Browsing history
   - Search and filtering
   - Privacy controls

6. **Settings** (`ios/chrome/browser/prefs/`)
   - User preferences
   - Privacy settings
   - Sync configuration

### UI Framework Integration Points

Current iOS UI uses a mix of:
- **UIKit** (Objective-C/Swift)
- **SwiftUI** (modern declarative UI)
- **WebKit** (web content rendering)

## Creating a New iOS Client

### Approach 1: New Target (Recommended)

Create a completely new iOS app target that reuses core Chromium services:

#### 1. Create New App Target

```gn
# ios/neuve_chrome/BUILD.gn
ios_app_bundle("neuve_chrome") {
  info_plist = "Info.plist"
  bundle_identifier = "org.chromium.neuve-chrome"
  
  deps = [
    ":neuve_chrome_main",
    "//ios/chrome/browser",  # Reuse browser services
    "//ios/web",             # Reuse web integration
  ]
}

source_set("neuve_chrome_main") {
  sources = [
    "main.mm",
    "app_delegate.swift",
    "scene_delegate.swift",
  ]
  
  deps = [
    ":ui_framework",
    "//ios/chrome/browser/tabs",
    "//ios/chrome/browser/bookmarks", 
    "//ios/chrome/browser/history",
    # Add other required services
  ]
}
```

#### 2. Create UI Framework

This is some early sketch of how the framework would go in order to wrap some parts of the browser code seen on chromium iOS source

```swift
// ios/neuve_chrome/ui/NeuveUIFramework.swift

import SwiftUI
import WebKit

// Core UI Framework
@MainActor
class NeuveUIFramework: ObservableObject {
    // Service Dependencies
    private let tabModel: TabModel
    private let bookmarkService: BookmarkService
    private let historyService: HistoryService
    
    // UI State
    @Published var selectedTab: TabType = .home
    @Published var webTabs: [WebTab] = []
    @Published var activeTabIndex: Int = 0
    
    init(
        tabModel: TabModel,
        bookmarkService: BookmarkService,
        historyService: HistoryService
    ) {
        self.tabModel = tabModel
        self.bookmarkService = bookmarkService
        self.historyService = historyService
    }
}

// Main App View
struct NeuveChromeBrowserView: View {
    @StateObject private var framework: NeuveUIFramework
    
    var body: some View {
        TabView(selection: $framework.selectedTab) {
            HomeView(framework: framework)
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
                
            // Additional tabs...
        }
    }
}
```
#### 2.2 Base UI component example (early mock without using the UI framework)

These are early mocks created to prototype the desired UI in SwiftUI

```swift
import SwiftUI
import WebKit

struct NeuveBrowserView: View {
    @State private var selectedTab: Tabs = .home
    @State private var userInput: String = ""
    @State private var isVoiceInputActive = false
    @State private var webTabs: [WebTab] = []
    @State private var activeWebTabIndex: Int = 0
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
    
            VStack {
                Spacer()
                TabView(selection: $selectedTab) {
                    
                    Tab("Home", systemImage: "house", value: .home) {
                        StartPageView()
                    }
                    
                    Tab("Tabs", systemImage: "square.on.square", value: .tabs) {
                        // add tabs
                        Color.blue.ignoresSafeArea(edges: .all)
                    }
                    .badge(webTabs.count)
                    
                    Tab("Memories", systemImage: "sparkles", value: .memories) {
                        // Add Agent memory management
                        Color.red.ignoresSafeArea(edges: .all)
                    }
                    
                    Tab("toggle-input", systemImage: "mic", value: .commit, role: .search) {
                        // Add input handling for search / URL entry
                    }
                }
            }
            
        }.ignoresSafeArea(edges: .all)
    }

    // Add support methods
}

struct StartPageView: View {
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
                    
                    Spacer(minLength: 120) // Increased to account for bottom nav
                    
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
            // Left icon (appears to be a browser/app icon)
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
            
            // Personal bookmarks (collapsed in image, showing icons)
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
                
                // Text content with bottom-aligned URL
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
                .frame(height: 50) // Fixed height for text area to ensure consistent URL positioning
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
                    .frame(width: 110)
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

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            // Home button
            NavBarButton(
                icon: "house.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            Spacer()
            
            // Bookmarks/Favorites button
            NavBarButton(
                icon: "star.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            Spacer()
            
            // Crossed out circle (disable/block button)
            NavBarButton(
                icon: "circle.slash",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            Spacer()
            
            // Plus/Add button
            NavBarButton(
                icon: "plus",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 34) // Account for home indicator
    }
}

struct NavBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(width: 44, height: 44)
                .background(
                    isSelected ?
                    Circle().fill(Color(.systemGray5)) :
                        Circle().fill(Color.clear)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NeuveBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        NeuveBrowserView()
            .preferredColorScheme(.light)
    }
}

```

#### 3. Service Bridges

Create Swift wrappers for C++ Chromium services:

```swift
// ios/neuve_chrome/services/TabModelBridge.swift

import Foundation

@objc protocol TabModelBridge {
    func createNewTab(url: URL)
    func closeTab(at index: Int)
    func switchToTab(at index: Int)
    var tabCount: Int { get }
}

// Implementation bridges to C++ TabModel
class TabModelBridgeImpl: NSObject, TabModelBridge {
    private let cppTabModel: ObjCBridgedTabModel
    
    init(tabModel: ObjCBridgedTabModel) {
        self.cppTabModel = tabModel
    }
    
    func createNewTab(url: URL) {
        cppTabModel.insertWebState(with: url)
    }
    
    // ... other implementations
}
```

### Approach 2: Replace Existing UI

Replace existing UI components incrementally:

#### Key Files to Modify:

1. **Main App Entry Point**
   ```
   ios/chrome/app/main_application_delegate.mm
   ios/chrome/app/application_delegate/app_state.mm
   ```

2. **Browser View Controller**
   ```
   ios/chrome/browser/ui/browser_view/browser_view_controller.mm
   ios/chrome/browser/ui/browser_view/browser_coordinator.mm
   ```

3. **Tab Grid**
   ```
   ios/chrome/browser/ui/tab_switcher/tab_grid/
   ```

4. **New Tab Page**
   ```
   ios/chrome/browser/ui/content_suggestions/
   ios/chrome/browser/ui/new_tab_page_omnibox/
   ```

## Directory Structure for New Client

```
ios/neuve_chrome/                    # New app target
├── BUILD.gn                       # Build configuration
├── Info.plist                     # App metadata
├── main.mm                        # App entry point
├── app/                          # App lifecycle
│   ├── app_delegate.swift
│   ├── scene_delegate.swift
│   └── coordinator.swift
├── ui/                           # UI Framework
│   ├── framework/
│   │   ├── NeuveUIFramework.swift # Main UI coordinator
│   │   ├── TabManagement.swift   # Tab state management
│   │   └── ServiceBridges.swift  # C++ service bridges
│   ├── views/
│   │   ├── HomeView.swift        # Home/start page
│   │   ├── WebTabsView.swift     # Browser tabs
│   │   ├── BookmarksView.swift   # Bookmarks management
│   │   └── SettingsView.swift    # Settings UI
│   └── components/               # Reusable UI components
│       ├── InputBar.swift
│       ├── TabCard.swift
│       └── WebView.swift
├── services/                     # Service layer
│   ├── TabModelBridge.swift      # Tab management bridge
│   ├── BookmarkBridge.swift      # Bookmark service bridge
│   ├── HistoryBridge.swift       # History service bridge
│   └── NetworkBridge.swift       # Network service bridge
└── resources/                    # Assets and resources
    ├── Assets.xcassets
    └── Localizable.strings
```

## Required Service Integrations

### 1. Tab Management
- **Service**: `TabModel` (`ios/chrome/browser/tabs/tab_model.h`)
- **Wrapper**: Create Swift bridge for tab operations
- **UI Integration**: Connect to SwiftUI tab state

### 2. Web Content Rendering  
- **Service**: `WebState` (`ios/web/public/web_state.h`)
- **Wrapper**: SwiftUI `UIViewRepresentable` for `WKWebView`
- **UI Integration**: Embed in tab views

### 3. Navigation and URL Handling
- **Service**: `NavigationManager` (`ios/web/public/navigation/navigation_manager.h`)
- **Wrapper**: Swift navigation coordinator
- **UI Integration**: Connect to address bar and navigation

### 4. Bookmarks
- **Service**: `BookmarkModel` (`components/bookmarks/browser/bookmark_model.h`)
- **Wrapper**: Swift bookmark manager
- **UI Integration**: Bookmark views and management

### 5. History
- **Service**: `HistoryService` (`components/history/core/browser/history_service.h`)
- **Wrapper**: Swift history bridge
- **UI Integration**: History views and search

### 6. Settings and Preferences
- **Service**: `PrefService` (`components/prefs/pref_service.h`)
- **Wrapper**: Swift settings manager
- **UI Integration**: Settings screens

## Build Configuration

### GN Build File Example

```gn
# ios/neuve_chrome/BUILD.gn

import("//build/config/ios/ios_sdk.gni")
import("//build/config/ios/rules.gni")

ios_app_bundle("neuve_chrome") {
  info_plist = "Info.plist"
  bundle_identifier = "org.chromium.neuve-chrome"
  
  deps = [ ":neuve_chrome_main" ]
  
  frameworks = [
    "UIKit.framework",
    "SwiftUI.framework", 
    "WebKit.framework",
    "Foundation.framework",
  ]
}

source_set("neuve_chrome_main") {
  sources = [
    "main.mm",
    "app/app_delegate.swift",
    "app/scene_delegate.swift",
    # Add all Swift sources
  ]
  
  deps = [
    "//ios/chrome/browser",
    "//ios/chrome/browser/tabs",
    "//ios/chrome/browser/bookmarks",
    "//ios/chrome/browser/history",
    "//ios/web",
    "//components/bookmarks/browser",
    "//components/history/core/browser",
    # Add other required dependencies
  ]
  
  frameworks = [
    "UIKit.framework",
    "SwiftUI.framework",
    "WebKit.framework",
  ]
}
```

## Swift UI key observations

We are plannign to build around iOS 26 and ther are new apis for WebViews and WebPage:
https://developer.apple.com/documentation/webkit/webview-swift.struct
https://developer.apple.com/documentation/webkit/webpage

Those are meant to facilitate our code whist using SwiftUI, since iOS uses webkit under the hood as rendering engine.

We don't have to support a custom rendering engine, but we want to support the devtools protocol and other frameworks around the iOS code for chrome found here

## Development Steps

### Phase 1: Foundation
1. Create new iOS app target (`neuve_chrome`)
2. Set up basic SwiftUI app structure
3. Create service bridge interfaces
4. Implement basic tab management

### Phase 2: Core Features  
1. Integrate WebKit for web content
2. Implement URL/search input handling
3. Add bookmark management
4. Add history tracking

### Phase 3: Advanced Features
1. Settings and preferences

2. Sync integration
3. Extensions support
4. Advanced tab features

### Phase 4: Polish
1. Animations and transitions
2. Accessibility
3. Performance optimization
4. Testing and debugging

## Testing Strategy

### Unit Tests
```swift
// ios/neuve_chrome/tests/TabModelBridgeTest.swift
import XCTest
@testable import NeuveChrome

class TabModelBridgeTest: XCTestCase {
    func testCreateNewTab() {
        let bridge = TabModelBridge()
        let initialCount = bridge.tabCount
        
        bridge.createNewTab(url: URL(string: "https://example.com")!)
        
        XCTAssertEqual(bridge.tabCount, initialCount + 1)
    }
}
```

### Integration Tests
Test SwiftUI views with mock services to ensure proper integration.

### UI Tests
Use XCUITest framework to test complete user workflows.

## Key Considerations

1. **Memory Management**: Proper cleanup of C++ objects in Swift bridges
2. **Threading**: Ensure UI updates happen on main thread
3. **Performance**: Minimize bridge overhead between Swift and C++
4. **Compatibility**: Maintain compatibility with existing Chromium services
5. **Testing**: Comprehensive test coverage for service bridges

## Resources

- [Chromium iOS Build Instructions](docs/ios/build_instructions.md)
- [iOS Development Documentation](docs/ios/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WebKit Documentation](https://developer.apple.com/documentation/webkit)

## Getting Started

1. **Choose your approach**: New target (recommended) or incremental replacement
2. **Set up build configuration**: Create BUILD.gn files for your new target
3. **Create service bridges**: Start with tab management and web content
4. **Build UI framework**: Create SwiftUI views that use the service bridges
5. **Test incrementally**: Build and test each component as you develop

This architecture allows you to create a modern, SwiftUI-based iOS client while leveraging all of Chromium's powerful browser services and maintaining compatibility with the existing codebase.
