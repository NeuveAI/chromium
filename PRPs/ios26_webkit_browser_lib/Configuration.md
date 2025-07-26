# WebPage.Configuration

`WebPage.Configuration` is a struct that describes the preferences and behaviours of a `WebPage`.  When you create a `WebPage`, you supply a configuration to customise media playback, data storage, sensor permissions, content controllers and more【395601969466313†L60-L61】.  If you don’t specify a configuration, WebKit uses sensible defaults.

## Key properties and categories

`Configuration` exposes numerous properties.  Below is a non‑exhaustive overview grouped by category.

### Media and playback

* **`allowsAirPlayForMediaPlayback`** – Indicates whether users can route audio/video to AirPlay devices.  The default is `true`【853543298945847†L28-L29】.
* **`allowsPictureInPictureMediaPlayback`** – Allows videos to enter picture‑in‑picture mode.
* **`mediaTypesRequiringUserActionForPlayback`** – Specifies which media types (audio, video) require user gestures to begin playback.

### Navigation and content loading

* **`loadsSubresources`** – When `false`, only the main resource loads; subresources (images, scripts) are blocked.  Useful for metadata fetching【237383390582521†L84-L146】.
* **`defaultNavigationPreferences`** – A `NavigationPreferences` value applied to all navigations unless overridden【872411011983898†L43-L50】.
* **`upgradeKnownHostsToHTTPS`** – Whether WebKit should automatically upgrade HTTP requests to HTTPS for known hosts.  This may supersede `NavigationPreferences.preferredHTTPSNavigationPolicy`【323622600272425†L31-L38】.

### Data storage and user content

* **`websiteDataStore`** – Chooses between persistent and non‑persistent storage.  Use `.nonPersistent()` to prevent cookies and cache from being saved【237383390582521†L84-L146】.
* **`userContentController`** – Provides a bridge for injecting JavaScript and message handlers.
* **`limitsNavigationsToAppBoundDomains`** – Restricts navigations to a set of domains defined in your app’s entitlements.

### Custom schemes and sensor access

* **`urlSchemeHandlers`** – A dictionary mapping `URLScheme` values to types conforming to `URLSchemeHandler`.  Use this to support custom resource types (e.g. `myapp://` URLs)【900665326928297†L19-L45】.
* **`deviceSensorAuthorization`** – A `DeviceSensorAuthorization` instance defining which device sensors (orientation/motion or media capture) the page may access【987514520325437†L14-L15】.

### User agent and direction

* **`applicationNameForUserAgent`** and **`customUserAgent`** – Strings appended or used to override the default user agent.  Use a custom user agent when scraping metadata or when websites need to recognise your app【237383390582521†L84-L146】.
* **`userInterfaceDirectionPolicy`** – Determines whether the page should respect the system’s layout direction (left‑to‑right vs right‑to‑left).

### Miscellaneous

* **`suppressesIncrementalRendering`** – When `true`, WebKit waits until enough data has loaded before rendering, which may improve the appearance of some pages.
* **`showsSystemScreenTimeBlockingView`** – If enabled, displays a system view when Screen Time restrictions block content.
* **`hasOnlySecureContent`** – Read‑only property on `WebPage` (not configuration) indicating whether all resources loaded from secure origins【237383390582521†L168-L176】.

## Initialising Configuration

Create a configuration and adjust properties as needed:

```swift
var config = WebPage.Configuration()
config.defaultNavigationPreferences.allowsContentJavaScript = false
config.loadsSubresources = false
config.websiteDataStore = .nonPersistent()
config.urlSchemeHandlers = [URLScheme("myapp")!: MySchemeHandler()]
let page = WebPage(configuration: config)
```

By supplying a customised configuration, you can build a secure, privacy‑respecting web experience that only loads the resources you need and integrates seamlessly with your app.
