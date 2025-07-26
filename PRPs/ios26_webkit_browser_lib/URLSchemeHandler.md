# URLSchemeHandler

`URLSchemeHandler` is a protocol that enables you to load resources using custom URL schemes not handled by WebKit.  By implementing this protocol and registering an instance in a `WebPage.Configuration`, you can provide content for URLs such as `myapp://photo/123` or `localfile://path/to/document`.

## Overview

The documentation states that you adopt `URLSchemeHandler` in types that handle custom URL schemes for your web content.  Custom schemes let you integrate resource types that are available only on the user’s device (like photos) or that your app defines【900665326928297†L19-L45】.  When a page encounters a resource using a custom scheme, it passes the `URLRequest` to the scheme handler and expects a stream of responses and data【900665326928297†L35-L40】.

## Registering handlers

You register custom scheme handlers via the `urlSchemeHandlers` property on `WebPage.Configuration`:

```swift
let scheme = URLScheme("myapp")!
struct PhotoHandler: URLSchemeHandler {
    func reply(for request: URLRequest) -> TaskSequence {
        // Provide a sequence of URLSchemeTaskResult values
    }
}
config.urlSchemeHandlers = [scheme: PhotoHandler()]
let page = WebPage(configuration: config)
```

## Implementing the protocol

The protocol defines an associated type `TaskSequence`, which must conform to `AsyncSequence` and yield `URLSchemeTaskResult` values.  You implement the required method `reply(for:)` to return a sequence of responses and data for each request.  WebKit calls this method whenever it encounters your scheme.

Inside your sequence you typically yield a `URLSchemeTaskResult.response(URLResponse)` to provide headers and MIME type, followed by one or more `URLSchemeTaskResult.data(Data)` values containing the body.  When the sequence finishes, WebKit treats the resource as fully loaded.  If WebKit decides it no longer needs the resource (for example, because the user navigated away), it cancels the task【900665326928297†L41-L45】.

## Example sequence

Here’s a simplified implementation that serves files from the app bundle:

```swift
struct BundleFileHandler: URLSchemeHandler {
    func reply(for request: URLRequest) -> TaskSequence {
        return TaskSequence {
            guard let url = request.url,
                  let fileURL = Bundle.main.url(forResource: url.lastPathComponent, withExtension: nil),
                  let data = try? Data(contentsOf: fileURL) else {
                // Not found
                throw URLError(.fileDoesNotExist)
            }
            let response = URLResponse(url: url, mimeType: "application/octet-stream", expectedContentLength: data.count, textEncodingName: nil)
            yield .response(response)
            yield .data(data)
        }
    }
}
```

This sequence first yields a `URLResponse` describing the file, then yields the file’s data.  When used with `URLSchemeHandler`, your web view can load `bundlefile://filename` URLs and display their contents.

Implementing `URLSchemeHandler` allows your app to seamlessly integrate custom resource types into your web content and is essential for building offline or app‑bound web experiences.
