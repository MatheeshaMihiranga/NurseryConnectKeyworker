# SE4020 – Assignment 02: AI Mockup Documentation
## NurseryConnect Keyworker — UI Design Variations & AI-Assisted Mockups

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **AI Tool Used** | Microsoft Copilot (AI-powered design description) + Figma AI (layout generation) |
| **Date** | June 2026 |

---

## 1. Introduction

As part of the design process for the Assignment 02 extension, three distinct UI design variations were explored for the two primary new screens: the **Daily Attendance Register** and the **Analytics Dashboard**. Each variation was generated or sketched with AI assistance, then critically evaluated against usability, accessibility, and EYFS workflow requirements before a final design was selected and implemented.

The AI tool used was **Microsoft Copilot** for describing and generating layout concepts and textual design specifications, combined with manual Figma layouts for visual mockups. Copilot was prompted with specific user journey descriptions (e.g. "a keyworker needs to mark 8 children as present in under 30 seconds") and returned multiple layout concept descriptions that were transcribed into Figma frames.

---

## 2. Variation 1 — Card Grid Attendance Register

### Description
A grid layout (2 columns on iPhone, 3 columns on iPad) where each child is represented by a large card showing their photo avatar, name, and three large circular tap buttons (one each for Present, Late, Absent). The card background changes colour to reflect the current status.

### Screenshot / Mockup Sketch

```
┌──────────────────────┐  ┌──────────────────────┐
│  [Avatar]  Oliver    │  │  [Avatar]  Emma       │
│  ● Present           │  │  ● Present            │
│  [●] [◑] [○]         │  │  [●] [◑] [○]          │
│  P   Late  Abs       │  │  P   Late  Abs        │
└──────────────────────┘  └──────────────────────┘
┌──────────────────────┐  ┌──────────────────────┐
│  [Avatar]  Aiden     │  │  [Avatar]  Sophie     │
│  ○ Absent            │  │  ◑ Late               │
│  [●] [◑] [○]         │  │  [●] [◑] [○]          │
│  P   Late  Abs       │  │  P   Late  Abs        │
└──────────────────────┘  └──────────────────────┘
```

**Colour coding**: Present = green card background, Late = amber, Absent = red/grey.

### AI Tool Prompt Used
> "Design a daily attendance register screen for a nursery iOS app. The keyworker has 8 children to mark present/late/absent. The screen must be usable in under 30 seconds with one hand on an iPhone. Show a grid card layout variation."

### Strengths
- Cards make each child visually prominent, reducing the chance of skipping a child
- Three large tap targets per child reduce miss-tap errors
- Colour-coded backgrounds give an immediate overview of the session's attendance at a glance
- Works well on iPad where the grid can accommodate 3 columns

### Weaknesses
- On a 4.7" iPhone (SE), a 2-column grid makes cards very small and the three buttons become difficult to tap
- No expandable note field — notes would require a separate tap-through to a detail screen, adding workflow steps
- No arrival time field for Late status — a critical regulatory requirement
- Grid layout wastes vertical space (no density); for rooms with 12+ children, scrolling becomes necessary even on iPad
- Does not surface a session summary strip without scrolling to the top

### Critical Evaluation
Variation 1 prioritises visual appeal and child identity recognition over workflow speed. In practice, a keyworker marking attendance does not need to see the child's avatar to know who they are — they know their children. The three-button pattern is also redundant with a segmented control approach. This variation was **rejected** because it fails the "under 30 seconds" usability requirement for 8+ children.

---

## 3. Variation 2 — Swipe-to-Status List (Tinder-style)

### Description
A full-screen stack of child cards, one at a time. The keyworker swipes right for Present, left for Absent, and swipes up for Late. After each swipe, the next child card animates in. A progress bar at the top shows completion (e.g., "5 / 8").

### Screenshot / Mockup Sketch

```
  [Progress bar ████████░░] 5 / 8

  ┌─────────────────────────────┐
  │                             │
  │       [Large Avatar]        │
  │         Oliver Taylor       │
  │          Age 3 • Owls Room  │
  │                             │
  │   ← Absent    Present →     │
  │       ↑  Late               │
  └─────────────────────────────┘

  Swipe ← Absent  |  Swipe ↑ Late  |  Swipe → Present
```

### AI Tool Prompt Used
> "Design an iOS attendance register UX that uses swipe gestures to mark children as present or absent, inspired by dating app card stack patterns. The design should feel fast and decisive for mobile one-handed use."

### Strengths
- Extremely fast for experienced users — a single fluid gesture per child
- Clear one-at-a-time focus eliminates the risk of accidentally marking the wrong child
- Progress bar provides visible momentum, encouraging completion
- Large touch targets (full card) accessible for varying motor abilities

### Weaknesses
- **Fatal UX flaw**: Once swiped, going back to correct a mistake requires a separate "undo" mechanism — complex to implement and easy to lose corrections
- Three-directional swipe (left/right/up) is non-discoverable; users will not know "swipe up = Late" without an onboarding tour
- Cannot review the full register at a glance — requires completing all cards first
- Does not scale to 20+ children (too many swipes)
- Incompatible with keyboard navigation on iPad or VoiceOver (accessibility failure)
- Session summary strip requires a separate summary screen after completion

### Critical Evaluation
Variation 2 is the fastest for a perfectly linear first-pass but fails for correction workflows (a keyworker frequently needs to re-check a status they set 5 cards ago). The swipe-up gesture for Late is non-standard and would require user education. VoiceOver/keyboard incompatibility makes it non-compliant with iOS accessibility guidelines. This variation was **rejected**.

---

## 4. Variation 3 — Compact Row List with Inline Controls (Selected)

