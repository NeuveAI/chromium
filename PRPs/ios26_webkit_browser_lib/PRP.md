# Controlled WebView Browser PRP

## Purpose

Build a **controlled webview browser** component using SwiftUI and the WebKit for SwiftUI API.  The component should load a specified webpage, enforce navigation policies, allow back/forward navigation, support custom URL schemes, expose sensor and media permissions, and provide hooks for evaluating JavaScript and exporting content.

This PRP follows the context‑rich template to ensure the AI agent has all necessary information and validation steps to deliver working code.

## Core Principles

1. **Context is King** – All relevant documentation and file references are included below.
2. **Validation Loops** – Define acceptance tests and measurable outcomes the agent must meet.
3. **Information Density** – Use concrete API names and patterns to guide implementation.
4. **Progressive Success** – Build modularly; test navigation control before adding custom scheme handlers.

---

## Goal

Refactor `WebTabContentView` as a SwiftUI `ControlledWebView` component that encapsulates a `WebView` and `WebPage` from the WebKit for SwiftUI API. Making changes necessary to the WebStateBridge.

The component must:
* Load a provided URL and display it.
* Enforce custom navigation policies (allowed domains, blocked downloads).
  * It should behave like a browser by default, so allowed domains and blocked domains should have empty defaults
* Provide back/forward navigation controls that reflect history state.
* Register and handle custom URL schemes (e.g. `myapp://`) to serve local resources.
  * For now register only neuvebrowser://
* Allow configuration of content preferences (JavaScript, content mode, HTTPS upgrades).
  * Again use good defaults for a browser but allow for overrides
* Surface navigation events (started, committed, finished, redirected) to the UI.
* Offer optional export of the current page as PDF or image.

## Why

- **Controlled browsing**: Many apps need to embed web content while restricting navigation to approved domains【NavigationDeciding.md†L20-L22】.
- **Modern API adoption**: The WebKit for SwiftUI API introduced at WWDC 2024 simplifies web integration and should be used instead of legacy `WKWebView`【WebView.md†L8-L21】.
- **Security and privacy**: Custom policies, sensor authorisation and scheme handlers protect users from unwanted content and requests【DeviceSensorAuthorization.md†L14-L15】.
- **Extensibility**: A modular component allows future expansion (e.g. additional scheme handlers) without rewriting core code.

## What

The component must deliver the following behaviour and technical features:

### User‑visible behaviour

- Display the webpage specified by an initial `URL`.  Show the current page title and URL in the UI.
- Show a progress bar or indicator bound to `page.estimatedProgress` until the page finishes loading【https://developer.apple.com/tutorials/data/documentation/webkit/webview-swift.struct.json#:~:text=%7D%2C%7B,can%20only%20bind%20a】.
- Provide back and forward buttons; disable them when no previous/next item exists in the `BackForwardList`【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/backforwardlist-swift.struct.json#:~:text=,d】.
- Show an alert when navigation to an unapproved domain is attempted.
- Optionally offer UI toggles for enabling/disabling JavaScript, switching between mobile and desktop content modes【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences.json#:~:text=iew,do】, and upgrading HTTP to HTTPS【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences/preferredhttpsnavigationpolicy.json#:~:text=,variants】.
- Expose a button or menu item to export the current page as PDF or image using `page.export` (via `Transferable` conformance of `WebPage`).

### Technical requirements

- Use `WebView(url:)` or `WebView(_ page:)` to create the view【https://developer.apple.com/tutorials/data/documentation/webkit/webview-swift.struct.json#:~:text=%5B%7B,paragraph】.  When advanced control is needed, bind a `WebPage` to the view【https://developer.apple.com/tutorials/data/documentation/webkit/webview-swift.struct.json#:~:text=%7D%2C%7B,can%20only%20bind%20a】.
- Create a custom `WebPage.Configuration` with:
  * Disabled JavaScript when requested via `allowsContentJavaScript`【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences/allowscontentjavascript.json#:~:text=,references】.
  * A `NavigationPreferences` specifying desktop or mobile content mode【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences.json#:~:text=iew,do】.
  * `upgradeKnownHostsToHTTPS` set according to user toggle【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences/preferredhttpsnavigationpolicy.json#:~:text=,variants】.
  * Custom `DeviceSensorAuthorization` to allow motion sensors but deny media capture【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/devicesensorauthorization.json#:~:text=A%20type%20that%20describes%20the,swift】.
  * A `URLSchemeHandler` registered for each custom scheme, returning data and responses as `URLSchemeTaskResult`【https://developer.apple.com/tutorials/data/documentation/webkit/urlschemehandler.json#:~:text=,c】.
- Conform to `NavigationDeciding` to intercept navigation actions and responses.  Cancel unapproved navigations and respond appropriately【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationdeciding.json#:~:text=el,met】【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationaction.json#:~:text=,doc%3A%2F%2Fco】.  Use `NavigationAction` and `NavigationResponse` to inspect requests【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationaction.json#:~:text=on%2FWebKit%2FWebPage%2FFrameInfo,Properties%22%2C%22ide】【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationresponse.json#:~:text=text,documentation%2Fwebkit%2Fwebpage%2Fnavigationrespo】.
- Observe navigation progress and events via asynchronous sequences or `NavigationEvent` to update the UI【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationevent.json#:~:text=%2C,a%20response%20to%20that%20request】.

