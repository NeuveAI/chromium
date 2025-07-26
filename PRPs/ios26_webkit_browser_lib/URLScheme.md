# URLScheme

`URLScheme` is a struct representing a valid URL scheme.  You use it when registering custom URL schemes with a `WebPage.Configuration`.  Custom schemes let you integrate resources that WebKit doesn’t handle natively, such as files on the user’s device or app‑specific content.

## Rules for scheme names

The documentation specifies that scheme names are case sensitive, must start with an ASCII letter and may contain only ASCII letters, numbers, the “+” character, the “-” character and the “.” character【978657257748459†L12-L15】.  For example, `myapp`, `my-app+v1` and `local.file` are valid schemes.

## Usage

To register a custom scheme, create a `URLScheme` value and provide it along with a `URLSchemeHandler` to the `urlSchemeHandlers` dictionary in a `WebPage.Configuration`:

```swift
let scheme = URLScheme("myapp")!
config.urlSchemeHandlers = [scheme: MySchemeHandler()]
```

If the initializer returns `nil`, the string was not a valid scheme according to the rules above.  Once registered, any `myapp://` URL encountered in your `WebPage` will be delegated to your handler.
