# SE4020 – Assignment 02 Part B: Presentation Pitch
## NurseryConnect Vision — Spatial Computing Prototype

> **Instructions for use:** This file contains the full content for a 6–8 slide presentation deck.  
> Import slide content into Keynote, PowerPoint, or Google Slides.  
> Each section below maps to one slide. Speaker notes are included under each slide.

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **Module** | SE4020 — Mobile Application Design & Development |
| **Assignment** | Assignment 02 — Part B: visionOS Spatial Prototype Pitch |
| **Date** | June 2026 |

---

## Slide 1 — Title Slide

**Heading:** NurseryConnect Vision  
**Subheading:** A Spatial Computing Prototype for Early Years Keyworkers  
**Visual:** Dark background with floating translucent panels fading into a soft visionOS-style gradient

**Speaker Notes:**
> Good morning / afternoon. My name is Jayasundara and I'm presenting NurseryConnect Vision — a spatial computing prototype that reimagines how early years keyworkers interact with the children's records they manage every day.
>
> This is Part B of the Assignment 02 submission for SE4020. The prototype targets Apple Vision Pro running visionOS 2, and demonstrates how spatial UI can make the most critical parts of a keyworker's workflow — checking in on children, reviewing incidents, and tracking mood — faster and more intuitive than any 2D screen.

---

## Slide 2 — The Problem

**Heading:** The Challenge Facing Nursery Keyworkers

