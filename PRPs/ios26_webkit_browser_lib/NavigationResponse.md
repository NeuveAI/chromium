# NavigationResponse

`NavigationResponse` is a value type that represents the server’s response to a navigation request.  It is passed to the `NavigationDeciding` protocol after a provisional navigation has begun but before the response is displayed.  By examining the response, your app can decide whether to allow or cancel the navigation.

## Overview

* The documentation describes a `NavigationResponse` as “an object that contains the response to a navigation request, and which you use to make navigation‑related policy decisions”【257379806613985†L19-L21】.  It is meant to be used with a `NavigationDeciding` implementation【257379806613985†L9-L15】.
* Important properties include:
  * **`response`** – A `URLResponse` describing the HTTP response.  You can inspect its URL, MIME type, and headers.
  * **`canShowMimeType`** – A Boolean indicating whether WebKit is capable of displaying the response’s MIME type natively【429919605365211†L3-L24】.  For example, WebKit can show HTML, images and PDFs but may not display certain binary formats.
  * **`frame`** – A `FrameInfo` describing the target frame for the response.  Use `frame.isMainFrame` to determine if the main frame is being loaded.

## Decision flow

When a provisional navigation starts, WebKit first calls your `decidePolicy(for action:preferences:)` method with a `NavigationAction`.  If you return `.allow`, WebKit continues loading and eventually receives a response.  At that point it calls `decidePolicy(for response:)` with a `NavigationResponse`.  You can inspect the MIME type and other attributes to decide whether to display the content, download it or cancel the navigation.

Example decision logic:

```swift
func decidePolicy(for response: WebPage.NavigationResponse) async -> WKNavigationResponsePolicy {
    // Disallow content that WebKit cannot display
    guard response.canShowMimeType else { return .download }
    // Allow HTML and images, but block large PDFs
    if let mimeType = response.response.mimeType, mimeType == "application/pdf" {
        return .download
    }
    return .allow
}
```

By combining information from `NavigationAction` and `NavigationResponse`, your app can enforce a comprehensive navigation policy tailored to your use case.
