# DeviceSensorAuthorization

`DeviceSensorAuthorization` is a struct that describes which device sensors a web resource is authorised to access.  When you configure a `WebPage`, you can supply a `DeviceSensorAuthorization` to restrict or allow access to motion sensors and media capture devices such as the camera and microphone.  This helps enforce user privacy and comply with system policies.

## Overview

The documentation says that this type “describes the authorization permissions policy for the device’s sensors a web resource may access”【987514520325437†L14-L15】.  It encapsulates a set of `Permission` values representing individual sensor permissions.

## Permissions enumeration

`DeviceSensorAuthorization` defines a nested `Permission` enumeration.  Each case specifies a type of sensor or media capture device the page might request:

| Case | Description | Source |
|---|---|---|
| `.deviceOrientationAndMotion` | Grants or denies access to orientation and motion sensors (accelerometer, gyroscope).  These sensors allow a webpage to detect device movement【198410538138285†L18-L78】. |
| `.mediaCapture(_ type: WKMediaCaptureType)` | Grants or denies access to media capture devices such as the camera or microphone.  The `WKMediaCaptureType` parameter specifies whether the permission applies to video, audio or both【198410538138285†L18-L78】. |

You construct a `DeviceSensorAuthorization` by supplying an array of permissions:

```swift
let sensors = DeviceSensorAuthorization([.deviceOrientationAndMotion, .mediaCapture(.video)])
var config = WebPage.Configuration()
config.deviceSensorAuthorization = sensors
```

If you omit a permission, WebKit denies access to that sensor.  Using this API ensures that sensitive device data is exposed only when explicitly authorised.
