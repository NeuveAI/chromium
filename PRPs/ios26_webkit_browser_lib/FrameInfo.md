# FrameInfo

`FrameInfo` is a struct that contains information about a frame on a webpage.  It is used by navigation APIs to identify the frame that initiated a navigation action and the frame that will display the resulting content.

## Properties

| Property | Type | Description |
|---|---|---|
| `isMainFrame` | `Bool` | Indicates whether the frame is the main frame of the page (`true`) or a subframe (`false`)【817921294561126†L2-L7】.  This is useful when deciding whether to allow a navigation; you might block subframe navigations but allow main frame changes. |
| `request` | `URLRequest` | The current URL request associated with the frame【796240538813625†L0-L10】.  You can inspect this request to understand what the frame is loading. |
| `securityOrigin` | `WKSecurityOrigin` | Describes the security origin (scheme, host and port) of the frame【369113489183898†L30-L45】.  This is important when applying content‑security policies or sandboxing rules. |

`FrameInfo` values are passed inside `NavigationAction` and `NavigationResponse` to identify the source and target frames for a navigation.

## Usage

In a `NavigationDeciding` implementation you might allow certain actions only when initiated from the main frame:

```swift
func decidePolicy(for action: WebPage.NavigationAction, preferences: WebPage.NavigationPreferences) async -> WKNavigationActionPolicy {
    guard action.source.isMainFrame else {
        return .cancel
    }
    return .allow
}
```

By inspecting `FrameInfo`, your app can make informed decisions about multi‑frame navigations and enforce security policies.
