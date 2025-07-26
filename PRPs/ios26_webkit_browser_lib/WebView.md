# WebView

`WebView` is a SwiftUI view that renders web content in your app.  It displays HTML, CSS and JavaScript alongside other native views, providing the feel of a full browser within the SwiftUI environment.  This struct is part of the WebKit for SwiftUI API collection and works hand in hand with the `WebPage` class to offer both simple and advanced browsing experiences.

## Creating a WebView

There are two primary initialisers:

* **`WebView(url:)`** – Create a `WebView` by supplying a `URL`.  Use this when you simply need to display a web page and do not require programmatic control over navigation.  This form automatically manages a `WebPage` behind the scenes and provides forward/back gestures, navigation bar integration and other browser‑like behaviour【863371579766190†L24-L34】.
* **`WebView(_ page: WebPage)`** – Pass an existing `WebPage` instance when you need advanced control.  Any changes you make to the page (loading requests, executing JavaScript) are reflected in the view, and the page’s observable properties (title, URL, loading progress) can update your SwiftUI state【863371579766190†L8-L21】.

### Example: toggle between two pages

The following snippet from Apple’s documentation demonstrates toggling between two URLs and disabling the back‑forward navigation gesture:

```swift
enum Source { case apple, swift }
@State private var source: Source = .apple
var body: some View {
    VStack {
        Button("Show alternate page") {
            source = (source == .apple ? .swift : .apple)
        }
        WebView(url: source == .apple ? URL(string: "https://www.apple.com")! : URL(string: "https://www.swift.org")!)
            .allowsBackForwardNavigationGestures(false)
    }
}
```

Using the `.allowsBackForwardNavigationGestures(false)` modifier disables the default edge‑swipe gestures for navigating in the history【863371579766190†L37-L47】.

### Example: binding a WebPage

When you need to observe and control the page directly, create a `WebPage` and bind it to the view.  Because `WebPage` conforms to `Observable`, SwiftUI updates the UI automatically when the page changes.  Here the navigation bar title reflects the page’s title:

```swift
@State private var page = WebPage()
var body: some View {
    NavigationStack {
        WebView(page)
            .navigationTitle(page.title ?? "")
    }
}
```

The title updates automatically because `WebPage.title` is an observable property【863371579766190†L90-L101】.

## Customising the user experience

`WebView` behaves like a scroll view and includes numerous modifiers for fine‑tuning behaviour.  You can:

* Enable or disable interactive scroll indicators and control whether content scrolls automatically when the keyboard appears.
* Control zooming behaviour and link‑preview interactions (e.g. long‑pressing a link).  A `.allowsLinkPreview(false)` modifier disables Safari‑style previews.
* Disable or enable user text selection.
* Define whether the `WebView` enters fullscreen for video playback or interacts with a system‑provided context menu.
* Adjust the background transparency to allow underlying SwiftUI views to show through【863371579766190†L48-L85】.

## Working with WebPage

For simple read‑only pages, constructing `WebView(url:)` is sufficient.  To customise navigation or integrate with your app’s state, create a `WebPage` object and supply it to the view.  You can then:

* Programmatically load URL requests or HTML strings via methods on `WebPage`.
* Observe navigation events, such as when navigation starts or finishes, and update your UI accordingly.
* Provide a `NavigationDeciding` delegate to restrict certain navigations or customise responses.
* Use the `backForwardList` property to programmatically navigate history.

Connecting a `WebView` to a `WebPage` transforms it from a simple browser into a fully controllable web component within your SwiftUI app【863371579766190†L86-L97】.
