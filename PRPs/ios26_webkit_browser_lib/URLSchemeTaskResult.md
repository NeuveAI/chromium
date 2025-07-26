# URLSchemeTaskResult

`URLSchemeTaskResult` is an enumeration used by a `URLSchemeHandler` to provide the results of loading a resource with a custom URL scheme.  Each result in the sequence represents either the response headers or a chunk of body data.  The enum conforms to `Sendable`, allowing it to cross concurrency boundaries safely【195357851629370†L24-L29】.

## Purpose

When WebKit encounters a resource with a custom scheme, it calls your handler’s `reply(for:)` method.  You return a sequence of `URLSchemeTaskResult` values.  WebKit processes each value in order until the sequence finishes or is cancelled.  According to the documentation, each value can be either a `Data` or a `URLResponse`【195357851629370†L24-L29】.

## Enumeration cases

Although Apple’s JSON documentation does not list the cases individually, the API uses two cases:

* **`response(URLResponse)`** – The response to return to WebKit.  You must set the `URLResponse.mimeType` property to the MIME type of the resource【195357851629370†L38-L40】.
* **`data(Data)`** – A chunk of body data for the resource.  You may yield multiple `data` values to stream large resources.

After yielding a `response` value, your handler should yield one or more `data` values.  Once all data has been sent, the sequence ends.  If the sequence throws an error, WebKit treats the resource as failed.

## Example usage

See the `URLSchemeHandler` example in `URLSchemeHandler.md` for how to yield `URLSchemeTaskResult` values from a custom scheme handler.  By structuring your results in this way, you provide WebKit with the information it needs to render or download custom resources.
