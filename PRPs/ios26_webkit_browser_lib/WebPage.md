# WebPage

`WebPage` is the central class of the WebKit for SwiftUI API.  It represents an observable web session and gives you fine‑grained control over how a page loads, navigates and interacts with content.  Because it conforms to `Observable`, you can bind SwiftUI view state directly to its properties and update your UI automatically as the page changes【237383390582521†L84-L146】.

## Creating a WebPage

You create a `WebPage` using one of its initialisers:

* **`WebPage()`** – Creates a page using the default configuration.
* **`WebPage(configuration:)`** – Pass a `WebPage.Configuration` to customise preferences such as media playback behaviour, data storage location, custom URL schemes and navigation policies【395601969466313†L60-L61】.
* **`WebPage(configuration:navigationDecider:)`** – Additionally supply a type conforming to `NavigationDeciding` to decide whether navigation actions should be allowed or denied.
* **`WebPage(configuration:navigationDecider:dialogPresenter:)`** – Also specify a custom JavaScript dialog presenter to handle `alert`, `confirm` and `prompt` functions.

After initialisation, associate the page with a `WebView` using `WebView(page)` to display its content.

## Loading content

`WebPage` provides several asynchronous methods to load content:

| Method | Purpose |
|---|---|
| `load(_ request: URLRequest)` | Loads a URL request and returns an async sequence of `NavigationEvent` values to observe progress.  You can ignore the events if you simply need to wait for completion【237383390582521†L84-L146】. |
| `load(html: String, baseURL: URL?)` | Loads an HTML string with an optional base URL. |
| `load(_ data: Data, mimeType: String, characterEncoding: String, baseURL: URL?)` | Loads raw data as a web resource. |

Each load method returns an async sequence; iterating through the events allows you to track when navigation starts, receives provisional approval, commits content, finishes or receives redirects.  If you only need to know when the load is complete, you can loop through the events and perform actions afterwards.

## Observing page state

Because `WebPage` is observable, you can bind UI elements to its properties.  Notable properties include:

* **`title`** – The current page title; updates automatically as the page changes【863371579766190†L90-L101】.
* **`url`** – The current URL of the page.
* **`estimatedProgress`** – A `Double` between 0 and 1 indicating load progress.
* **`isLoading`** – A Boolean indicating whether the page is currently loading.
* **`backForwardList`** – A `BackForwardList` representing the page’s navigation history, which you can use to navigate backwards or forwards programmatically【932146644498746†L10-L13】.

Additionally, the page supports asynchronous `callJavaScript(_:arguments:in:contentWorld:)` for executing JavaScript in the page and returning results.

## Example: custom metadata fetch

The documentation provides an example that uses `WebPage` to fetch metadata from a page by customising its configuration.  The example demonstrates:

* Creating a `WebPage.Configuration` that disables subresource loading and JavaScript (`loadsSubresources = false`, `defaultNavigationPreferences.allowsContentJavaScript = false`) and uses a non‑persistent data store.
* Setting a custom user agent string (`customUserAgent`) to mimic a bot when fetching open‑graph metadata.
* Loading a request using `page.load(request)` and awaiting completion.
* Executing JavaScript to extract metadata from the page once navigation completes.

The example emphasises that you can tailor the page’s configuration to your needs and then perform operations after the page has finished loading【237383390582521†L84-L146】.

## Programmatic navigation and control

* **Back‑forward navigation** – Use `page.backForwardList` to access the current, back and forward items.  You can call `WebView.go(to:)` on a `WebView` to navigate to a specific item.
* **Reload and stop** – `page.reload(fromOrigin:)` reloads the current page, optionally bypassing caches, and `page.stopLoading()` cancels the current load.
* **Media control** – Methods like `pauseAllMediaPlayback()`, `setAllMediaPlaybackSuspended(_:)` and `mediaPlaybackState()` let you manage media on the page, and `fullscreenState` notifies you of full‑screen changes.
* **Camera and microphone** – Properties such as `cameraCaptureState` and `microphoneCaptureState` tell you whether those devices are in use, and `setCameraCaptureState(_:)` or `setMicrophoneCaptureState(_:)` can change them (subject to system permissions).
* **Export** – Because `WebPage` conforms to `Transferable`, you can call `exported(as:)` to generate PDF, web archive or other representations.

## Customising behaviour

`WebPage` works closely with several other types:

* **`NavigationDeciding`** – Implement this protocol to approve or deny navigations based on the originating `NavigationAction` or `NavigationResponse`【342203519738595†L20-L22】.
* **`NavigationPreferences`** – Use this struct to set whether JavaScript executes, which content mode to render (desktop or mobile) and how to handle HTTPS upgrading【872411011983898†L43-L50】.
* **`Configuration`** – A `WebPage.Configuration` sets high‑level options such as media playback, data storage, user content controllers, custom URL schemes, sensor authorisations and more【395601969466313†L60-L61】.
* **`URLSchemeHandler`** – Register custom URL scheme handlers via `configuration.urlSchemeHandlers` to load resources that WebKit doesn’t handle natively【900665326928297†L19-L45】.

Collectively, these components let you build a secure and customisable web browser inside your SwiftUI app.
