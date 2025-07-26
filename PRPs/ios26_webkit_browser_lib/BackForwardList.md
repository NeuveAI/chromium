# BackForwardList

`BackForwardList` is an observable struct that represents the navigation history of a `WebPage`.  It allows your app to inspect and manipulate the list of pages that the user has visited, enabling browser‑like forward and backward navigation controls.

## Overview

Apple’s documentation describes `BackForwardList` as “an observable representation of a webpage’s navigations that you use to facilitate navigation to prior or subsequent resources, and to observe the addition and removal of items in the list”【932146644498746†L10-L13】.  It is returned by the `backForwardList` property of `WebPage`【798010711766145†L20-L27】.

## Structure

`BackForwardList` conforms to `Sequence` and `Sendable`, so you can iterate over it and send it across concurrency domains.  It exposes three key properties:

| Property | Description |
|---|---|
| `backList` | An array of `Item` values representing history entries before the current item.  Items are ordered from earliest to most recent; the last element is the item you would navigate to if the user pressed the back button【835982392567441†L16-L41】. |
| `currentItem` | The current `Item`, or `nil` if no pages have been loaded【293946834845821†L35-L37】. |
| `forwardList` | An array of `Item` values representing history entries after the current item.  Items are ordered from earliest to most recent; the first element is the next page if the user presses the forward button【852437560560683†L37-L39】. |

You can programmatically navigate to an item by passing it to the `go(to:)` method on `WebView`.  Updating the back/forward lists triggers updates to any SwiftUI views bound to them because `BackForwardList` is observable.

### `Item` struct

Each entry in the list is represented by a nested `BackForwardList.Item`.  An item contains:

* `id` – A stable identifier for the history entry.
* `initialURL` – The URL originally requested for the page.
* `url` – The current URL of the page (after redirects).
* `title` – The page’s title, if available.

Two items may have equal titles and URLs but are not necessarily considered equal if they represent distinct navigations【709345893648434†L30-L38】.

## Usage

In a browser‑like interface you might create buttons bound to the list:

```swift
@State private var page = WebPage()

var body: some View {
    HStack {
        Button(action: { if let item = page.backForwardList.backList.last { webView.go(to: item) } }) {
            Image(systemName: "chevron.left")
        }.disabled(page.backForwardList.backList.isEmpty)
        Button(action: { if let item = page.backForwardList.forwardList.first { webView.go(to: item) } }) {
            Image(systemName: "chevron.right")
        }.disabled(page.backForwardList.forwardList.isEmpty)
    }
    WebView(page)
}
```

Because `BackForwardList` is observable, the disabled state of the buttons updates automatically when the user navigates.
