# NavigationAction

`NavigationAction` is a value type that encapsulates information about the event that initiated a navigation.  WebKit passes a `NavigationAction` to your `NavigationDeciding` implementation so that you can decide whether to allow the navigation.  Understanding the information contained in this struct helps you make more nuanced decisions.

## Overview

* A `NavigationAction` describes what triggered the navigation – for example a link click, form submission, back‑forward gesture, reload or script‑initiated navigation.  You examine the `navigationType` property to understand the source.
* The struct includes details such as:
  * **`request`** – The `URLRequest` being loaded.
  * **`source`** – The `FrameInfo` of the frame that initiated the navigation (which might be a subframe).  Use `source.isMainFrame` to determine whether the main frame initiated the action.
  * **`target`** – The `FrameInfo` of the target frame, if the navigation specifies one.
  * **`buttonNumber` and `modifierFlags`** – The mouse button and keyboard modifiers involved (useful for detecting right‑clicks or command‑clicks).
  * **`shouldPerformDownload`** – A Boolean indicating whether this navigation should trigger a file download instead of loading in the view.

* Apple’s documentation notes that a `NavigationAction` value is intended to be used to make policy decisions about whether to allow navigation within a web page via a `NavigationDeciding` implementation【282351521652238†L14-L50】.

## Example usage

In your `NavigationDeciding` implementation, you might block navigation initiated by scripts while allowing user‑initiated clicks:

```swift
func decidePolicy(for action: WebPage.NavigationAction, preferences: WebPage.NavigationPreferences) async -> WKNavigationActionPolicy {
    // Only allow navigations triggered by user clicks or reloads
    switch action.navigationType {
    case .linkActivated, .reload:
        return .allow
    default:
        return .cancel
    }
}
```

You can also check `action.shouldPerformDownload` to redirect downloads into your own download manager.

By examining the properties of `NavigationAction`, your app can tailor its behaviour to the user’s intent and maintain control over the browsing session.
