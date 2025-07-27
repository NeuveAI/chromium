# Adopting Liquid Glass (iOS 26)

## Overview

Liquid Glass is a new dynamic material introduced with iOS 26 and other Apple platforms.  It combines the optical properties of glass with fluidity and forms a functional layer that floats above your content, separating navigation and controls from the underlying content.  Standard components such as bars, sheets and controls adopt this material automatically when you build and run your app with the latest SDK【Adopting_Liquid_Glass.md†L5-L13】.  Liquid Glass blurs and reflects the colours and light of content behind it and reacts to touch and pointer interactions.

### Use system frameworks

When you rebuild your app with the latest SDK and use standard components from **SwiftUI**, **UIKit** or **AppKit**, these elements automatically adopt Liquid Glass【Adopting_Liquid_Glass.md†L5-L13】.  The system also adapts the material dynamically based on overlap, focus state and accessibility preferences, so you gain the benefits of the new design with minimal code.

### Minimise custom backgrounds

Liquid Glass works best when it isn’t obstructed.  Custom backgrounds or appearances on navigation elements (such as split views, tab bars and toolbars) may overlay or interfere with Liquid Glass and the new scroll‑edge effect【Adopting_Liquid_Glass.md†L5-L13】.  Audit your interface and remove or simplify custom effects to let the system provide the appropriate glass appearance.  Prefer using the default appearance of navigation stacks, split views and toolbars, and rely on standard view modifiers like `.toolbar` to customise content.

### Test with accessibility settings

Transparency and fluid morphing animations contribute to the look and feel of Liquid Glass.  However, users can enable accessibility options that reduce transparency or motion.  Standard components automatically adapt, but custom views must provide fallbacks.  Ensure that your custom effects remain legible and usable when transparency or motion is reduced【Adopting_Liquid_Glass.md†L15-L18】.

### Avoid overuse

Liquid Glass is intended to draw attention to key controls and navigation.  Applying the effect too broadly can distract from your content.  Use Liquid Glass sparingly and limit it to the most important functional elements【Adopting_Liquid_Glass.md†L19-L21】.  For guidance on applying the effect to custom components, refer to the dedicated article “Applying Liquid Glass to custom views”.

## Visual refresh and controls

### Updated materials and shapes

• **Material** – Liquid Glass is now the primary material across bars, sheets and controls.  It blurs the content behind it and reacts to interactions.
• **Shapes** – Concentric design aligns radii and margins to hardware bezels and provides unified rhythms across platforms.  Controls often adopt rounder forms and offer extra‑large sizes to accommodate bigger labels and accents.
• **App icons** – Icons are layered and respond to lighting.  The system offers default, dark, clear and tinted appearance variants to let people personalise their Home Screen【Adopting_Liquid_Glass.md†L27-L29】.

### Menus and toolbars

Toolbars and menus adopt a glass appearance and encourage grouping related items.  When using toolbars:

* **Use standard icons** – Find an appropriate SF Symbol for each action so the toolbar remains compact and recognisable.  Provide accessibility labels for icons.
* **Group logically** – Organise items based on function and frequency of use, using fixed spacers to separate groups.
* **Avoid custom backgrounds** – Remove background colours from custom toolbars and tab bars.  Use layout, grouping and tints to express hierarchy instead of decoration【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Primary actions** – Tint primary actions so they stand out【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Remove clutter** – Rely on Liquid Glass and the scroll‑edge effect instead of hard dividers; let carousels and content glide behind sidebars【WWDC_Get_to_know_new_design_system.md†L16-L17】.

### Colour and spacing

Being judicious with colour ensures controls remain legible and keep the focus on your content.  In controls and navigation, apply colour sparingly; when you do, use system colours so they adapt to light and dark appearances automatically【Adopting_Liquid_Glass.md†L41-L43】.  Avoid overcrowding or layering elements; give Liquid Glass room to move and breathe【Adopting_Liquid_Glass.md†L41-L43】.

## Navigation

Liquid Glass occupies the topmost layer of your interface; navigation elements float in this layer to help people focus on underlying content.  Key guidelines include:

* **Separate navigation from content** – Establish a clear hierarchy by keeping tab bars, sidebars and other navigation elements distinct from content【Adopting_Liquid_Glass.md†L49-L50】.
* **Adaptive navigation** – Consider allowing a tab bar to adapt into a sidebar when context requires it.  In SwiftUI, use `TabViewStyle.sidebarAdaptable` to allow automatic adaptation【Adopting_Liquid_Glass.md†L49-L52】.
* **Split views** – Use `NavigationSplitView` and the inspector APIs to build sidebar layouts with an inspector panel.  This creates a consistent experience across platforms and lets content flow behind sidebars and inspectors【Adopting_Liquid_Glass.md†L51-L52】.
* **Safe areas and background extension** – Audit safe area compatibility for content adjacent to sidebars and inspectors so underlying content peeks through appropriately.  Apply a **background extension effect** to mirror adjacent content under a sidebar or inspector, producing a blur that preserves legibility【Adopting_Liquid_Glass.md†L52-L52】.

## Colour and brand‑specific customisation

Liquid Glass adapts to context by reflecting underlying colours.  For brand differentiation:

1. **Use tinted appearances** – The system provides tinted variants for bars and icons.  Choose a tint colour that matches your brand, and apply it through view modifiers or asset catalog settings so it adapts to light and dark modes.
2. **Define accent colour** – In SwiftUI, set your app’s `accentColor` to a brand colour.  Primary buttons and highlights adopt this accent colour automatically.
3. **Apply tint to Liquid Glass components** – When using custom views with the glass effect, specify a tint colour in the `glassEffect` modifier to suggest prominence.  The system blends this tint into the glass material to maintain the Liquid Glass look (see the “Applying Liquid Glass to custom views” file).
4. **Respect contrast** – Ensure that tinted or coloured surfaces provide adequate contrast for text and icons.  Avoid saturating large surfaces; instead, highlight individual controls or small groups.

By following these guidelines, you can adopt Liquid Glass while retaining your brand’s unique character.