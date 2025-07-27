# Key Insights from “Get to know the new design system” (WWDC 25)

## Context

The WWDC 25 session “Get to know the new design system” introduced Liquid Glass and highlighted how Apple’s design language evolves across platforms.  The transcript emphasises several practical guidelines for adopting the new design in your apps.

## Toolbar and tab bar guidelines

* **Remove custom backgrounds** – The session urges developers to **remove background colours** from custom toolbars and tab bars.  Instead of decorating bars with opaque colours, rely on layout and grouping to express hierarchy【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Organise items logically** – Arrange bar items based on their function and frequency of use.  Group related actions together using fixed spacers to make them easier to scan【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Use tint to highlight primary actions** – Tint important buttons or icons so they stand out.  Primary actions should be visually distinct from secondary commands【WWDC_Get_to_know_new_design_system.md†L9-L11】.
* **Well‑structured tab bars** – Tab bars should include a dedicated search tab (new to iOS) and reflect a clear structure【WWDC_Get_to_know_new_design_system.md†L12-L12】.

## Scroll edge and sidebars

* **Scroll‑edge effect** – Liquid Glass works with the new scroll‑edge effect, which replaces hard dividers with a **subtle blur** to reduce visual clutter【WWDC_Get_to_know_new_design_system.md†L16-L16】.
* **Content behind sidebars** – Scroll views now extend beneath sidebars by default, allowing carousels and other content to **glide through**.  Sidebars are inset and built with Liquid Glass, so content can flow behind them for a more immersive feel【WWDC_Get_to_know_new_design_system.md†L17-L17】.
* **Background extension effects** – Background extension effects allow content to **expand behind sidebars**, giving the impression of stretching the background under the sidebar.  Ensure text and controls are layered above to avoid distortion【WWDC_Get_to_know_new_design_system.md†L18-L18】.

## Design principles

The talk also underlines broader design principles:

* **Dynamic hierarchy** – The new system reshapes the relationship between interface and content, using Liquid Glass to separate controls from underlying content while letting the two interact.
* **Consistency across devices** – Shared heuristics ensure designs scale gracefully across iPhone, iPad, and Mac, maintaining continuity and familiarity.

These insights complement the guidance in the documentation and provide a practical lens through which to adopt Liquid Glass in your own apps.