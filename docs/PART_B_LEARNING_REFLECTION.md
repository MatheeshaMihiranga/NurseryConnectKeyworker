# SE4020 – Assignment 02 Part B: Learning Reflection
## NurseryConnect Vision — visionOS Development Learning Journey

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **Module** | SE4020 — Mobile Application Design & Development |
| **Assignment** | Assignment 02 — Part B: Learning Reflection |
| **Word Count** | ~1,200 words |
| **Date** | June 2026 |

---

## 1. Introduction

This reflection documents my learning journey through the visionOS portion of Assignment 02 — the development of *NurseryConnect Vision*, a spatial computing prototype for Apple Vision Pro. Prior to this assignment, my experience with spatial computing was zero. My background was in standard SwiftUI/UIKit development for iPhone and iPad. Learning visionOS required me to discard several assumptions I had formed about mobile UI and rebuild my mental model from first principles.

This reflection is structured around three curated learning resources I used throughout the project, followed by a critical evaluation of what I learned, what I struggled with, and how this experience will shape my future practice.

---

## 2. Curated Learning Resources

### Resource 1 — WWDC23: "Develop your first immersive app" (Apple Developer, 2023)

**Reference:** Apple Inc. (2023). *Develop your first immersive app* [WWDC23 Session 10203]. Apple Developer. https://developer.apple.com/wwdc23/10203

**What it covers:** This session walks through creating a visionOS app from scratch in Xcode 15 using the visionOS SDK. It covers the visionOS app lifecycle (`WindowGroup`, `ImmersiveSpace`), the difference between `.mixed`, `.full`, and `.progressive` immersion styles, and the basics of `RealityView` for embedding RealityKit content inside a SwiftUI view hierarchy.

**How I used it:** This was my entry point to visionOS. Before watching this session, I had incorrectly assumed that visionOS apps were simply SwiftUI apps with a different colour scheme. The session immediately corrected this: visionOS introduces two entirely new scene types (`ImmersiveSpace` being the key one) that have no equivalent in iOS. The `RealityView` closure-based API — where the scene is built asynchronously in a `make` closure and updated in an `update` closure — is unlike any SwiftUI pattern I had used before.

The session's explanation of the content world (the persistent passthrough layer where windows float) versus the immersive space (a full RealityKit scene replacing the pass-through) was the conceptual breakthrough I needed. It told me exactly where to put the parabolic panel layout (in the immersive space) versus the always-on dashboard (in a standard `WindowGroup`).

**Critical evaluation:** The session uses Xcode 15 and visionOS 1.0 APIs. By the time of this assignment (visionOS 2, Xcode 26), some APIs had changed — notably `PKToolPicker` initialisation and certain `Entity` component APIs. I had to cross-reference with the visionOS 2 release notes to identify which session examples were still valid. The session is excellent for conceptual grounding but should always be supplemented with the current SDK documentation.

---

### Resource 2 — WWDC23: "Principles of spatial design" (Apple Developer, 2023)

**Reference:** Apple Inc. (2023). *Principles of spatial design* [WWDC23 Session 10072]. Apple Developer. https://developer.apple.com/wwdc23/10072

**What it covers:** This is a design-focused (not code-focused) session from Apple's design team. It covers the fundamental principles that differentiate spatial UI from flat UI: comfortable viewing distances (0.5–2m), the importance of keeping content within the user's natural field of view (120° forward arc), how scale communicates meaning differently in 3D, and why glass materials (translucent, backgrounded) are the correct choice for floating panels.

**How I used it:** This session directly shaped every placement decision in `ImmersiveChildPanelsView`. The parabolic arc formula I used — `zOffset = -0.06 * pow(xOffset, 2)` — was directly inspired by the session's explanation of why a flat horizontal layout of panels feels unnatural in a spatial context. Flat arrays of objects at different horizontal angles require the viewer to turn their head, which is fatiguing. A gentle inward curve (parabola) keeps all panels at approximately equal angular distance from the viewer's eye line, matching the natural geometry of peripheral vision.

The session also informed my decision to use `.mixed` immersion rather than `.full`. For a nursery keyworker, maintaining awareness of the physical room — the children, the furniture, the other staff — is a safety requirement. A fully immersive experience that occludes the real world would be unsafe in a nursery environment. The `Principles of spatial design` session explicitly states that `.mixed` immersion is appropriate for productivity applications where users need to remain contextually aware.

**Critical evaluation:** This session is prescriptive and Apple-centric. It presents Apple's spatial design philosophy as if it were objective truth. Alternative perspectives — for example, Microsoft's HoloLens mixed reality design guidelines, which take a different approach to content placement distances and user agency — are not represented. A well-rounded spatial design education should include cross-platform perspectives. That said, since the NurseryConnect Vision prototype targets Vision Pro specifically, following Apple's own guidelines was both appropriate and necessary for the submission.

---

### Resource 3 — Apple Developer Documentation: "Hello World (visionOS sample app)" (Apple Developer, 2024)

**Reference:** Apple Inc. (2024). *Hello World: Use windows, volumes, and immersive spaces to teach people about the Earth* [visionOS sample code]. Apple Developer. https://developer.apple.com/documentation/visionos/world

