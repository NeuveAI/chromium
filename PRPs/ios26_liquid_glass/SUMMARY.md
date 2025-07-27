# Summary – Building a Liquid Glass UI in iOS 26

This summary synthesises the official Apple documentation and WWDC 25 insights on Liquid Glass to highlight the essential guidelines for creating a user interface that embraces the new design language while retaining your brand’s unique identity.

## Adopt Liquid Glass through standard components

* **Use the latest SDK** – Build your app in the latest Xcode with iOS 26 to automatically adopt Liquid Glass for bars, sheets and controls【Adopting_Liquid_Glass.md†L5-L13】.
* **Rely on system frameworks** – Standard components in SwiftUI, UIKit and AppKit dynamically adapt Liquid Glass based on overlap, focus and accessibility settings【Adopting_Liquid_Glass.md†L5-L13】.

## Remove custom backgrounds and reduce clutter

* **Let the system provide glass** – Custom backgrounds on navigation elements can interfere with Liquid Glass and the new scroll‑edge effect.  Remove them and use the default appearance for navigation stacks, split views, tab bars and toolbars【Adopting_Liquid_Glass.md†L5-L13】.
* **Avoid overuse** – Apply Liquid Glass sparingly; reserve it for key controls and navigation to avoid distracting from content【Adopting_Liquid_Glass.md†L19-L21】.

## Structure menus and toolbars thoughtfully

* **Group and organise items** – Use logical grouping and fixed spacers to arrange toolbar items.  Remove decorative backgrounds, rely on layout, and use tint to highlight primary actions【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Use standard icons and accessibility labels** – Choose appropriate SF Symbols for toolbar actions and provide labels for assistive technologies.

## Colour and brand customisation

* **Be judicious with colour** – Keep controls legible by limiting the use of colour and leveraging system colours that adapt to light and dark modes【Adopting_Liquid_Glass.md†L41-L43】.
* **Tint for prominence** – Use `glassEffect(.regular.tint(_))` on custom views or rely on tinted bar appearances to infuse your brand colour into Liquid Glass surfaces【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
* **Define an accent colour** – Set your app’s `accentColor` to your brand’s primary colour so interactive elements adopt it automatically.

## Applying Liquid Glass to custom components

* **Use `.glassEffect()`** – Add Liquid Glass behind any SwiftUI view; by default it uses a capsule shape【Applying_Liquid_Glass_to_Custom_Views.md†L5-L13】.
* **Customise shape and tint** – Provide a shape parameter to the `glassEffect` modifier and specify a tint to match your brand【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
* **Enable interaction** – Add `.interactive()` for fluid reactions to touch and pointer input【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
* **Group effects in containers** – Wrap multiple glass views in a `GlassEffectContainer` to optimise rendering and allow shapes to merge or morph into one another【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.

## Navigation and layout

* **Separate navigation from content** – Maintain a clear hierarchy where tab bars and sidebars float above the content layer【Adopting_Liquid_Glass.md†L49-L50】.
* **Adopt adaptive navigation** – Use `TabViewStyle.sidebarAdaptable` and `NavigationSplitView` to let tab bars become sidebars on larger devices【Adopting_Liquid_Glass.md†L49-L52】.
* **Extend content beneath sidebars** – Use background extension effects so content can flow behind sidebars without losing legibility【Adopting_Liquid_Glass.md†L52-L52】.

## Tools for SwiftUI developers

* **glassEffect** – Modifier to apply Liquid Glass to any view with optional shape and tint parameters.
* **GlassEffectContainer** – Groups multiple glass views and merges their shapes.
* **glassEffectUnion** and **glassEffectID** – Coordinate multiple glass views and animate transitions across view hierarchy changes【Applying_Liquid_Glass_to_Custom_Views.md†L69-L90】【Applying_Liquid_Glass_to_Custom_Views.md†L91-L100】.

By following these guidelines, you can build an interface that feels at home in Apple’s new design system while expressing your brand through thoughtful colour, shape and layout choices.