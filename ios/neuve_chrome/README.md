# Neuve Chrome - Modern iOS Browser

A modern iOS browser built with SwiftUI, based on the Chromium engine and following the architecture outlined in `CHROMIUM_UI_ARCHITECTURE.md`.

## Features

- **Modern SwiftUI Interface**: Built with the latest iOS design patterns and SwiftUI framework
- **Tab-based Navigation**: Clean tab bar interface with Home, Tabs, Memories, and Search sections
- **Chromium Integration**: Reuses existing Chrome browser services for tabs, bookmarks, and history
- **WebKit Integration**: Native iOS WebKit integration for optimal performance
- **Memory Management**: Smart agent memory system for browsing context

## Architecture

### Directory Structure

```
ios/neuve_chrome/
├── BUILD.gn                    # Build configuration
├── Info.plist                  # App metadata
├── main.mm                     # App entry point
├── neuve_chrome_bridge.h       # C++/Swift bridging header
├── app/                        # App lifecycle
│   ├── app_delegate.h
│   ├── app_delegate.swift
│   └── scene_delegate.swift
├── ui/                         # UI Framework
│   ├── framework/
│   │   └── NeuveUIFramework.swift  # Main UI coordinator
│   └── views/
│       ├── HomeView.swift          # Home/start page (based on NeuveBrowserView)
│       ├── WebTabsView.swift       # Browser tabs management
│       ├── BookmarksView.swift     # Memories/bookmarks view
│       └── SettingsView.swift      # Search interface
└── services/                   # Service layer bridges
    ├── TabModelBridge.swift        # Tab management bridge
    ├── BookmarkBridge.swift        # Bookmark service bridge
    └── HistoryBridge.swift         # History service bridge
```

### Key Components

#### 1. NeuveUIFramework
- Central state management for the app
- Coordinates between SwiftUI views and Chromium services
- Manages tab state, search, and navigation

#### 2. Service Bridges
- **TabModelBridge**: Interfaces with Chromium's TabModel for tab management
- **BookmarkBridge**: Connects to Chromium's BookmarkModel for bookmark operations
- **HistoryBridge**: Integrates with Chromium's HistoryService for browsing history

#### 3. SwiftUI Views
- **HomeView**: Main landing page with recents, personal bookmarks, and easels (based on the NeuveBrowserView design from the architecture guide)
- **WebTabsView**: Tab management interface with grid layout
- **MemoriesView**: Agent memory and bookmark management
- **SearchView**: Voice and text search interface

## Integration with Existing Chrome Services

The new iOS client reuses the following Chromium services:

### Core Browser Services
- `TabModel` (`ios/chrome/browser/tabs/`) - Tab management and state
- `WebState` (`ios/web/web_state/`) - WebKit integration
- `BookmarkModel` (`components/bookmarks/browser/`) - Bookmark storage
- `HistoryService` (`components/history/core/browser/`) - Browsing history
- `PrefService` (`components/prefs/`) - User preferences

### Networking
- Uses existing Chromium networking stack
- Inherits cookie management and security policies
- Maintains sync integration

## Building

### Prerequisites
- iOS 16.0 or later
- Xcode 15.0 or later
- Chromium build environment set up

### Build Commands

```bash
# Configure the build
gn gen out/ios_neuve --args='target_os="ios" ios_enable_code_signing=false'

# Build the new iOS client
ninja -C out/ios_neuve neuve_chrome
```

### Build Arguments

Key GN arguments for the Neuve Chrome build:

```gn
# Target iOS platform
target_os = "ios"

# Enable SwiftUI support
ios_enable_swiftui = true

# Include Neuve Chrome target
include_neuve_chrome = true

# Code signing (disable for development)
ios_enable_code_signing = false

# Optional: Debug symbols
symbol_level = 2
```

## Usage

### Tab Management
- **Home Tab**: Start page with recent sites, personal bookmarks, and easels
- **Tabs Tab**: Visual tab switcher with preview cards
- **Memories Tab**: AI-powered browsing context and bookmarks
- **Search Tab**: Voice and text search with intelligent suggestions

### Key Features
1. **Smart Search**: Supports both URL entry and web search
2. **Tab Previews**: Visual tab cards with close functionality  
3. **Voice Input**: Integrated voice search capability
4. **Recent History**: Quick access to recently visited sites
5. **Personal Bookmarks**: Organized bookmark folders
6. **Easels & Notes**: Memory management for browsing sessions

## Development

### Adding New Features

1. **UI Components**: Add new SwiftUI views in `ui/views/`
2. **Service Integration**: Extend service bridges in `services/`
3. **Framework Updates**: Modify `NeuveUIFramework.swift` for state management

### Testing

```bash
# Run unit tests
ninja -C out/ios_neuve neuve_chrome_unittests

# Run integration tests  
ninja -C out/ios_neuve neuve_chrome_inttests
```

### Debugging

Use Xcode's debugging tools with the generated `.xcodeproj` file:

```bash
# Generate Xcode project
gn gen out/ios_neuve --ide=xcode
open out/ios_neuve/neuve_chrome.xcodeproj
```

## Future Enhancements

- [ ] Web content rendering in tab previews
- [ ] Advanced bookmark organization
- [ ] Sync integration with Chrome account
- [ ] Extension support
- [ ] Advanced memory/agent features
- [ ] Custom gesture navigation
- [ ] iPad-specific layouts

## Contributing

Follow the existing Chromium contribution guidelines:
1. Create feature branch
2. Make changes following Swift/SwiftUI best practices
3. Test on physical iOS devices
4. Submit pull request with detailed description

## License

This project follows the same BSD license as Chromium.