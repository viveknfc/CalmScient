# CalmScient — Unused Code & Localization Cleanup Report

**Prepared:** 3 Aug 2026 · **Branch analyzed:** `Viv_May6_2026`
**Mode:** Tier 1 **EXECUTED** on 3 Aug 2026 (see "What was removed" below). Tier 2 remains report-only.

---

## ✅ What was removed (executed)

### 15 Swift files deleted (from disk + de-referenced in `project.pbxproj`)

1. `DiscoveryTakingControl/BasicKnowledge/AlcoholGuidelinesViewController.swift`
2. `DiscoveryTakingControl/CustomLabel.swift`
3. `Excercises/Header.swift`
4. `Font/FontLL18.swift`
5. `HomeTab/MyMedicalRecords/Medications/CustomViewController.swift`
6. `HomeTab/MyMedicalRecords/Screenings/ScreeningsAPIRequest.swift`
7. `HomeTab/WeeklySummary/ProgressOnCourseWork/ProgressOnWorkExpansionTableView.swift`
8. `NetworkLayer/Networking/API/MockAPI.swift`
9. `NetworkLayer/Networking/Service/Router.swift`
10. `Swift UI/general/SwiftUIHostingControllerPreviews.swift` (DEBUG-only Xcode previews, 1285 lines)
11. `Swift UI/view/.../Ready To Quit/Modal/Components/QuitSymptomModalTimelineRowView.swift`
12. `Swift UI/view/Exercises/.../Type 1/BreathingTechniqueType1StepRowView.swift`
13. `TakingControlDrinksSummary/CustomProgressBar.swift`
14. `Viv Screens/General Class/CustomDropDown.swift`
15. `Viv Screens/General Class/TimeZoneHelper.swift`

Each removal cleared exactly its 4 `project.pbxproj` lines (PBXBuildFile, PBXFileReference,
group child, sources phase). Post-check: **0** dangling UUIDs, braces balanced, and **0**
references to any deleted type/global name anywhere in the remaining Swift, storyboards, or xibs.

### 29 unused localization keys removed from `en/es/ja` Localizable.strings

All 30 originally-flagged keys were removed, then **1 was restored** — `alarm_time_unit_min`
(en/es = "min", ja = "分") — because verification found it is used at
`Swift UI/ViewModel/AlarmSettingsViewModel.swift:36` inside string interpolation
(`"\(minutes) \("alarm_time_unit_min".localized)"`), which the first-pass scan mis-tokenized.
Net = **29 keys removed**. Final check: **0** removed keys are referenced anywhere in code.

### Not touched
Your pre-existing uncommitted changes (AppDelegate, ViewModels, the new `no_internet_*`
localization keys, Pods, etc.) were left exactly as they were.

### ⚠️ Still required on your Mac
Open the project in Xcode and do a clean **build + run + smoke test** of the main flows.
Static analysis cannot substitute for a compile. If anything is off, every change is reversible
(`git checkout -- <file>` / `git restore`), and a backup of the original `project.pbxproj` was kept.

---

## How to read this report

You asked me to confirm what is unused before removing anything, keeping the same
architecture and breaking no functionality. I analyzed the whole app target (859 Swift
files, 76 storyboards, 92 xibs, 3 `Localizable.strings` catalogs + per-screen `.strings`/
`.xcstrings`), excluding `Pods/`.

**Two honest limits of this analysis:**

1. **I cannot compile the project here** (this environment has no Xcode/macOS). Static
   analysis is high-confidence for the Tier 1 items below, but the *only* proof of "nothing
   broke" is a clean **Xcode build + smoke test on your Mac** after removal.
2. **Reference detection is deliberately conservative.** A file is only flagged as unused
   when the type(s) it declares appear **nowhere else** — not in any other Swift file, not
   as a `customClass` in any storyboard/xib, and not in any string used for dynamic
   instantiation. If a name is referenced *anywhere*, I kept the file.

Because you chose "only zero-reference files," everything in **Tier 1** is safe to remove.
**Tier 2** (the bulk of the old UIKit screens) is explained but **not** on the delete-now
list — see why below.

---

## Key finding: this is a *hybrid* app, not a finished migration

The launch path is:

```
SceneDelegate → LaunchScreenHostingController (SwiftUI)
             → LoginHostingController (SwiftUI)
             → navigateToDashboard(): UIStoryboard(name: "AppTabBar")
                                       → AppMainTabViewController  ← still UIKit
```

The main tab bar and many screens are **still UIKit storyboards that are actively loaded**.
So "most screens are unused" is only partly true: the *old versions* of migrated screens
are dead, but they are still wired to shared UIKit components (`LinearGradientButton`,
`CapsuleButton`, `CustomCalender`, custom text fields, etc.) that the **live** screens also
use. That shared wiring is why a blind "delete all old screens" pass would break the build —
and why the safe, zero-reference pass finds far fewer files than you might expect.

---

# TIER 1 — Safe to remove now (zero references anywhere)

## A. Dead Swift files (14)