**What it covers:** Apple's official visionOS sample application, `Hello World`, is the most complete working reference for the major visionOS UI patterns: windows, volumes, and immersive spaces. The source code (available on Apple Developer) demonstrates `RealityView`, `InputTargetComponent`, `CollisionComponent`, `SpatialTapGesture`, `openImmersiveSpace` / `dismissImmersiveSpace`, and `@Observable AppModel` state shared between scenes.

**How I used it:** The `Hello World` sample was my primary reference implementation when writing `ImmersiveChildPanelsView`. Two specific patterns from the sample were directly applied:

1. **`InputTargetComponent` + `CollisionComponent` combination**: The sample shows that for an entity to be tappable in visionOS, it must have both components. `InputTargetComponent` declares the entity is interactive; `CollisionComponent` provides the hit-testing geometry. Adding only one of the two silently fails — the entity does not respond to gestures. This was a subtle bug I would not have found without the sample code.

2. **`AppModel` as a shared `@Observable` state container injected via `.environment(AppModel())`**: The `Hello World` sample uses this exact pattern to share `showImmersiveSpace: Bool` between the `WindowGroup` and `ImmersiveSpace`. I replicated this in `NurseryConnectVisionApp.swift` and `AppModel.swift`, which resolved the problem of how the dashboard's "Enter Immersive Mode" button could toggle state visible to the immersive space.

**Critical evaluation:** `Hello World` targets a relatively simple use case (displaying information about the Earth). It does not demonstrate multi-entity interaction (selecting one panel out of several), hit-testing disambiguation when entities overlap, or shared state between SwiftUI sheets and RealityKit entities. For those scenarios I had to extrapolate from the sample's patterns and iterate through several failed approaches. The RealityKit documentation for visionOS is still maturing compared to the depth of SwiftUI documentation, and several aspects required trial-and-error rather than documentation-guided development.

---

## 3. What I Learned

**Spatial thinking requires a new mental model.** The most significant learning was conceptual rather than technical. Two-dimensional UI design is fundamentally about layout on a flat canvas. Spatial UI design is about *placement in a volume* — distance matters, angle matters, the relationship between objects in physical space matters. I found myself sketching 3D diagrams on paper for the first time during a software module, which was unfamiliar but ultimately more effective than wireframing for reasoning about the parabolic arc layout.

**SwiftUI and RealityKit have different animation philosophies.** SwiftUI's animation system (`.animation()`, `withAnimation`) does not propagate into RealityKit entity transforms. This was the most technically costly discovery: I wrote the scale pulse animation using `withAnimation`, committed the code, and tested — nothing happened. Only after reading the `Hello World` source closely did I understand that RealityKit entity properties must be animated with explicit timing via `DispatchQueue` or RealityKit's own animation system. This cost approximately two hours of debugging time.

**Simulator limitations changed my workflow.** visionOS Simulator does not render `SimpleMaterial` colour correctly and does not simulate spatial gesture input accurately. This forced me to rely on reading the code and comparing against documentation rather than visual iteration — a workflow I was not accustomed to. It reinforced the importance of writing clear, self-documenting code (meaningful entity variable names, clear separation of layout vs. material logic) because visual confirmation was unavailable.

---

## 4. What I Would Do Differently

If I were starting the visionOS prototype again, I would:

1. **Complete the `Hello World` sample walkthrough before writing a single line of prototype code** — not skim it. The two hours lost to the `InputTargetComponent` bug and the RealityKit animation issue were both covered by the sample, which I had read but not thoroughly understood.

2. **Start with a simpler scene** (a single floating panel, then two, then the full arc) rather than attempting the full layout on the first iteration. Incremental scene building would have caught placement and scaling issues earlier.

3. **Set up a physical device workflow earlier** — borrowing an Apple Vision Pro from the university lab for device testing, rather than relying entirely on Simulator.

---

## 5. Conclusion

The NurseryConnect Vision prototype represents my first experience with spatial computing development. While the prototype is necessarily limited in scope (sample data, no live SwiftData connection), the learning it required was disproportionately deep: a new scene type (`ImmersiveSpace`), a new rendering framework (RealityKit), a new input model (eye + hand gaze), and a fundamentally different design paradigm (placement in physical space rather than layout on a flat canvas).

The three resources I curated — the WWDC23 immersive app session, the spatial design principles session, and the `Hello World` sample — together provided a complete foundation: conceptual understanding of the platform, principled guidance on design decisions, and working reference code for the key technical patterns. I am confident that this foundation is transferable to any future spatial computing project, on Vision Pro or on the broader category of XR devices that will follow.

---

## References

Apple Inc. (2023). *Develop your first immersive app* [WWDC23 Session 10203]. Apple Developer. Retrieved from https://developer.apple.com/wwdc23/10203

Apple Inc. (2023). *Principles of spatial design* [WWDC23 Session 10072]. Apple Developer. Retrieved from https://developer.apple.com/wwdc23/10072

Apple Inc. (2024). *Hello World: Use windows, volumes, and immersive spaces to teach people about the Earth* [visionOS sample code]. Apple Developer. Retrieved from https://developer.apple.com/documentation/visionos/world

---

*SE4020 — Mobile Application Design & Development | Assignment 02 Part B | June 2026 | SLIIT*
