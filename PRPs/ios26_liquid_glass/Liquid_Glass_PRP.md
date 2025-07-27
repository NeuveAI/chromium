# Liquid Glass UI PRP

## Purpose

Design and implement a SwiftUI user interface that adopts Apple’s **Liquid Glass** material (iOS 26+) while preserving a unique brand identity.  The interface should feature adaptive navigation, modern toolbars, and custom controls that leverage the `glassEffect` modifier.  This PRP provides the context and blueprint necessary for an AI agent to deliver a polished, accessible and brand‑aligned design.

## Core Principles

1. **Context is King** – Provide detailed documentation references and specific API calls.
2. **Validation Loops** – Define measurable success criteria and tests for UI behaviour and appearance.
3. **Information Density** – Use concrete SwiftUI components and patterns.
4. **Progressive Success** – Implement navigation and basic glass effects first, then refine with brand tinting and interactions.

---

## Goal

Build a SwiftUI interface that:
* Uses Liquid Glass for navigation bars, toolbars and key controls, letting content flow behind them.
* Provides an adaptive navigation hierarchy: a tab bar that becomes a sidebar on wider screens and may include an inspector panel.
* Implements custom controls (cards or buttons) with glass effects, tinted with the brand’s primary colour and optionally interactive.
* Groups multiple glass elements using `GlassEffectContainer` for performance and cohesive morphing.
* Ensures all layouts and effects remain accessible when transparency or motion reduction is enabled.

## Why

- **Modern aesthetics**: Liquid Glass is Apple’s new design language; adopting it ensures the app feels native and up to date【Adopting_Liquid_Glass.md†L5-L13】.
- **User immersion**: Glass allows content to flow behind navigation, reducing clutter and creating a sense of depth【WWDC_Get_to_know_new_design_system.md†L14-L18】.
- **Brand differentiation**: Tinting and custom shapes can infuse brand colours without overwhelming the interface【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
- **Adaptive design**: A single navigation structure scales across iPhone, iPad and Mac【Adopting_Liquid_Glass.md†L49-L50】.

## What

### User‑visible behaviour

- Navigation elements (tab bar/sidebar, toolbars) appear translucent and blurred, with content visible behind them.
- Toolbar items are organised logically and tinted to highlight primary actions【WWDC_Get_to_know_new_design_system.md†L9-L11】.
- A tab bar includes a dedicated search tab and adapts into a sidebar on larger screens【WWDC_Get_to_know_new_design_system.md†L12-L12】【Adopting_Liquid_Glass.md†L49-L51】.
- Custom cards/buttons showcase glass effects with brand tint and interactive responses.
- Background extension effects stretch content beneath sidebars and inspectors without distortion【Adopting_Liquid_Glass.md†L52-L52】.
- When accessibility settings reduce transparency or motion, controls fall back to opaque backgrounds and minimal animations【Adopting_Liquid_Glass.md†L15-L18】.

### Technical requirements

- Use `TabView` with `.tabViewStyle(.sidebarAdaptable)` to adapt between tab bar and sidebar【Adopting_Liquid_Glass.md†L49-L51】.
- Use `NavigationSplitView` and optionally `inspector(isPresented:content:)` to build a three‑pane layout【Adopting_Liquid_Glass.md†L50-L52】.
- Apply `backgroundExtensionEffect()` on sidebars/inspectors to extend content beneath them【Adopting_Liquid_Glass.md†L52-L52】.
- Implement toolbars using `.toolbar` with groups and fixed spacers; remove custom backgrounds; use tint for primary buttons【WWDC_Get_to_know_new_design_system.md†L9-L11】.
- Create custom views with `glassEffect()`; specify shapes and tint colours; use `.interactive()` for touch response【Applying_Liquid_Glass_to_Custom_Views.md†L5-L13】【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
- Use `GlassEffectContainer` to group glass views; adjust `spacing` to control merging【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.
- Use `glassEffectUnion(id:namespace:)` and `glassEffectID(_:in:)` to coordinate morphing effects across views【Applying_Liquid_Glass_to_Custom_Views.md†L69-L90】【Applying_Liquid_Glass_to_Custom_Views.md†L91-L100】.

### Success Criteria

- [ ] **Adaptive navigation**: The tab bar transforms into a sidebar on iPad/Mac and includes a search tab.
- [ ] **Logical toolbars**: Toolbars have grouped items separated by spacers; primary actions are tinted; no custom backgrounds【WWDC_Get_to_know_new_design_system.md†L9-L11】.
- [ ] **Brand‑tinted controls**: Custom glass components apply the brand colour subtly and react to touch【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
- [ ] **Background extension**: Content extends smoothly behind sidebars and inspectors with blur, maintaining legibility【Adopting_Liquid_Glass.md†L52-L52】.
- [ ] **Accessibility fallback**: When Reduce Transparency or Reduce Motion is enabled, the UI remains legible and functional【Adopting_Liquid_Glass.md†L15-L18】.

## All Needed Context

```yaml
- file: Adopting_Liquid_Glass.md
  why: Overall guidelines for adopting Liquid Glass, minimising custom backgrounds, handling colour and spacing, and navigation best practices【Adopting_Liquid_Glass.md†L5-L13】【Adopting_Liquid_Glass.md†L41-L43】.
- file: Applying_Liquid_Glass_to_Custom_Views.md
  why: How to apply `glassEffect`, tint, shapes, interactive variants and group effects【Applying_Liquid_Glass_to_Custom_Views.md†L5-L13】【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
- file: WWDC_Get_to_know_new_design_system.md
  why: Key tips from the WWDC 25 session on toolbars, scroll‑edge effect and sidebars【WWDC_Get_to_know_new_design_system.md†L9-L18】.
- file: SUMMARY.md
  why: Condensed summary of Liquid Glass adoption guidelines and key APIs.
```