Each declares only type(s)/helpers that are referenced **nowhere** in Swift, storyboards,
xibs, or dynamic strings. No `NSClassFromString` usage exists anywhere in the app, so there
is no hidden dynamic instantiation.

| # | File | Declares | Note |
|---|------|----------|------|
| 1 | `DiscoveryTakingControl/BasicKnowledge/AlcoholGuidelinesViewController.swift` | `enum AlcoholAvoidanceReason` + global `printAlcoholAvoidanceReasons()` | No VC despite the name; enum + a `print()` helper used only by each other |
| 2 | `DiscoveryTakingControl/CustomLabel.swift` | `CustomLabel` | Not set as `customClass` in any IB file |
| 3 | `Excercises/Header.swift` | `HeaderView` | |
| 4 | `Font/FontLL18.swift` | `FontLL18` | Leftover font wrapper |
| 5 | `HomeTab/MyMedicalRecords/Medications/CustomViewController.swift` | `HalfScreenPresentationController` | |
| 6 | `HomeTab/MyMedicalRecords/Screenings/ScreeningsAPIRequest.swift` | `ScreeningsAPIRequest` | Old request model, superseded |
| 7 | `HomeTab/WeeklySummary/ProgressOnCourseWork/ProgressOnWorkExpansionTableView.swift` | `ProgressOnWorkExpansionTableView` | |
| 8 | `NetworkLayer/Networking/API/MockAPI.swift` | `MockAPI` | Mock never wired in |
| 9 | `NetworkLayer/Networking/Service/Router.swift` | `NetworkRouter`, `Router` | Old routing layer, unused |
| 10 | `Swift UI/view/.../Ready To Quit/Modal/Components/QuitSymptomModalTimelineRowView.swift` | `QuitSymptomModalTimelineRowView` | SwiftUI subview never composed |
| 11 | `Swift UI/view/Exercises/.../Type 1/BreathingTechniqueType1StepRowView.swift` | `BreathingTechniqueType1StepRowView` | SwiftUI subview never composed |
| 12 | `TakingControlDrinksSummary/CustomProgressBar.swift` | `CustomProgressBar` | |
| 13 | `Viv Screens/General Class/CustomDropDown.swift` | `DropdownView` | |
| 14 | `Viv Screens/General Class/TimeZoneHelper.swift` | `TimeZoneHelper` | Timezone logic now lives in `DayFeedbackSessionLogic` |

## B. Debug-only preview file (1) — your call

| File | What it is |
|------|-----------|
| `Swift UI/general/SwiftUIHostingControllerPreviews.swift` | Entirely wrapped in `#if DEBUG`. 76 Xcode `#Preview` canvas entries (all `private struct … UIViewControllerRepresentable`) for the SwiftUI hosting controllers. Never compiled into release, never referenced by app code. |

Removing it has **zero runtime impact**, but you lose the Xcode canvas previews for those
hosts. It's an intentional developer aid — remove only if you don't use those previews.

**Tier 1 total: 15 files (14 dead + 1 debug-only).**

---

# TIER 2 — Old UIKit screens (very likely dead, but NOT safe to blind-delete)

35 of 76 storyboards are **never loaded by name** (`UIStoryboard(name:)`), never referenced
by another storyboard, and not set in Info.plist. These are almost entirely the pre-migration
UIKit versions of screens now served by SwiftUI hosting controllers (e.g. `LoginVC`,
`UserProfile`, `Dashboard`, `CreateAccountVC`, `ScreeningResultVC`, `AddNewAppointment`…).

**Why they are not on the delete-now list:**

- Their view-controller classes still reference **shared UIKit components** that the live
  screens also use, so the classes are not "zero-reference." Deleting the class files would
  need per-screen confirmation that no live flow reaches them.
- Safe removal here means removing each screen as a **cluster** (storyboard + its exclusive
  VC/cell classes + its xibs + its per-screen `.strings`) and then **building** to confirm.
  That is a guided second pass, ideally one cluster per commit.

**Correction / do-not-touch inside this bucket:**

- `HealthAppLaunchScreen.storyboard` — **KEEP.** It is the active launch screen
  (`INFOPLIST_KEY_UILaunchStoryboardName = HealthAppLaunchScreen.storyboard`).
- `LaunchScreen.storyboard` and `Main.storyboard` — appear to be genuine leftovers (the app
  builds its window programmatically in `SceneDelegate`), but confirm the build settings
  before removing, since launch/main storyboards are wired via project settings, not code.

The 35 unreferenced storyboards:

```
AddAppointments, AddMedicationVC, AddNewAppointment, AddUserMedications,
AppointmentDetailsVC, CourseViewController, CreateAccountVC, Dashboard,
DrinkingHabbitController, GlossyController, HealthAppLaunchScreen*, HistoryVC,
JournalEntryMain, JournalEntryViewController, LandingVC, LaunchScreen, LoginVC,
Main, ManagingAnxietyBeginScreen, MedicationDetail, NextAppointments, ProfilePrivacy,
ProfileViewController, ProgressOnWorkMain, QuestionnairesVC, ScreeningQuestions,
ScreeningResultVC, USGuidlines, UserIntro, UserProfile, VideoController, WebViewLesson,
WeeklySummaryGraphResults, WeeklySummaryResults, WhatToExpectViewController
        (* = KEEP, it is the live launch screen)
```

