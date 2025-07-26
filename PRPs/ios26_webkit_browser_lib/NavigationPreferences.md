# NavigationPreferences

`NavigationPreferences` is a struct that specifies how WebKit should load and render page content.  It acts as a set of per‑navigation settings that you can modify to tailor the browsing experience.  A `WebPage` holds a default `NavigationPreferences` value that you can override when loading content, and you can also create your own preferences and supply them when deciding navigation policies.

## Purpose

The documentation explains that you create a `NavigationPreferences` value to change the default rendering behaviour; while iOS and iPadOS devices render web content for a mobile experience, Mac devices render for desktop experiences【872411011983898†L43-L50】.  This struct lets you override those defaults.

## Key properties

| Property | Default | Description |
|---|---|---|
| `allowsContentJavaScript` | `true` | Determines whether JavaScript executes within the context of loaded pages.  When set to `false`, script tags and inline event handlers are disabled, so no JavaScript runs【967264118312516†L26-L37】.  You might disable JavaScript to improve performance or security. |
| `isLockdownModeEnabled` | Follows system | Reflects the device’s “Lockdown” mode setting.  When `true`, access to certain web APIs (such as WebGL) is restricted.  You can set this property to override the system default【452765516411337†L9-L13】. |
| `preferredContentMode` | `.recommended` | Selects the user agent’s rendering mode.  On mobile devices the recommended mode adapts to the device (mobile vs desktop), but you can force `.desktop` or `.mobile` rendering.  Subframe navigations ignore this preference【600464721689892†L15-L16】.  The `ContentMode` enumeration describes each case and notes that desktop browsers render web pages differently than mobile browsers【209886258694583†L9-L16】. |
| `preferredHTTPSNavigationPolicy` | `.keepAsRequested` | Determines whether to upgrade HTTP URLs to HTTPS.  The default keeps the protocol as requested by the user.  Other policies include automatically upgrading with fallback to HTTP, failing immediately if upgrade fails, or requiring user interaction to fall back【323622600272425†L31-L38】【551550320620286†L32-L34】【337027270783358†L20-L22】. |

In addition to these properties, `NavigationPreferences` may offer other settings such as controlling cookie acceptance or content blocking (not covered in the current documentation snapshot).

## Enumerations

### `ContentMode`

The `ContentMode` enumeration defines how WebKit renders content.  Cases include:

* **`.recommended`** – Use the system’s recommended mode (typically mobile on iPhone/iPad and desktop on Mac).  This case adapts to the platform.
* **`.desktop`** – Force desktop rendering; pages appear as they would on a desktop browser.  The documentation notes that desktop browsers render web pages differently than mobile browsers【209886258694583†L9-L16】.
* **`.mobile`** – Force mobile rendering; pages load using a mobile user agent.

### `UpgradeToHTTPSPolicy`

`UpgradeToHTTPSPolicy` controls whether WebKit upgrades HTTP links to HTTPS:

* **`.keepAsRequested`** – Keep the protocol specified in the navigation request (default).  This policy may be superseded by `WebPage.Configuration.upgradeKnownHostsToHTTPS`【323622600272425†L31-L38】.
* **`.automaticFallbackToHTTP`** – Attempt to upgrade to HTTPS, but automatically fall back to HTTP if the upgrade fails.  This is used when a site supports both protocols and you prefer security but want to maintain compatibility【337027270783358†L20-L22】.
* **`.errorOnFailure`** – Attempt to upgrade to HTTPS and cancel the navigation if the upgrade fails.
* **`.userMediatedFallbackToHTTP`** – Attempt to upgrade; if it fails, ask the user before falling back to HTTP【551550320620286†L32-L34】.

## Usage

You can set default preferences on a `WebPage.Configuration`, or pass preferences when making navigation decisions.  For example, you might disable JavaScript for a specific request:

```swift
var prefs = WebPage.NavigationPreferences()
prefs.allowsContentJavaScript = false
await page.load(request, preferences: prefs)
```

This disables JavaScript for the loaded page only, leaving other navigations unaffected.