### Description
A standard `List` layout with one row per child. Each row shows the child's name, a horizontal row of three segmented icon-buttons (Present/Late/Absent), and an expandable section below for arrival time (if Late) and a note field. A pinned header contains the session picker and date picker. A sticky summary strip sits below the header.

### Screenshot / Mockup Sketch

```
┌─────────────────────────────────────────────────┐
│  [Date: 01 Jun 2026] [Morning | Afternoon | FD] │
│  [Present: 5]  [Late: 1]  [Absent: 1]  [87.5%] │
├─────────────────────────────────────────────────┤
│ Oliver Taylor    [✓ P]  [◑ L]  [✗ A]            │
├─────────────────────────────────────────────────┤
│ Emma Wilson      [✓ P]  [◑ L]  [✗ A]            │
├─────────────────────────────────────────────────┤
│ Aiden Murphy     [✓ P]  [◑ L]  [✗ A]            │
│   ▼ Arrival time: 09:14                         │
│   📝 Note: parent phoned - dentist appt         │
├─────────────────────────────────────────────────┤
│ Sophie Chen      [✓ P]  [◑ L]  [✗ A]            │
└─────────────────────────────────────────────────┘
                              [All Present ✓]
```

### AI Tool Prompt Used
> "Design a compact iOS list-based daily attendance register for nursery keyworkers. Requirements: date picker, morning/afternoon session selector, mark each child present/late/absent in one tap, show arrival time for late children, optional notes per child, summary showing attendance rate. The design should work on both iPhone and iPad."

### Strengths
- All children visible at once — no pagination or swiping required; no child is accidentally skipped
- One-tap status change with clear visual feedback (coloured icon button highlight)
- Expandable Late section exposes arrival time picker in context without navigation
- Summary strip updates in real time — keyworker can confirm 100% before leaving the screen
- Scales to 20+ children via standard scroll
- Compatible with VoiceOver (each row is a discrete accessible element), keyboard navigation (`⌘R` for refresh), and Dynamic Type
- iPad layout can show summary strip and list simultaneously without scrolling

### Weaknesses
- Rows are more visually dense than Variation 1 — requires readable typography at `.subheadline` or larger
- Three icon-buttons per row could be replaced with a single long-press context menu to reduce visual noise; however this trades discoverability for density
- "All Present" batch button at the bottom is easy to overlook at the end of a long list

### Critical Evaluation
Variation 3 provides the best balance of speed (one tap per status), correctability (all children visible simultaneously), completeness (arrival time + notes in one view), and accessibility. It maps naturally to how paper attendance registers work — a single sheet with one row per child — making it immediately familiar to nursery staff without training. This variation was **selected and implemented**.

---

## 5. Analytics Dashboard — Design Variations

### Variation A — Scrollable Card Stack (Selected)

Each chart occupies a full-width rounded card. Charts stack vertically. On iPad a 2-column `LazyVGrid` is used. A horizontal chip row above filters all charts by child. **Selected** because it gives each chart sufficient space to be readable, works well on both iPhone and iPad, and matches the card-based visual language established in Assignment 01.

### Variation B — Tabbed Charts

A `TabView` with `.tabViewStyle(.page)` holds one chart per page. Child filter is global. **Rejected** because page indicators are small, navigating to a specific chart requires multiple swipes, and there is no at-a-glance summary of multiple metrics simultaneously.

### Variation C — Dashboard Grid with Mini Charts

A 2×2 fixed grid of small sparkline charts always visible, tapping any sparkline expands it to full screen. **Rejected** because mini charts are unreadable for colour-blind users and the expand/collapse navigation adds two interaction steps per insight.

---

## 6. Final Design Rationale

The final implemented design combines:
- **Attendance Register**: Variation 3 (compact row list) — chosen for accessibility, correctability, and familiarity
- **Analytics**: Variation A (scrollable card stack) — chosen for readability and consistent visual language

Both designs were validated against the following criteria:

| Criterion | Attendance (V3) | Analytics (VA) |
|---|---|---|
| Accessible (VoiceOver) | ✅ Yes | ✅ Yes (Charts auto-descriptions) |
| Works on iPhone SE | ✅ Yes | ✅ Yes (single column) |
| Works on iPad Pro | ✅ Yes (full width list) | ✅ Yes (2-column grid) |
| Satisfies regulatory requirement | ✅ Yes (arrival time, notes) | ✅ N/A |
| One-hand usable | ✅ Yes | ✅ Scroll only |
| Under 30 sec to complete | ✅ Yes (8 children) | ✅ N/A |

---

## 7. AI Tool Justification

**Microsoft Copilot** was chosen as the AI tool for generating design variation descriptions for the following reasons:

1. **Free access**: No subscription cost — accessible via copilot.microsoft.com or the VS Code extension
2. **Contextual prompting**: Copilot understands multi-paragraph technical prompts including iOS HIG terminology, accessibility requirements, and SwiftUI component names
3. **Iterative refinement**: Follow-up prompts like "now add a VoiceOver accessibility evaluation to Variation 2" produce incremental additions to the existing response without losing context
4. **Text-to-layout fidelity**: Copilot's ASCII wireframe outputs translate directly to Figma Auto Layout frames, reducing the manual transcription step

**Limitations acknowledged**:
- Copilot does not generate actual visual mockup images — ASCII wireframes require manual translation to Figma
- The AI does not have real-time knowledge of latest iOS 18 HIG changes; outputs were cross-checked against Apple Human Interface Guidelines (developer.apple.com/design)
- AI-generated design descriptions occasionally favoured aesthetics over accessibility; each variation required a separate accessibility-specific prompt to surface compliance issues

---

*SE4020 — Mobile Application Design & Development | Assignment 02 Part A | June 2026 | SLIIT*
