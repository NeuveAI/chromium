# WebKit for SwiftUI

Apple’s **WebKit for SwiftUI** API collection makes it easy to integrate web‑based experiences into a SwiftUI application.  It supplies a new `WebView` view that renders HTML, CSS and JavaScript alongside native SwiftUI views, and it exposes an accompanying `WebPage` class that lets you track and control the state of web content.  The API also includes protocols and types for managing navigation, configuring behaviour and handling custom resource schemes.  Together these types let developers build browser‑like components that feel fully native while still harnessing the power of the WebKit engine【268694156017393†L20-L39】.

## Overview

* **Integration with SwiftUI** – The API introduces a `WebView` view and a `WebPage` object.  You embed web content in a SwiftUI hierarchy by creating a `WebView` and passing either a URL or a `WebPage` instance.  The `WebView` renders the content while respecting SwiftUI’s layout system and responds to modifiers like any other view【863371579766190†L8-L21】.  Using a `WebPage` gives you full control over navigation, page state and interactions【863371579766190†L24-L34】.
* **Customisable behaviour** – WebKit for SwiftUI includes numerous hooks for controlling the browsing experience.  View modifiers allow you to customise scrolling, gesture recognition, link preview behaviour, text selection, context menus and whether the page’s background shows through【863371579766190†L48-L85】.  The `NavigationDeciding` protocol lets you veto or allow navigations based on their source and type【342203519738595†L20-L22】.  A `NavigationPreferences` value controls whether JavaScript runs, which user–agent mode (desktop vs mobile) to use, whether to upgrade HTTP links to HTTPS and more【872411011983898†L43-L50】.  The `Configuration` struct includes settings for media playback, screen time blocking, data storage, custom URL schemes and device sensors【395601969466313†L60-L61】.
* **Observability** – Both `WebView` and `WebPage` are `Observable` types.  You can bind SwiftUI state to properties like `WebPage.title`, `WebPage.estimatedProgress` or the `BackForwardList` to automatically update the UI when the page changes.  The `NavigationEvent` enum reports progress events such as when navigation starts, commits, finishes or receives a server redirect【105842586820260†L55-L57】【105842586820260†L69-L70】【105842586820260†L80-L82】【862038986428253†L15-L16】.
* **Custom resource schemes** – For resources not handled by WebKit (e.g. local files), you can implement the `URLSchemeHandler` protocol and register it through `WebPage.Configuration.urlSchemeHandlers`.  When the page encounters a URL with your custom scheme, it forwards the request to your handler, which returns a stream of `URLSchemeTaskResult` values containing responses and data【900665326928297†L19-L45】.
* **Exporting and transforming** – Because `WebPage` conforms to `Transferable`, you can export pages to PDF or web archive formats.  You can also run arbitrary JavaScript on the page with `callJavaScript(_:arguments:in:contentWorld:)`, or capture the page as an image for further processing【237383390582521†L84-L146】.

## Related API

The WebKit for SwiftUI documentation includes dedicated pages for each component.  Refer to the following files for details:

| Component | Description |
|---|---|
| **WebView** | SwiftUI view that displays web content and provides a high‑level browsing experience.  See `WebView.md`. |
| **WebPage** | Observable class representing a web session.  Allows programmatic loading, executing JavaScript, and exporting content.  See `WebPage.md`. |
| **NavigationDeciding** | Protocol for deciding whether to allow navigations.  See `NavigationDeciding.md`. |
| **NavigationAction** & **NavigationResponse** | Types that describe the action initiating a navigation and the server’s response, respectively.  These are used when making navigation decisions.  See `NavigationAction.md` and `NavigationResponse.md`. |
| **NavigationPreferences** | Struct that controls how pages are rendered and navigated (e.g., whether JavaScript runs, content mode, HTTPS upgrading).  See `NavigationPreferences.md`. |
| **BackForwardList** | Represents navigation history and allows programmatic navigation to previous/forward pages.  See `BackForwardList.md`. |
| **NavigationEvent** | Enum representing stages of a navigation (provisional, committed, finished, server redirect).  See `NavigationEvent.md`. |
| **FrameInfo** | Struct describing a frame’s properties such as whether it is the main frame and its security origin.  See `FrameInfo.md`. |
| **Configuration** | Struct specifying preferences and behaviours for a `WebPage` (media playback, data store, custom schemes).  See `Configuration.md`. |
| **DeviceSensorAuthorization** | Struct describing sensor permission policies for web content.  See `DeviceSensorAuthorization.md`. |
| **URLScheme / URLSchemeHandler / URLSchemeTaskResult** | Types for defining and handling custom URL schemes and streaming responses to WebKit.  See `URLScheme.md`, `URLSchemeHandler.md` and `URLSchemeTaskResult.md`. |
