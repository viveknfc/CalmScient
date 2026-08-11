# CalmScient Wearables — Xcode Setup

This branch (`Clamscient-Wearables`) adds HealthKit to the iOS app and a new
Apple Watch companion app. All source code is written; the only remaining work
is wiring the targets in Xcode (a few minutes of clicks). Do the steps in order
so the project always compiles.

---

## What was added

**iOS app (`Calmscient/Wearables/`)**
- `Shared/WearableMessages.swift` — Codable payloads + WatchConnectivity keys. **Shared by both targets.**
- `HealthKit/HealthKitManager.swift` — auth, reads (HR/HRV/sleep/mindful), writes mindful sessions.
- `Connectivity/PhoneConnectivityManager.swift` — pushes medications to the watch, receives mood check-ins / mindful sessions.
- `AppDelegate.swift` — now calls `PhoneConnectivityManager.shared.activate()` at launch.
- `Calmscient.entitlements` — HealthKit capability added.
- `Info.plist` — `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` added.

**Watch app (`CalmscientWatch Watch App/`)**
- `CalmscientWatchApp.swift` — `@main` entry point.
- `WatchRootView.swift` — home list (Mood / Breathe / Medications).
- `MoodCheckInView.swift` — one-tap mood log, sent to phone.
- `BreathingSessionView.swift` — 1/3/5-min guided breathing → writes mindful minutes to HealthKit + notifies phone.
- `MedicationGlanceView.swift` — shows medications synced from the phone.
- `WatchConnectivityManager.swift` — watch side of the bridge.
- `WatchHealthKitManager.swift` — watch HealthKit auth + mindful-session write.

**Health Metrics screen (iOS, `Calmscient/Wearables/HealthKit/`)**
- `HealthMetric.swift` — catalog of the 20 metrics across 6 categories + HealthKit mapping.
- `HealthMetricsRepository.swift` — reads current values and Daily/Weekly/Monthly/Yearly trends from HealthKit.
- `HealthMetricsViewModel.swift` / `HealthMetricsView.swift` / `HealthMetricsHostingController.swift` — the dashboard (grouped list matching the design).
- `HealthMetricDetailViewModel.swift` / `HealthMetricDetailView.swift` / `HealthMetricDetailHostingController.swift` — per-metric trend chart (Swift Charts).
- `HomeTabDashboardViewController.swift` — a 4th Home card **"Health Metrics"** now pushes `HealthMetricsHostingController`.

> The Health Metrics screen uses Apple's **Swift Charts** (`import Charts`). This
> project's CocoaPod is **DGCharts** (module `DGCharts`), so there is no module
> name collision — `import Charts` resolves to the system framework.

> Optional: add an image asset named **`HealthMetricsIcon`** for the Home card.
> Without it the card falls back to the SF Symbol `heart.text.square.fill`.
> Also add a **"Health Metrics"** key to the `Localizable.strings` files (it
> shows the English key until translated).

---

## Step 1 — Add the iOS files to the app target

1. In Xcode, drag the `Calmscient/Wearables/` folder into the Project navigator (if it isn't already shown).
2. In the dialog: **check "Copy items if needed" is OFF** (files are already in place), choose **"Create groups"**, and tick the **CalmscientIOS** target.
3. Build the iOS app (⌘B). It should compile now that `PhoneConnectivityManager` and `HealthKitManager` are in the target.

> The `AppDelegate` change references `PhoneConnectivityManager` and the Home
> screen references `HealthMetricsHostingController`, so the iOS app will not
> build until the whole `Calmscient/Wearables/` folder (including the
> `HealthKit/` subfolder) is added to the target.

## Step 2 — Confirm the iOS HealthKit capability

- Select the **CalmscientIOS** target → **Signing & Capabilities**.
- Confirm **HealthKit** appears (it's already in `Calmscient.entitlements`). If not, click **+ Capability → HealthKit**.

> ✅ **UPDATE:** Steps 1–5 below are already DONE. The iOS files and the watchOS
> target were added to the Xcode project programmatically (via the `xcodeproj`
> gem) and verified with a clean `xcodebuild` (iOS app + embedded watch app,
> **BUILD SUCCEEDED**). You can just open the workspace and run. The sections
> below are kept for reference / if you ever recreate the target by hand.
>
> **Build settings changed on the `Calmscient` target to make the embedded watch app build cleanly** (both were needed to resolve Xcode build-phase cycles; both are safe and reversible):
> - `ENABLE_DEBUG_DYLIB = NO` — disables the Xcode 16 debug-dylib split (only affects debug build layout, not behavior).
> - `LM_SKIP_METADATA_EXTRACTION = YES` — skips App Intents metadata extraction (this app doesn't use App Intents).
> - The **Embed Watch Content** build phase is ordered right after **Resources** (before the Firebase run-script), and the iOS target has an explicit build dependency on the watch target.
> - Requires the **watchOS platform** installed (done on this machine: watchOS 26.2).

## Step 3 — Create the Watch App target

1. **File → New → Target… → watchOS → App**. Name it exactly **`CalmscientWatch`** (product name; the folder `CalmscientWatch Watch App` already matches Xcode's default naming).
2. Interface: **SwiftUI**, Language: **Swift**. Leave "Include Notification Scene" unchecked (optional).
3. When prompted, set it as a **companion to CalmscientIOS**. Xcode will set:
   - Watch app bundle id: `calmscientllc.com.watchkitapp`
   - `WKCompanionAppBundleIdentifier` = `calmscientllc.com`
4. Xcode generates a starter `ContentView.swift` / `App.swift` in the new target. **Delete those generated files** (move to Trash) so they don't clash with the provided ones.
5. Add the seven files from `CalmscientWatch Watch App/` to the new watch target (drag them in, tick the **watch** target only).

## Step 4 — Add the shared file to the watch target too

- Select `Calmscient/Wearables/Shared/WearableMessages.swift`.
- In the **File inspector → Target Membership**, tick **both** the CalmscientIOS target **and** the new watch target.

## Step 5 — Watch target capabilities & Info.plist

- Select the **watch** target → **Signing & Capabilities → + Capability → HealthKit**.
- Add these keys to the watch target's Info (target → Info tab, or its Info.plist):
  - `NSHealthShareUsageDescription` — e.g. *"CalmScient logs your mindful minutes to Apple Health."*
  - `NSHealthUpdateUsageDescription` — same text is fine.

## Step 6 — Build & run

- Select the **watch scheme** + a paired iPhone/Watch simulator pair, ⌘R.
- On the iPhone build, ⌘R the iOS app too.

---

## Wiring the medication sync (one integration point)

`PhoneConnectivityManager` is activated but nothing pushes data yet. Wherever
the app loads/edits the medication list, call:

```swift
if #available(iOS 16.0, *) {
    let meds = currentMeds.map {
        WearableMedication(id: $0.id, name: $0.name, dosage: $0.dosage, nextDoseAt: $0.nextDose?.timeIntervalSince1970)
    }
    PhoneConnectivityManager.shared.syncMedications(meds)
}
```

To handle mood check-ins coming back from the watch, set a handler once (e.g.
in `AppDelegate` after `activate()`):

```swift
PhoneConnectivityManager.shared.onMoodCheckIn = { checkIn in
    // persist to backend / day-feedback flow
}
```

---

## Notes
- Deployment targets: iOS 16.0 (existing). Set the watch target to **watchOS 9.0+** to match the modern HealthKit/SwiftUI APIs used.
- SourceKit will show "Cannot find type…" errors on these files until they are members of a compiled target — that's expected and clears after Steps 1–4.