### Success Criteria

- [ ] **Navigation control**: Attempting to navigate to an unapproved domain triggers cancellation and an alert.
- [ ] **History management**: Back/forward buttons enable and disable correctly based on `BackForwardList` state【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/backforwardlist-swift.struct/backlist.json#:~:text=List,patc】. Whist still observing how ios/chrome/browser implements history and porting / adapting as much whist reusing it as a base layer.
- [ ] **Custom scheme loading**: A registered scheme handler successfully loads a local resource (e.g. image) when a `neuvebrowser://` URL is visited【https://developer.apple.com/tutorials/data/documentation/webkit/urlschemehandler.json#:~:text=,c】.
- [ ] **Sensor permissions**: Web content requesting motion or media access is granted or denied according to configuration【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/devicesensorauthorization.json#:~:text=A%20type%20that%20describes%20the,swift】.
- [ ] **Rendering preferences**: Toggling JavaScript or switching content mode produces observable changes in the rendered page【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences/allowscontentjavascript.json#:~:text=,references】【https://developer.apple.com/tutorials/data/documentation/webkit/webpage/navigationpreferences.json#:~:text=iew,do】.

## All Needed Context

### Documentation & References


> OBS: / refers to the root of this project, whist ./ refers to this current folder

```yaml
# MUST READ – include these in your context window
- directory: /changelogs/
  why: This is a key folder where we gather what was done by agents on previous tasks. The files are named as changelog-<date>.md. Read the latest changelog file to understand what was done on the last session.
- directory: /learnings/
  why: This is a key folder for what the previous agent execution learned acording to the task it set out to do and what insights it had. The insights is based on what it needed to execute and what are some of the possible alternatives to do next based on the common goal of this project. Read the last learnings file to understand what kind of hand-offs we have to work with, but remember that this file directives take precedence when conflicting information arises.
- file: /CHROMIUM_UI_ARCHITECTURE.md
  why: A TLDR doc for onboarding into the chromium project, focusing on iOS code. This reflects the original implementation and its structure. This project also describes the goal of this project - 
- file: ./WebView.md
  why: Creation of `WebView` and binding to `WebPage`, understanding default behaviour and navigation controls【863371579766190†L8-L21】.
- file: ./WebPage.md
  why: Accessing and controlling web content; evaluating JavaScript; exporting pages; asynchronous navigation sequences.
- file: ./NavigationDeciding.md
  why: How to implement custom navigation policies; what information is available when deciding【342203519738595†L20-L22】.
- file: ./NavigationAction.md
  why: Inspecting navigation actions when deciding to allow or cancel navigation【282351521652238†L12-L15】.
- file: ./NavigationResponse.md
  why: Inspecting navigation responses when deciding to allow or cancel navigation【257379806613985†L9-L16】.
- file: ./NavigationPreferences.md
  why: Configuring content modes, HTTPS policies and JavaScript permissions【872411011983898†L43-L50】.
- file: ./BackForwardList.md
  why: Managing history and reflecting back/forward capabilities【932146644498746†L10-L13】.
- file: ./Configuration.md
  why: Setting up `WebPage.Configuration` including AirPlay, sensor authorisation, content settings and scheme handlers【395601969466313†L60-L61】.
- file: ./URLSchemeHandler.md
  why: Registering and implementing custom URL schemes to serve local resources【900665326928297†L19-L45】.
- file: ./DeviceSensorAuthorization.md
  why: Granting or denying access to motion sensors and media devices【987514520325437†L14-L15】.
- file: ./SUMMARY.md
  why: Consolidated summary of WebKit for SwiftUI integration.
```

Other key sources of information are:
```yaml
- directory: /docs/
  why: Where all the main docs are included. we different setup, "how to" and iOS specific docs there that can be used in case of research needed for subjects specific for this repository or things that might be of need to improve context when executing tasks. It's advised to search within this folder at least once to gather context.
- directory: /.github/prompts/
  why: different prompts to guild LLMs and agents on how to execute and use different dependencies within this project.
```
### Known Gotchas & Library Quirks

```python
# CRITICAL: JavaScript is enabled by default; you must explicitly disable it via NavigationPreferences when needed【967264118312516†L26-L37】.
# CRITICAL: Subframe navigations ignore the content mode set in NavigationPreferences; only top-level navigation uses the preference【872411011983898†L43-L50】.
# CRITICAL: `NavigationDeciding` callbacks run on the main actor; avoid long‑running operations.
# CRITICAL: Scheme handlers should send a `URLResponse` before sending data, and end with `.success(.data(...))` or `.success(.response(...))`【900665326928297†L19-L45】.
# Example: Upgrading HTTP to HTTPS may break pages if the host does not support HTTPS; provide a fallback option【323622600272425†L31-L38】.
# Example: Do not block the main thread when exporting pages to PDF or image.
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
# The ControlledWebView component lives in its own module under Sources/
ios/
└── neuve_chrome/
    └── app/
        └── browser/                         # Similar to ios/chrome, this folder is for browser logic and services
            ├── NavigationPolicy.swift       # Defines allowed domains and blocking rules
            ├── ControlledNavigationDelegate.swift  # Implements NavigationDeciding and publishes alerts
            ├── CustomSchemeHandler.swift    # Handles myapp:// scheme and serves local resources
            ├── ControlledWebView.swift      # SwiftUI view composing WebView with controls and settings
?/                                           # Test folder for iOS tests (unknown at this point)
└── ControlledWebViewTests.swift             # Unit tests verifying navigation, history and scheme handling
```

