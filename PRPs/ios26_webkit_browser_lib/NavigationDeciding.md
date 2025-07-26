# NavigationDeciding

The `NavigationDeciding` protocol allows you to customise the way a `WebPage` handles navigation requests.  It provides asynchronous methods that you implement to either allow or deny navigation based on the details of the request or response.  This protocol is central to building a controlled browsing experience where your app, rather than the remote page, decides which links the user may follow.

## Overview

* `NavigationDeciding` is a protocol adopted by a type that you provide when creating a `WebPage` (using the `navigationDecider:` initialiser).  The protocol’s methods are called on the main actor and allow you to respond to navigation actions and responses.
* The documentation states that you can use these methods “to restrict navigation from specific links within your content”【342203519738595†L20-L22】.  For example, you might block navigation to external domains or require confirmation before leaving your app’s domain.
* When a navigation begins, WebKit calls one of the protocol’s methods (e.g., `decidePolicy(for:preferences:)` or `decidePolicy(for:)`) with a `NavigationAction` or `NavigationResponse`.  Your implementation returns a `WKNavigationActionPolicy` or `WKNavigationResponsePolicy` to allow or cancel the navigation.
* The protocol also includes a method for handling authentication challenges (`decideAuthenticationChallengeDisposition(for:)`) where you can provide credentials or cancel navigation.

## Usage

To use `NavigationDeciding`, define a class or struct conforming to the protocol:

```swift
final class MyNavigationDelegate: NavigationDeciding {
    func decidePolicy(for action: WebPage.NavigationAction, preferences: WebPage.NavigationPreferences) async -> WKNavigationActionPolicy {
        // Inspect action.request, action.navigationType, etc.
        // Return .allow or .cancel
    }

    func decidePolicy(for response: WebPage.NavigationResponse) async -> WKNavigationResponsePolicy {
        // Inspect response.canShowMimeType, response.response (URLResponse) etc.
    }

    func decideAuthenticationChallengeDisposition(for challenge: AuthenticationChallenge) async -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
        // Provide credentials or refuse.
    }
}

let page = WebPage(configuration: config, navigationDecider: MyNavigationDelegate())
```

Because the protocol’s methods are async, you can perform asynchronous checks (like network requests or user confirmation) before returning a policy.

## Considerations

* Your implementation should respect user privacy and security.  For example, you might allow navigation only to a whitelist of domains or block downloads.
* Remember that not all requests originate from user interaction – some may be script‑initiated or from subframes.  Use the `NavigationAction`’s properties (button number, modifier keys, source frame) to determine the context.
* If you return `.cancel` for a navigation, WebKit will stop the load.  Use `.download` to instead download the resource (if appropriate).

With `NavigationDeciding`, you gain full control over how your app’s web views behave, ensuring that browsing aligns with your product’s requirements.