Paired per-screen IB localization files that would go **with** their storyboard clusters:
`Main.strings`, `LaunchScreen.strings`, `Features/Login/*/LoginVC.strings`,
`profile/*/UserProfile.strings` (en/es/ja variants).

If you want, I can produce the exact per-cluster delete list (each storyboard + its
exclusive classes + xibs) as a follow-up so you can remove and build them one at a time.

---

# Localization keys

Source: `en/es/ja` `Localizable.strings` (union of 932 distinct keys). A key is "used" if its
literal appears in Swift, **or** it matches a dynamically built prefix. Detected dynamic
prefixes (whose keys are all kept): `appointment_`, `gls_term_`, `gls_sum_`.

## C. 30 high-confidence unused keys (not in code, not in any storyboard/xib)

```
Accept Terms & Conditions
According to the 2020-2025 Dietary Guidelines… (2 escaped variants)
As a simple example: Instead of focusing on how many miles…
COULD BE\n BETTER  (2 escaped variants)
DISCOVERY
DRINKING_CONTROL_Do_Not_Show_Checkbox_text
DRINKING_CONTROL_Drink_Coach
DRINKING_CONTROL_Intro_Message
DRINKING_CONTROL_Substance_Coach
Days at each Mood
Discovery Excercise            (note the misspelling — the correct "Discovery Exercise" is separate)
How does mindfulness help with anxiety?
Inhale through your nose about 4 seconds,\nFocusing on the tummy rising.
Managing Stress
Mindfulness is the opposite of automatic pilot…
Mindfulness reminds us that we don't have to take immediate control…
My medical appointment
No internet connection. Please try again.
Not Yet
Rewards
This assessment is based on the Patient Health Questionnaire (PHQ)… (2 escaped variants)
Which mindfulness exercises would you like to make part of your daily routine?…
alarm_time_unit_min
consequences2
filter_discovery_capsule
filter_questionnaire
help_button_text
```

Removing a key means deleting that one line from **each** of `en/es/ja` `Localizable.strings`.

## D. 13 review-first keys (unused via code, but the same text is hardcoded in a storyboard/xib)

These have no `.localized` lookup, so removing them won't break code — but the identical
English text sits inside a (mostly Tier 2) storyboard/xib. Safer to remove **together with**
the corresponding old screen, or after confirming the screen is dead.

```
Add Medication · Choose Date and Time · Cons · Create an New account
Did you take your meds this evening? · Discovery Exercise · Home · Managing Anxiety
My medical record · Pros · counts
Emotional Regulation: Engaging in mindful walking…   (long body copy)
Have you ever caught your mind wandering…            (long body copy)
```

## E. Cross-language inconsistencies (informational, not deletions)

Keys present in one language file but missing from `en` — these indicate drift, not dead
code. Worth aligning so all three catalogs share the same key set:

- **es only (7):** `Daily journal`, `Discovery Exercise`, `First find a comfortable to either sit down or lay down.`, plus 4 body-copy strings.
- **ja only (22):** includes `Good job!`, `Congratulations text`, `Your suggested`, `NotYet` / `Not yet` (duplicate casings), `congralatuateDecision`, `typesOfconsequence`, `consequences4/6`, `DRINKING_CONTROL_Intro`, and several body-copy strings.

There are also near-duplicate keys differing only by escaping (`\\n` vs `\\\n`) and by
casing/spacing (`Not Yet` / `Not yet` / `NotYet`; `Discovery Excercise` / `Discovery Exercise`)
— good candidates to consolidate.

---

# Summary of what a removal would delete

| Tier | Item | Count | Confidence |
|------|------|-------|-----------|
| 1A | Dead Swift files | 14 | High — zero references, verify with a build |
| 1B | Debug-only preview file | 1 | High — no runtime impact (dev aid) |
| C | Unused localization keys (code + IB clean) | 30 | High |
| D | Localization keys to review with their screen | 13 | Medium |
| 2 | Old UIKit storyboard/VC/xib screen clusters | ~34 | Likely dead — needs per-cluster pass + build |

---

# Recommended safe procedure (on your Mac)

1. Commit/stash your current in-progress changes first (you said you'd handle this).
2. Create a branch, e.g. `cleanup/dead-code`.
3. Remove **Tier 1A** files (delete from disk **and** remove their `PBXBuildFile` /
   `PBXFileReference` entries from `Calmscient.xcodeproj/project.pbxproj`, or just delete via
   Xcode which handles both). Remove **1B** if you don't want the previews.
4. Remove the **30 Tier C** keys from all three `Localizable.strings`.
5. **Build + run + smoke-test** the main flows (login, dashboard tabs, medications,
   appointments, screenings, weekly summary, discovery/taking-control, profile).
6. Commit. Then tackle **Tier 2** one screen-cluster per commit, building between each.

Because everything above is reversible via git, each step can be rolled back independently if
a build or smoke test fails.

*No files were changed in producing this report.*
