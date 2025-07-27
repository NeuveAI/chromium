# Product Requirements Document – Liquid Glass UI with Brand Customisation

## 1 Overview

Apple’s **Liquid Glass** material transforms the look and feel of interfaces across iOS 26, iPadOS, macOS and other platforms by creating a dynamic glass layer that blurs content beneath it, reflects colour and light, and reacts to interaction.  This document outlines the requirements for a new SwiftUI app that adopts Liquid Glass while retaining the company’s unique brand identity.  The app will present content through adaptive navigation and polished controls, using the latest SwiftUI and iOS 26 APIs.

## 2 Problem statement

Our current app design relies on custom backgrounds and static controls that do not take advantage of the dynamic Liquid Glass material introduced in iOS 26.
Users expect a modern, fluid interface consistent with system apps.  At the same time, the design must communicate our brand through colour and thoughtful detailing without looking generic.

## 3 Goals

1. **Adopt Liquid Glass:** Integrate Liquid Glass across navigation, toolbars and key controls to align with Apple’s latest design system.
2. **Retain brand identity:** Use brand colours and shapes tastefully through tinting and accent colours to differentiate the app【Adopting_Liquid_Glass.md†L41-L43】.
3. **Simplify navigation:** Implement adaptive navigation that scales across iPhone, iPad and Mac using SwiftUI’s new navigation APIs【Adopting_Liquid_Glass.md†L49-L52】.
4. **Enhance user experience:** Provide responsive interactions and fluid animations while respecting accessibility settings【Adopting_Liquid_Glass.md†L15-L18】.

## 4 Target users

* **Existing users** familiar with the brand who expect a refreshed look and feel.
* **New users** drawn to the modern, immersive interface offered by Liquid Glass.
* **Accessibility users** who require reduced motion or transparency.

## 5 User stories

1. *As a user, I want to navigate through the app using a clear and consistent set of tabs or sidebars, so I can find information quickly.*
2. *As a user, I want the interface to feel light and immersive, with content flowing behind navigation, so that I can focus on what matters.*
3. *As a user, I want the brand’s colour to appear in key places (e.g. primary buttons) without overwhelming the interface, so that I feel connected to the brand.*
4. *As a user with reduced motion enabled, I want a version of the interface that remains usable without fluid animations or transparency.*

## 6 Functional requirements

1. **Adaptive navigation:**
   * Use `TabView` with `TabViewStyle.sidebarAdaptable` to provide a tab bar that becomes a sidebar on larger screens【Adopting_Liquid_Glass.md†L49-L51】.
   * Implement `NavigationSplitView` to separate navigation from content and to optionally include an inspector panel【Adopting_Liquid_Glass.md†L50-L52】.
   * Include a search tab for quick access【WWDC_Get_to_know_new_design_system.md†L12-L12】.

2. **Toolbars and menus:**
   * Provide toolbars with logically grouped items and no custom backgrounds【WWDC_Get_to_know_new_design_system.md†L9-L11】.
   * Use SF Symbols for toolbar icons and supply accessibility labels.
   * Tint primary actions with the brand’s primary colour【WWDC_Get_to_know_new_design_system.md†L9-L11】.

3. **Liquid Glass components:**
   * Apply `.glassEffect()` to navigation bars, toolbars and custom views.  Use shapes appropriate to the size of the component【Applying_Liquid_Glass_to_Custom_Views.md†L5-L13】.
   * Create custom controls (buttons, cards) with tinted and interactive glass effects【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
   * Group multiple glass views in a `GlassEffectContainer` for better performance and cohesive morphing【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.
   * Unite effects across disparate views using `glassEffectUnion` and animate transitions with `glassEffectID`【Applying_Liquid_Glass_to_Custom_Views.md†L69-L90】【Applying_Liquid_Glass_to_Custom_Views.md†L91-L100】.

4. **Brand theming:**
   * Set the global `accentColor` to the brand’s primary colour.
   * Provide tinted bar and glass appearances using the same colour.  Ensure tinted surfaces remain legible and accessible.
   * Avoid saturating large surfaces; apply colour to key controls and highlights【Adopting_Liquid_Glass.md†L41-L43】.

5. **Accessibility and fallback:**
   * Detect when transparency or motion reduction is enabled and fall back to static backgrounds and simpler animations【Adopting_Liquid_Glass.md†L15-L18】.
   * Support dynamic type and provide descriptive labels for all icons and buttons.

## 7 Non‑functional requirements

* **Performance:** The interface must scroll smoothly and animate at 60 fps on current devices.  Use `GlassEffectContainer` to optimise rendering of multiple glass effects【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.
* **Scalability:** The layout must adapt to different screen sizes and support iPad multitasking and Mac Catalyst windows without layout changes.
* **Maintainability:** Use only SwiftUI APIs; avoid UIKit bridging to simplify future updates.
* **Security:** No network or sensitive data is exposed through the UI.  All views present local or computed content.

## 8 Success metrics

* **User satisfaction:** Measured through post‑update reviews and user testing feedback.
* **Adoption rate:** Percentage of existing users who update to the new version within the first month.
* **Performance metrics:** Average frames per second during typical navigation; should remain above 55 fps.
* **Accessibility compliance:** Pass Apple’s accessibility audits; no WCAG level AA violations related to contrast or motion.

## 9 Risks and mitigations

* **Overuse of Liquid Glass:** The design may become cluttered if Liquid Glass is applied too broadly.  **Mitigation:** apply glass only to navigation elements and a few key controls; emphasise content.
* **Colour clash:** Brand colours may reduce legibility on glass surfaces.  **Mitigation:** test tints in light and dark modes; adjust brightness and saturation; leverage system colours when necessary【Adopting_Liquid_Glass.md†L41-L43】.
* **Performance overhead:** Multiple glass effects could impact performance.  **Mitigation:** group views in `GlassEffectContainer` and reuse effects where possible【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.

## 10 Timeline and milestones

1. **Design specification (Week 1–2):** Finalise navigation structure, colour palette and glass usage guidelines.
2. **Prototype (Week 3–4):** Implement basic navigation and apply Liquid Glass to standard components.  Create custom glass components.
3. **Brand integration (Week 5–6):** Apply tinting and accent colours; refine toolbars and menus.
4. **Accessibility & testing (Week 7–8):** Test with accessibility settings; optimise performance; gather user feedback.
5. **Release (Week 9):** Finalise and submit the update to the App Store.

## 11 Future considerations

* **Adaptive home screen widgets** using Liquid Glass for dynamic widget surfaces.
* **Cross‑platform support** for visionOS when Liquid Glass becomes available there.
* **Dynamic theming** where users can select from multiple brand colour themes within the app.

This PRD defines a clear path to adopting Apple’s Liquid Glass design language while maintaining brand differentiation.  Adhering to these requirements will result in a modern, accessible and coherent user experience.