**Bullet points:**
- 👶 A typical keyworker manages **6–8 children** simultaneously
- 📋 They juggle **diary entries, incident reports, attendance registers, and safeguarding alerts** — all on a small phone screen
- ⏱️ Statutory EYFS documentation must be completed **during the nursery day**, not after hours
- 📱 Current tools are **linear and 2D** — one screen at a time, one child at a time
- 🔍 Critical information (a child's allergy, a pending incident) is **buried in list views**

**Visual:** Side-by-side of a crowded iPhone list view vs an open spatial dashboard

**Speaker Notes:**
> The problem NurseryConnect addresses is information overload in a high-care, high-stakes environment. A keyworker cannot sit at a desk — they are in the room with the children. They need to record what is happening in real time without losing situational awareness.
>
> The existing 2D app (Assignment 01) already improved on paper-based systems, but every piece of information still requires navigating into a specific screen. The spatial prototype asks: what if all the information a keyworker needs could be visible in their peripheral vision simultaneously, in the space around them?

---

## Slide 3 — The Concept

**Heading:** NurseryConnect Vision — Spatial UI for the Keyworker Role

**Three-panel layout:**

| Panel 1 | Panel 2 | Panel 3 |
|---|---|---|
| **Glass Dashboard Window** | **Immersive Space** | **Child Detail Sheet** |
| Always-on stats: total children, pending incidents, average mood | Floating 3D child panels in a parabolic arc — one panel per child | Three-tab detail: Overview, Diary, Health — tap any floating panel to open |

**Tagline:** *"Your children's data, floating in the space around you."*

**Visual:** Concept render — keyworker in nursery room with translucent floating cards visible ahead of them

**Speaker Notes:**
> The concept has three layers.
>
> The main window is a familiar glass-morphism dashboard — always visible as a floating panel in the room. It shows the numbers that matter: how many children are present, how many incidents are pending, and what the average mood is today.
>
> Activating the Immersive Space brings up a parabolic arc of floating child panels — one per child, colour-coded by mood and incident status. The keyworker can see at a glance which child has a red panel (incident or low mood) without navigating a list.
>
> Tapping any floating panel opens a three-tab detail sheet anchored to that panel's position in space, showing the child's overview, diary, and health information.

---

## Slide 4 — Key Features

**Heading:** Technical Highlights

**Feature cards (2×2 grid):**

**🪟 Spatial Glass Dashboard**
- `.glassBackgroundEffect()` for visionOS translucent panels
- Always-on stat cards: children, incidents, mood average
- Activity feed showing last 5 events

**🌌 RealityKit Immersive Space**
- `RealityView` with `.mixed` ImmersionStyle
- Child panels placed in a parabolic arc (z = –0.06x²)
- `SimpleMaterial` colour-coded: 🟢 Mood ≥4 / 🟡 Mood 3 / 🔴 Mood <3 or incident pending

**👁️ Spatial Input & Gestures**
- `InputTargetComponent` + `CollisionComponent` on each panel
- `SpatialTapGesture().targetedToAnyEntity()` for eye+hand selection
- Scale pulse animation on tap (1.0 → 1.1 → 1.0)

**📋 Child Detail Sheet**
- Opens anchored to tapped panel position
- Three tabs: Overview / Diary / Health
- `.presentationBackground(.ultraThinMaterial)` glass sheet

**Speaker Notes:**
> Let me walk through the four key technical components.
>
> The glass dashboard uses visionOS's native `.glassBackgroundEffect()` — the correct way to achieve the characteristic translucent panel look. No custom blurs or UIKit tricks needed.
>
> The immersive space is built with RealityKit's `RealityView`. Each child panel is a box mesh entity placed using a parabolic arc formula — spreading panels horizontally while curving them gently toward the viewer, creating a natural arc you'd see in a theatre stage. Z-offset equals negative 0.06 times x-offset squared.
>
> Panels are colour-coded using `SimpleMaterial`. Green means mood score 4 or 5 — the child is having a good day. Yellow is neutral mood. Red means either a low mood score or a pending incident report — a visual early warning system.
>
> Eye + hand input is implemented via `InputTargetComponent` and `SpatialTapGesture`. Tapping a panel triggers a scale pulse (a brief 1.1× scale then returning to 1.0) confirming the selection, then opens the detail sheet.

---

## Slide 5 — User Journey

**Heading:** A Day in the Life — Keyworker Workflow with Vision Pro

**Timeline (horizontal):**

```
08:30 ─────────────────────────────────────────────── 16:00
  │                                                      │
Opens     Sees red panel    Taps panel →    Closes      End-of-day
Dashboard  for Aiden        opens detail    Immersive   stat review
  │        (incident)       sheet →         Space         │
  ↓        ↓               reviews diary   ↓             ↓
[Glass]  [Parabolic     [3-tab Detail   [Dashboard   [All green
Window   Arc — 7         Sheet opens     returns]     panels]
opens]   panels]         in-space]
```

**Target audience callout box:**
> **Primary User**: Nursery Keyworker, aged 22–45, familiar with iPhone/iPad, first-time spatial computing user  
> **Pain point solved**: Zero-navigation access to all children's status simultaneously  
> **Use case**: Quick morning status check (under 60 seconds) + incident triage during the day

**Speaker Notes:**
> Here is the practical user journey. The keyworker arrives in the morning, puts on Vision Pro, and the dashboard window opens automatically showing today's stats.
>
> They activate the immersive space with one tap and immediately see seven floating panels — one per child. Six are green, one is amber. They look toward the amber panel — Aiden's — and tap it. A detail sheet opens anchored to Aiden's panel showing that he had a Minor incident reported yesterday that is still pending parent notification.
>
> The keyworker makes a mental note to call Aiden's parent at 9am. They close the detail, the panel updates to green (incident acknowledged), and they dismiss the immersive space. The dashboard continues floating in the corner of the room for the rest of the day.
>
> This entire workflow took under 60 seconds and required zero swipes through lists.

---

## Slide 6 — Spatial Design Principles

**Heading:** How This Design Follows Apple Spatial Design Guidelines

**Three-column layout:**

| Principle | Apple Guideline | How Applied |
|---|---|---|
| **Depth & Distance** | Place content 0.5–2m from viewer; avoid placing objects behind the viewer | Panels placed 0.8–1.2m ahead at natural reading distance; parabolic arc keeps all panels in a 120° forward arc |
| **Scale** | Objects should feel life-sized or appropriately scaled to context | Child panels are 25cm × 35cm — approximately the size of a physical keyworker observation card |
| **Eye comfort** | Do not require persistent upward or downward gaze | Arc is at seated/standing eye level (1.5m); no panel is above 20° vertical from eye line |
| **Glass materials** | Use `.glassBackgroundEffect()` for persistent overlays | All windows and detail sheets use native glass material |
| **Passthrough** | In .mixed immersion, the real world must remain readable | `.mixed` ImmersionStyle preserves full passthrough; panels are semi-transparent |
| **Input** | Prioritise eye+hand gaze for primary actions | `SpatialTapGesture` uses fused eye gaze + hand pinch — the primary Vision Pro input model |

**Speaker Notes:**
> Spatial design has very different rules from 2D UI design. Objects placed too close cause eye strain. Objects placed behind the viewer require unnatural head rotation. Text too small at distance becomes unreadable.
>
> Every placement decision in NurseryConnect Vision was validated against Apple's Spatial Design guidelines from WWDC 2023 and the visionOS Human Interface Guidelines. The parabolic arc formula — which I derived from the "Principles of spatial design" WWDC session — ensures all panels are within the comfortable 120-degree forward field of view and at natural reading distance.

---

## Slide 7 — Limitations & Future Work

**Heading:** Prototype Scope & What Comes Next

**Left column — Current prototype limitations:**
- Hard-coded sample data (4 children — not connected to live SwiftData store)
- No persistent state between sessions (immersive space resets on close)
- No annotation or writing input (Apple Pencil for Vision Pro not in scope)
- Single-user prototype — no multi-keyworker synchronisation
- Requires a physical Apple Vision Pro ($3,499 USD) to run; simulator has limited RealityKit preview

**Right column — Future roadmap:**
- Connect to live SwiftData container from the main iOS app via App Group shared container
- Add in-space annotation: keyworker can draw on a child's panel using hand gestures
- Multi-user shared space: two keyworkers see the same arc with live synchronisation (SharePlay)
- Biometric data integration: mood score fed from wearable sensor rather than manual entry
- Ofsted-ready export: one-tap PDF of all children's observations directly from the immersive space

**Speaker Notes:**
> I want to be transparent about what this prototype is and is not. It demonstrates the spatial UI concept and the key interaction patterns — panel layout, colour coding, tap-to-detail. It uses hard-coded sample data rather than the live SwiftData store from the main app, because connecting two separate Xcode targets via a shared App Group container is beyond the scope of this assignment.
>
> The most important next step would be that data connection — once the immersive space shows real children's real data, the value proposition becomes immediately tangible to nursery operators.

---

## Slide 8 — Summary & Value Proposition

**Heading:** Why NurseryConnect Vision?

**Large callout numbers (3-column):**

| 60 seconds | Zero | 100% |
|---|---|---|
| Full morning status check — faster than any list-based UI | Navigations required to see all children's status simultaneously | Apple HIG spatial design compliance |

**Value proposition statement:**
> NurseryConnect Vision does not replace the keyworker's judgment — it clears the noise so their judgment can act faster.

**Closing bullet points:**
- Builds on a solid iOS MVP (Assignment 01) with a proven MVVM + SwiftData architecture
- visionOS prototype demonstrates real RealityKit spatial layout, gesture input, and glass UI
- Grounded in real regulatory requirements (EYFS, Children Act, Ofsted)
- Designed for a real user in a real workflow — not a technology demonstration for its own sake

**Speaker Notes:**
> To close — NurseryConnect Vision is not about making nurseries feel futuristic. It is about reducing the cognitive load on staff who already carry enormous responsibility for the safety and development of young children.
>
> The spatial prototype proves three things: that spatial computing can surface critical information faster than any 2D list; that visionOS development is achievable within the SwiftUI/RealityKit framework Apple has provided; and that the principles of good UX — accessibility, discoverability, task completion speed — apply equally in three dimensions as in two.
>
> Thank you.

---

## Presentation Notes

**Total duration:** 8–10 minutes (1–1.5 minutes per slide)  
**Recommended tool:** Apple Keynote (Magic Move transitions between spatial layout slides)  
**Font:** SF Pro Display for headings, SF Pro Text for body  
**Colour scheme:** Deep black/dark grey background, white text, accent colours matching the app (green, amber, red for mood states)  
**Recommended visuals to add:**
- Slide 3: Screenshot of `ImmersiveChildPanelsView` running in visionOS Simulator
- Slide 4: Code snippet of the parabolic arc formula + panel colour logic
- Slide 6: Screenshot of Apple's spatial design distance diagram (from developer.apple.com)

---

*SE4020 — Mobile Application Design & Development | Assignment 02 Part B | June 2026 | SLIIT*