## Implementation Blueprint

### Data models and structure

- Create a `ControlledWebView` `View` in SwiftUI.  Use an `@StateObject` of type `WebPage` to manage page state.
- Define a struct `NavigationPolicy` that lists allowed domains and optionally blocked URL patterns.
- Implement a class `ControlledNavigationDelegate` conforming to `NavigationDeciding` that checks `NavigationAction.request` and `NavigationResponse` against the policy and calls `.allow()` or `.cancel()` accordingly.
- Define a struct `CustomSchemeHandler` adopting `URLSchemeHandler` to return local data for `myapp://` scheme.

### List of tasks (in order)

```yaml
Task 1: Define data models
  CREATE ios/neuve_chrome/app/browser/NavigationPolicy.swift
    - Define `NavigationPolicy` with properties: `allowedDomains: [String]`, `blockDownloads: Bool`.
    - Provide a helper method `isAllowed(url: URL) -> Bool`.

Task 2: Implement navigation delegate
  CREATE ios/neuve_chrome/app/browser/ControlledNavigationDelegate.swift
    - Conform to `NavigationDeciding`.
    - Inspect `action.request.url?.host` and use `NavigationPolicy` to decide.
    - On disallowed navigation, cancel and publish an alert through a `@Published` property.

Task 3: Implement custom scheme handler
  CREATE ios/neuve_chrome/app/browser/CustomSchemeHandler.swift
    - Conform to `URLSchemeHandler`.
    - On start of a task, send a `URLResponse` with appropriate MIME type.
    - Read local resource (e.g. from app bundle) and send as `.success(.data(data))`.

Task 4: Compose the ControlledWebView
  CREATE ios/neuve_chrome/app/browser/ControlledWebView.swift
    - `@StateObject var page: WebPage` initialised with `Configuration` from user settings.
    - Provide UI with `WebView(page)`.
    - Bind progress, title and URL to the UI; implement back/forward buttons using `page.backForwardList`.
    - Include toggles for JavaScript, content mode and HTTPS upgrade; rebuild configuration when toggles change.
    - Handle alerts from `ControlledNavigationDelegate`.

Task 5: Export functionality
  MODIFY ControlledWebView.swift
    - Add a button to export the page using `page.exportPDF` or `page.exportImage` (pseudocode; check `WebPage` API for actual methods).
    - Save the resulting file to the user’s documents directory.

Task 6: Unit tests / validation (if using Xcode tests)
  CREATE ControlledWebViewTests.swift according to how the project setup iOS tests
    - Test navigation blocking by loading pages with external links.
    - Test custom scheme loading with local resources.
    - Test toggling JavaScript and verifying script behaviour.
```

### Pseudocode examples

```swift
// Navigation decision pseudocode
func decideNavigation(for action: NavigationAction) async -> NavigationDecision {
    guard let host = action.request.url?.host else { return .cancel }
    if navigationPolicy.isAllowed(url: action.request.url!) {
        return .allow
    } else {
        await MainActor.run { showBlockedAlert(for: host) }
        return .cancel
    }
}

// Register custom scheme handler
configuration.urlSchemeHandlers = [URLScheme("myapp") : CustomSchemeHandler()]
```

## Validation Loop

### Level 1: Syntax & style

- Compile the SwiftUI component in Xcode; fix any compiler errors and warnings.
- Run SwiftLint (if available) to enforce style conventions.

### Level 2: Unit tests

- Write unit tests using `XCTest` to verify navigation blocking, history management and scheme handling.  Tests should simulate page loads and assert expected UI state.

### Level 3: Integration test

- Launch the app in the simulator.  Load an approved URL and verify it displays.
- Tap on an external link and confirm an alert appears and the page doesn’t change.
- Navigate back and forward through history and ensure the buttons enable/disable correctly.
- Load a `myapp://` URL and verify the resource appears.
- Toggle JavaScript and content mode and observe changes in the page.

## Final validation checklist

> OBS: / refers to the root of this project, whist ./ refers to this current folder

- [ ] All tests pass and compile successfully.
- [ ] Navigation policies enforce allowed domains and blocked downloads.
- [ ] History controls reflect `BackForwardList` state.
- [ ] Custom schemes load resources correctly.
- [ ] Sensor and media permissions behave as configured.
- [ ] Rendering preferences change the appearance of pages as expected.
- [ ] Create a /changelogs/changelog-<date>.md
- [ ] Create a /learnings/learnings-<date>.md
