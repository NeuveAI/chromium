# Applying Liquid Glass to Custom Views

## Overview

Liquid Glass isn’t limited to bars and system controls – you can add the material to your own components.  The **`glassEffect(_:in:)`** modifier in SwiftUI renders Liquid Glass behind a view, capturing and blurring the content underneath and reflecting its colours【Applying_Liquid_Glass_to_Custom_Views.md†L5-L13】.  This modifier uses the **regular** variant of the `Glass` material by default and applies the effect within a capsule shape.

### Basic usage

Apply the `.glassEffect()` modifier directly to any view to give it a Liquid Glass background.  For example:

```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()
```

The system captures content behind the text, blurs it and applies a glass sheen.  Because the glass layer is dynamic, it reacts to touches and pointer interactions automatically.

### Configuring the shape

You can customise the shape of the glass layer to match your design.  Use the `in` parameter of `glassEffect` to supply a shape; the default is a capsule.  For larger components, specify a rounded rectangle or custom shape to avoid awkward capsules:

```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect(in: .rect(cornerRadius: 16))
```

### Tinting for prominence

To suggest that a control is primary or to infuse brand colour, define a tint colour on the glass effect.  Specify the variant before calling `.interactive()` for interactive behaviour:

```swift
Text("Pay")
    .padding()
    .glassEffect(.regular.tint(.orange).interactive())
```

Tinting the glass effect applies a subtle colour overlay that stands out while preserving the blurred, glassy appearance【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.  Use this sparingly to emphasise primary actions and reflect your brand palette.

### Interactivity

Adding `.interactive()` to the glass effect causes the glass to respond to touches and pointer movements with fluid motion and highlights【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.  The interactive variant uses the same responsive reactions as the new **glass button style**.  Use this for buttons and controls that people interact with directly.

### Combining multiple glass views

When several views have Liquid Glass effects, group them in a **`GlassEffectContainer`**.  A container optimises rendering performance and enables multiple glass shapes to merge or morph into each other.  Place your views inside a container and supply a spacing value:

```swift
GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "scribble.variable")
            .frame(width: 80, height: 80)
            .font(.system(size: 36))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 80, height: 80)
            .font(.system(size: 36))
            .glassEffect()
            .offset(x: -40, y: 0)  // demonstrates how proximity merges effects
    }
}
```

Views that are close together merge their glass effects into a single shape.  Increase spacing to separate shapes; reduce spacing to make them merge sooner【Applying_Liquid_Glass_to_Custom_Views.md†L49-L67】.  Use this behaviour to create fluid transitions and group related elements.

### Uniting effects across disparate views

Sometimes you want different views to contribute to the same glass shape even when they aren’t adjacent.  Use **`glassEffectUnion(id:namespace:)`** to unite glass effects with a common identifier within a `Namespace`.  This is useful when generating views dynamically or when grouping shapes across layouts【Applying_Liquid_Glass_to_Custom_Views.md†L69-L90】.

```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 20) {
    HStack(spacing: 20) {
        ForEach(symbolSet.indices, id: \.​self) { index in
            Image(systemName: symbolSet[index])
                .frame(width: 80, height: 80)
                .font(.system(size: 36))
                .glassEffect()
                .glassEffectUnion(id: index < 2 ? "group1" : "group2", namespace: namespace)
        }
    }
}
```

SwiftUI unites all glass effects with the same ID into a single shape, creating complex morphing animations when views appear or disappear.

### Morphing effects during transitions

To animate between different glass shapes during view transitions, use **`glassEffectID(_:in:)`**.  Assign a unique ID within the same namespace to each glass effect; SwiftUI animates shapes with matching IDs across transitions【Applying_Liquid_Glass_to_Custom_Views.md†L91-L100】.  This is particularly effective in navigation stacks and interactive lists.

### Best practices for brand customisation

When customising Liquid Glass components to match your brand:

1. **Choose an appropriate shape** – Align your glass shapes with your app’s visual language.  For example, a rounded rectangle may reflect your brand better than a capsule.
2. **Select a subtle tint** – Use your brand’s primary colour as a tint on the glass effect to suggest prominence without overpowering content【Applying_Liquid_Glass_to_Custom_Views.md†L31-L41】.
3. **Combine with accent colour** – Set your app’s global `accentColor` so that text and symbols inside the glass effect adopt your brand colour.  The tinted glass will harmonise with these accents.
4. **Balance interactivity** – Apply the interactive variant only to controls that need expressive feedback.  Overusing interactivity can be distracting.
5. **Use containers** – Group related glass elements in `GlassEffectContainer` to create cohesive morphing surfaces and to optimise performance.

By applying these techniques, you can craft unique custom views that feel at home in the Liquid Glass design language while expressing your brand identity.