### Known Gotchas & Library Quirks

```swift
// CRITICAL: Overuse of Liquid Glass can distract users; apply it sparingly【Adopting_Liquid_Glass.md†L19-L21】.
// CRITICAL: Remove custom background colours from tab bars and toolbars; rely on the glass material【Adopting_Liquid_Glass.md†L5-L13】【WWDC_Get_to_know_new_design_system.md†L9-L11】.
// CRITICAL: When Reduce Transparency is enabled, the system removes blur effects; custom controls must provide opaque alternatives【Adopting_Liquid_Glass.md†L15-L18】.
// Example: Use system colours for text/icons inside glass views; avoid saturating large surfaces【Adopting_Liquid_Glass.md†L41-L43】.
// Example: `GlassEffectContainer` merges shapes based on spacing; large spacing prevents merging【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
# The Liquid Glass UI is organised into navigation, components and branding modules
Sources/
├── Navigation/
│   ├── AppNavigation.swift     # Manages TabView/Sidebar with adaptive style
│   ├── SidebarLayout.swift     # Implements NavigationSplitView and inspector
│   └── Toolbars.swift          # Groups toolbar items and applies tint
├── Components/
│   ├── GlassCard.swift         # Reusable card view with glass effect and tinting
│   ├── GlassCardGroup.swift    # Uses GlassEffectContainer to merge multiple cards
└── Branding.swift              # Defines brand colours, shapes and accessibility fallbacks
Tests/
└── LiquidGlassUITests.swift    # UI tests for adaptive navigation, toolbars and glass effects
```

## Implementation Blueprint

### Data models and structure

- Define an enum `AppSection` with cases like `.home`, `.search`, `.settings` to represent top‑level tabs.
- Provide a `BrandStyle` struct containing colours (primary, secondary) and shape preferences.
- Use an `EnvironmentObject` to store user settings (JavaScript toggle, content mode, reduce transparency) and update the UI accordingly.

### List of tasks

```yaml
Task 1: Set up navigation
  CREATE Sources/AppNavigation.swift
    - Define a `NavigationModel` class with a `selectedSection: AppSection` property.
    - Implement a `TabView` with `.tabViewStyle(.sidebarAdaptable)` bound to `selectedSection`.
    - Add a search tab with appropriate label and icon.

Task 2: Implement sidebar and inspector
  CREATE Sources/SidebarLayout.swift
    - Use `NavigationSplitView` to separate sidebar and content.
    - Provide an optional inspector panel using `inspector(isPresented:content:)` for detail views.
    - Apply `backgroundExtensionEffect()` to the sidebar and inspector【Adopting_Liquid_Glass.md†L52-L52】.

Task 3: Build toolbars
  MODIFY Sources/AppNavigation.swift
    - Add `.toolbar` modifiers to each primary view.
    - Group toolbar items logically and insert fixed spacers.
    - Apply tint using `.tint(brandStyle.primary)` for primary actions.

Task 4: Create custom glass components
  CREATE Sources/Components/GlassCard.swift
    - Define a view that wraps content in `.glassEffect()`.
    - Accept parameters for `shape`, `tint` and `interactive` boolean.
    - Use brandStyle.primary to tint when `isProminent` is true.

Task 5: Group glass components
  MODIFY Sources/Components/GlassCard.swift
    - Provide a `GlassCardGroup` view that uses `GlassEffectContainer` to wrap multiple cards.
    - Expose a `spacing` parameter to control merging【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.

Task 6: Brand theming and accessibility
  CREATE Sources/Branding.swift
    - Set `accentColor(brandStyle.primary)` globally.
    - Provide alternative colours or shapes when `UIAccessibility.isReduceTransparencyEnabled` is true.

Task 7: Testing & validation
  CREATE Tests/LiquidGlassUITests.swift
    - Test navigation adaptation by rotating the simulator or using different devices.
    - Verify toolbars have no background colours and are tinted appropriately.
    - Check that glass cards merge when spacing is low and remain separate when spacing is high.
    - Validate that enabling Reduce Transparency switches to opaque backgrounds.
```

## Validation Loop

### Level 1: Compile and style

- Build the SwiftUI project; ensure there are no compiler errors or warnings.
- Optionally run SwiftLint to enforce style conventions.

### Level 2: UI tests

- Use `XCTest` and `XCUITest` to automate interactions.  Verify the navigation adapts on different devices and that toolbar items are correctly tinted and grouped.
- Test the behaviour when Reduce Transparency and Reduce Motion are enabled in the simulator.

### Level 3: Manual review

- Run the app on iPhone, iPad and Mac (via Mac Catalyst).  Visually inspect that Liquid Glass surfaces reflect content, tinted elements align with brand colours, and no custom backgrounds remain.

## Final validation checklist

- [ ] Adaptive navigation works across devices.
- [ ] Toolbars are logical, tint applied, no custom backgrounds.
- [ ] Glass components are tinted and interactive according to brand settings.
- [ ] Background extension effect is applied to sidebars and inspectors.
- [ ] Accessibility settings produce usable fallbacks.
