# NavigationEvent

`NavigationEvent` is an enumeration that represents significant moments in the lifecycle of a navigation.  When you call a `WebPage`’s `load` method, it returns an asynchronous sequence of `NavigationEvent` values.  Iterating through these events lets you monitor progress, respond to redirects, and perform actions when navigation finishes.

## Enumeration Cases

| Case | Description | Source |
|---|---|---|
| `.startedProvisionalNavigation` | Emitted after a navigation request receives provisional approval but before WebKit has received the response.  Use this to update UI when navigation begins【105842586820260†L55-L57】. |
| `.committed` | Emitted when WebKit begins receiving the content of the page.  At this point the frame’s document and URL are available【105842586820260†L69-L70】. |
| `.finished` | Emitted when navigation completes successfully.  You can perform post‑navigation tasks here【105842586820260†L80-L82】. |
| `.receivedServerRedirect` | Emitted when the server issues a redirect during provisional navigation【862038986428253†L15-L16】.  You might update state to reflect the new URL. |

Other cases may include error states or subframe events (not detailed in the current documentation snapshot).

## Usage

To observe navigation events, iterate through the sequence returned by `page.load(request)`:

```swift
for await event in page.load(request) {
    switch event {
    case .startedProvisionalNavigation:
        // Show a loading indicator
    case .receivedServerRedirect:
        // Update the address bar with the new URL
    case .committed:
        // The page has begun loading content
    case .finished:
        // Hide the loading indicator and process results
    }
}
```

Listening to `NavigationEvent`s allows your UI to react to each stage of loading and provide feedback to the user.
