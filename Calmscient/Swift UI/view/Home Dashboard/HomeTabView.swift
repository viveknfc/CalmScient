//
//  HomeTabView.swift
//  Calmscient
//
//  Native SwiftUI Home tab `NavigationStack`.
//
//  Each destination owns its view model with `@StateObject` (matching the lifetime the
//  hosting controller used to give it), replicates that controller's `configure(...)`
//  call, and wires the navigation closures. Every view model keeps its UIKit push/pop
//  fallback, so the still-UIKit Discovery tab can continue pushing into these screens.
//
//  Chrome parity with the retired hosting controllers:
//   • `navigationItem.title` → `.navigationTitle(...)`, always inline.
//   • the custom `NavigationBack` / `MedicationFlowNavigationBarBackItem` leading item →
//     `MedicationNavigationBackButton` (same 32×32 asset) in a `.navigationBarLeading`
//     toolbar item, with the system chevron hidden. Screens that never replaced the
//     system back button pass `onBack: nil` and keep it.
//   • `viewDidLoad` / `viewWillAppear` / `viewWillDisappear` → `HomeHostBridge`, which
//     also hands each view model the `hostViewController` it was written against.
//
//  Exercises and Taking Control destinations bridge to their existing hosting
//  controllers via `LegacyHostBridge` until those tabs convert.
//

import SwiftUI

@available(iOS 16.0, *)
struct HomeTabView: View {

    let navigationTitle: String
    let showMedicationsAsHome: Bool
    /// Bumped by `MainTabBarViewModel` on every user tab selection. The tab used to be
    /// rebuilt outright at that point (which is what crashed UIKit's navigation bar
    /// layout), so popping to the root here keeps the same behaviour safely.
    let rootResetToken: Int

    @State private var path: [HomeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            rootScreen
                .navigationDestination(for: HomeRoute.self) { route in
                    destination(for: route)
                }
        }
        .onChange(of: rootResetToken) { _ in
            guard !path.isEmpty else { return }
            path.removeAll()
        }
    }

    // MARK: - Root (conditional, mirrors `MainTabStoryboardHost`)

    @ViewBuilder
    private var rootScreen: some View {
        if showMedicationsAsHome {
            UserMedicationsRoute(path: $path, isTabRoot: true)
        } else {
            HomeDashboardRoute(path: $path, navigationTitle: navigationTitle)
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        switch route {

        // ---- half 1: medical records branch ----
        case .homeDashboard:
            HomeDashboardRoute(path: $path, navigationTitle: navigationTitle)
        case .userMedicalRecords:
            UserMedicalRecordsRoute(path: $path, isBelowMedicationsRoot: showMedicationsAsHome)
        case .userMedications:
            UserMedicationsRoute(path: $path, isTabRoot: false)
        case .addEditMedication(let box):
            AddEditMedicationRoute(path: $path, viewModel: box.value)
        case .medicationsDetail(let box):
            MedicationsDetailRoute(path: $path, medicineDetails: box.value)
        case .nextAppointments:
            NextAppointmentsRoute(path: $path)
        case .addNewAppointment:
            AddNewAppointmentRoute(path: $path, isEditMode: false, editPayload: nil)
        case .editAppointment(let box):
            AddNewAppointmentRoute(path: $path, isEditMode: true, editPayload: box.value)
        case .appointmentDetails(let box):
            AppointmentDetailsRoute(path: $path, appointment: box.value)
        case .screeningList:
            ScreeningListRoute(path: $path, fromParticular: false, fromParticular1: false)
        case .screeningQuestions(let box, let p0, let p1):
            ScreeningQuestionsRoute(path: $path, screening: box.value, fromParticular: p0, fromParticular1: p1)
        case .screeningResult(let box, let p0, let p1):
            ScreeningResultRoute(path: $path, screening: box.value, fromParticular: p0, fromParticular1: p1)
        case .screeningHistory(let box):
            ScreeningHistoryRoute(path: $path, screening: box.value)

        // ---- half 2 ----
        case .userProfile:
            UserProfileRoute(path: $path)
        case .patientProfileEdit:
            PatientProfileEditRoute(path: $path)
        case .profilePrivacy:
            ProfilePrivacyRoute(path: $path)
        case .weeklySummaryDashboard:
            WeeklySummaryDashboardRoute(path: $path)
        case .weeklySummaryGraph(let item):
            WeeklySummaryGraphRoute(path: $path, summaryType: item)
        case .journalEntry:
            JournalEntryRoute(path: $path)
        case .progressOnCourseWork:
            ProgressOnCourseWorkRoute(path: $path)
        case .progressOnCourseWorkDetail(let courses, let index):
            ProgressOnCourseWorkDetailRoute(path: $path, courses: courses, selectedIndex: index)
        case .healthMetrics:
            HealthMetricsRoute(path: $path)
        case .healthMetricDetail(let metric):
            HealthMetricDetailRoute(path: $path, metric: metric)
        case .healthDataRange(let startDate, let endDate):
            HealthDataRangeRoute(path: $path, startDate: startDate, endDate: endDate)
        case .needToTalk:
            NeedToTalkRoute(path: $path)
        case .favoritesWeb(let urlString, let title):
            FavoritesWebRoute(path: $path, urlString: urlString, title: title)
        case .dayFeedback(let hideSkip, let dashboardTitle):
            DayFeedbackRoute(path: $path, hideSkipButton: hideSkip, dashboardNavigationTitle: dashboardTitle)

        // ---- destinations still owned by the UIKit tabs ----
        //
        // Exercises and Taking Control have not been converted, so these bridge to the
        // existing hosting controllers. `MainTabStoryboardHost` keeps them alive; they
        // become native routes when Discovery converts.
        //
        // The bridged controller installs its title and back button on its *own*
        // `navigationItem`, which belongs to a child of the stack's controller and never
        // reaches the visible bar — so the chrome has to be applied here instead.
        case .exercise(let exerciseRoute):
            LegacyHostBridge { legacyExerciseController(for: exerciseRoute) }
                .homeScreenChrome(title: exerciseRoute.screenTitle, onBack: popLast($path))
        case .takingControlIndex(let segment):
            LegacyHostBridge { TakingControlIndexHostingController.forRoute(initialSegment: segment) }
                .homeScreenChrome(title: "Taking control".localized, onBack: popLast($path))
        case .takingControlIntroSecond:
            LegacyHostBridge { TakingControlIntroSecondHostingController() }
                .homeScreenChrome(
                    title: TakingControlIntroSecondLocalization.takingControlTitle.localized,
                    onBack: popLast($path)
                )
        }
    }
}

// MARK: - UIKit host bridge
//
// Every Home view model was written against a hosting controller. Around thirty of their
// methods open with `guard let host = hostViewController` before hitting the network,
// presenting a bottom sheet or showing an alert — with no host they return silently, so
// screens such as Screenings loaded nothing at all. This representable resolves the real
// controller that owns the SwiftUI screen inside the stack and hands it over, exactly as
// `viewDidLoad` used to, then forwards the UIKit appearance callbacks.

@available(iOS 16.0, *)
private struct HomeHostBridge: UIViewControllerRepresentable {
    let onResolveHost: (UIViewController) -> Void
    let onFirstAppear: () -> Void
    let onWillAppear: () -> Void
    /// Every appearance except the first — mirrors the `hasAppeared` flag some hosting
    /// controllers used so the first load is not fired twice.
    let onReturnAppear: () -> Void
    let onWillDisappear: () -> Void

    func makeUIViewController(context: Context) -> Resolver {
        let controller = Resolver()
        controller.apply(self)
        // Some screens kick off their load from the SwiftUI view's own `.onAppear`
        // (Settings, Privacy, Profile edit, Day feedback), which can beat this
        // controller's `viewWillAppear`. Seed a usable host now — this runs while the
        // view is being built, so it is always first — and let `viewWillAppear` upgrade
        // it to the exact parent.
        if let fallbackHost = UIApplication.topViewController() {
            controller.seedHost(fallbackHost)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: Resolver, context: Context) {
        uiViewController.apply(self)
    }

    final class Resolver: UIViewController {
        private var onResolveHost: ((UIViewController) -> Void)?
        private var onFirstAppear: (() -> Void)?
        private var onWillAppear: (() -> Void)?
        private var onReturnAppear: (() -> Void)?
        private var onWillDisappear: (() -> Void)?
        private var hasAppeared = false

        /// Best-effort host used only until `viewWillAppear` resolves the real parent.
        func seedHost(_ controller: UIViewController) {
            guard !hasAppeared else { return }
            onResolveHost?(controller)
        }

        func apply(_ bridge: HomeHostBridge) {
            onResolveHost = bridge.onResolveHost
            onFirstAppear = bridge.onFirstAppear
            onWillAppear = bridge.onWillAppear
            onReturnAppear = bridge.onReturnAppear
            onWillDisappear = bridge.onWillDisappear
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            resolveHost()
            let isFirstAppearance = !hasAppeared
            hasAppeared = true

            // `onFirstAppear` is the `viewDidLoad` slot: it wires `onOpenRoute`/`onClose`
            // and runs each screen's `configure(...)`, which the SwiftUI view's own
            // `.onAppear` can depend on. It stays synchronous so that ordering is
            // unchanged.
            if isFirstAppearance { onFirstAppear?() }

            // The appearance slots are where screens refresh localized chrome and reload
            // data — i.e. where they publish. A representable's UIKit appearance callbacks
            // are delivered *inside* SwiftUI's view-update pass, so publishing straight
            // from here trips "Publishing changes from within view updates is not
            // allowed" and can drop the update. Hopping to the next main-queue turn runs
            // the exact same work, in the same order, just after the update completes.
            enqueueAfterViewUpdate { [weak self] in
                guard let self else { return }
                if !isFirstAppearance { self.onReturnAppear?() }
                self.onWillAppear?()
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Same reasoning as `viewWillAppear`: a pop is also a view update.
            enqueueAfterViewUpdate { [weak self] in
                self?.onWillDisappear?()
            }
        }

        /// Keeps every deferred callback on one FIFO queue, so their relative order
        /// (first appear -> will appear -> will disappear) is preserved.
        private func enqueueAfterViewUpdate(_ work: @escaping () -> Void) {
            DispatchQueue.main.async(execute: work)
        }

        /// The nearest ancestor sitting in the navigation stack is what the hosting
        /// controllers handed the view models as `hostViewController`.
        private func resolveHost() {
            var candidate = parent
            while let current = candidate {
                if current.navigationController != nil {
                    onResolveHost?(current)
                    return
                }
                candidate = current.parent
            }
            if let fallback = parent {
                onResolveHost?(fallback)
            }
        }
    }
}

@available(iOS 16.0, *)
private extension View {
    func homeHost(
        _ onResolveHost: @escaping (UIViewController) -> Void,
        onFirstAppear: @escaping () -> Void = {},
        onWillAppear: @escaping () -> Void = {},
        onReturnAppear: @escaping () -> Void = {},
        onWillDisappear: @escaping () -> Void = {}
    ) -> some View {
        background(
            HomeHostBridge(
                onResolveHost: onResolveHost,
                onFirstAppear: onFirstAppear,
                onWillAppear: onWillAppear,
                onReturnAppear: onReturnAppear,
                onWillDisappear: onWillDisappear
            )
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
        )
    }
}

// MARK: - Shared chrome

@available(iOS 16.0, *)
private struct HomeScreenChrome: ViewModifier {
    let title: String
    /// Screens whose hosting controller replaced the system chevron with the shared
    /// `NavigationBack` asset. `nil` keeps the system back button.
    let onBack: (() -> Void)?

    func body(content: Content) -> some View {
        Group {
            if let onBack {
                content
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            MedicationNavigationBackButton(onBack: onBack)
                        }
                    }
            } else {
                content
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
    }
}

@available(iOS 16.0, *)
private struct HomeTrailingBarItem<Item: View>: ViewModifier {
    let item: Item

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { item }
        }
    }
}

@available(iOS 16.0, *)
private extension View {
    func homeScreenChrome(title: String, onBack: (() -> Void)? = nil) -> some View {
        modifier(HomeScreenChrome(title: title, onBack: onBack))
    }

    /// Trailing bar button for the two screens whose hosting controller installed one.
    func homeTrailingBarItem<Item: View>(@ViewBuilder _ item: () -> Item) -> some View {
        modifier(HomeTrailingBarItem(item: item()))
    }
}

@available(iOS 16.0, *)
private func popLast(_ path: Binding<[HomeRoute]>) -> () -> Void {
    { if !path.wrappedValue.isEmpty { path.wrappedValue.removeLast() } }
}

/// Pushes a route — unless the stack already contains it, in which case it unwinds back
/// to the existing entry.
///
/// Several legacy "back" actions navigate by *pushing a fresh copy* of the screen below
/// them: `ScreeningListViewModel.openBack()` pushes Medical Records, and
/// `ScreeningResultViewModel.openBack()` pushes the Screening list. That worked on the
/// old storyboard stack, but on a `NavigationStack` it makes the path grow forever, so
/// back never reaches Home — it just cycles. Unwinding is what those calls actually mean.
@available(iOS 16.0, *)
private func appendRoute(_ path: Binding<[HomeRoute]>) -> (HomeRoute) -> Void {
    { route in
        var stack = path.wrappedValue
        if let index = stack.lastIndex(of: route) {
            guard index < stack.count - 1 else { return }   // already the visible screen
            stack.removeSubrange((index + 1)...)
        } else {
            stack.append(route)
        }
        path.wrappedValue = stack
    }
}

// MARK: - Half 1 destinations
//
// Ordering note: `homeHost`'s `onFirstAppear` runs once, right after the host controller
// is resolved and before `onWillAppear` — the same slot the hosting controller's
// `viewDidLoad` + the pushing controller's `configure(...)` used to occupy. Anything the
// legacy `viewWillAppear` did goes in `onWillAppear`.

@available(iOS 16.0, *)
private struct UserMedicalRecordsRoute: View {
    @Binding var path: [HomeRoute]
    /// True when Medications is the tab root, so the dashboard is *above* this screen
    /// rather than below it and "back to home" has to push rather than pop.
    let isBelowMedicationsRoot: Bool
    @StateObject private var viewModel = UserMedicalRecordsViewModel()
    var body: some View {
        UserMedicalRecordsView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.screenTitle) {
                if isBelowMedicationsRoot {
                    // Mirrors the legacy controller, which pushed a fresh dashboard here.
                    // Popping would land back on Medications and the two would cycle.
                    appendRoute($path)(.homeDashboard)
                } else {
                    viewModel.openBackToHome()
                }
            }
            // Legacy controller also installed a trailing `profileIcon` button.
            .homeTrailingBarItem {
                Button { viewModel.openProfile() } label: {
                    Image("profileIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct UserMedicationsRoute: View {
    @Binding var path: [HomeRoute]
    let isTabRoot: Bool
    @StateObject private var viewModel = UserMedicationsViewModel()
    var body: some View {
        UserMedicationsView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) {
                if isTabRoot {
                    // As the tab root there is nothing to pop to; the legacy controller
                    // pushed medical records from here.
                    appendRoute($path)(.userMedicalRecords)
                } else {
                    viewModel.openBackToMedicalRecords()
                }
            }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = isTabRoot ? {} : popLast($path)
                    // Legacy wired this from the hosting controller's `viewDidLoad`.
                    viewModel.presentFullDatePickerFromBottom = { [weak viewModel] in
                        viewModel?.presentMonthDatePicker()
                    }
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct AddEditMedicationRoute: View {
    @Binding var path: [HomeRoute]
    @ObservedObject var viewModel: AddEditMedicationViewModel
    var body: some View {
        AddEditMedicationView(viewModel: viewModel)
            // Legacy controller set no navigation title for this screen.
            .homeScreenChrome(title: "", onBack: popLast($path))
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct MedicationsDetailRoute: View {
    @Binding var path: [HomeRoute]
    let medicineDetails: MedicineDetails
    @StateObject private var viewModel: MedicationsDetailViewModel

    init(path: Binding<[HomeRoute]>, medicineDetails: MedicineDetails) {
        _path = path
        self.medicineDetails = medicineDetails
        _viewModel = StateObject(wrappedValue: MedicationsDetailViewModel(medicineDetails: medicineDetails))
    }

    var body: some View {
        MedicationsDetailView(viewModel: viewModel)
            // Legacy controller set a literal title, not a view-model property.
            .homeScreenChrome(
                title: AppHelper.getLocalizeString(str: "Medications detail"),
                onBack: popLast($path)
            )
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct NextAppointmentsRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = NextAppointmentsViewModel()
    var body: some View {
        NextAppointmentsView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) {
                viewModel.openBackToMedicalRecords()
            }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                    // Legacy wired this from the hosting controller's `viewDidLoad`.
                    viewModel.presentFullDatePickerFromBottom = { [weak viewModel] in
                        viewModel?.presentMonthDatePicker()
                    }
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct AddNewAppointmentRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel: AddNewAppointmentViewModel

    init(path: Binding<[HomeRoute]>, isEditMode: Bool, editPayload: MedicalAppointmentDetailsByDate?) {
        _path = path
        _viewModel = StateObject(wrappedValue: AddNewAppointmentViewModel(isEditMode: isEditMode, editPayload: editPayload))
    }

    var body: some View {
        AddNewAppointmentView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.screenTitle, onBack: popLast($path))
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                    // Legacy wired these from `AddNewAppointmentHostingController.viewDidLoad`,
                    // so on this SwiftUI path the Date / Time rows did nothing when tapped.
                    viewModel.presentDatePicker = { [weak viewModel] in
                        viewModel?.presentDatePickerSheet()
                    }
                    viewModel.presentTimePicker = { [weak viewModel] in
                        viewModel?.presentTimePickerSheet()
                    }
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct AppointmentDetailsRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel: AppointmentDetailsViewModel

    init(path: Binding<[HomeRoute]>, appointment: MedicalAppointmentDetailsByDate) {
        _path = path
        _viewModel = StateObject(wrappedValue: AppointmentDetailsViewModel(medicalAppointment: appointment))
    }

    var body: some View {
        AppointmentDetailsView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ScreeningListRoute: View {
    @Binding var path: [HomeRoute]
    let fromParticular: Bool
    let fromParticular1: Bool
    @StateObject private var viewModel = ScreeningListViewModel()

    var body: some View {
        ScreeningListView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    // Legacy `ScreeningListHostingController.configure(...)`.
                    viewModel.isComingFromParticularVC = fromParticular
                    viewModel.isComingFromParticularVC1 = fromParticular1
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ScreeningQuestionsRoute: View {
    @Binding var path: [HomeRoute]
    let screening: Screening
    let fromParticular: Bool
    let fromParticular1: Bool
    @StateObject private var viewModel = ScreeningQuestionsViewModel()

    var body: some View {
        ScreeningQuestionsView(viewModel: viewModel)
            // The view model derives this from the screening it is configured with; read it
            // straight off the route payload so the title is right on the first render.
            .homeScreenChrome(title: screening.screeningType) { viewModel.openBack() }
            // Legacy `refreshNavigationChrome()` installed this as a right bar button.
            .homeTrailingBarItem {
                if viewModel.showsInfoButton {
                    Button { viewModel.showInfo() } label: {
                        Image("InfoIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
            }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    // Legacy: the list configured this screen with an `onSubmissionSuccess`
                    // closure that pushed the result. Here the questions screen appends the
                    // result route itself, carrying the same provenance flags.
                    viewModel.configure(selectedScreening: screening) { submitted in
                        guard let submitted else { return }
                        appendRoute($path)(.screeningResult(
                            RouteBox(submitted),
                            fromParticular: fromParticular,
                            fromParticular1: fromParticular1
                        ))
                    }
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ScreeningResultRoute: View {
    @Binding var path: [HomeRoute]
    let screening: Screening
    let fromParticular: Bool
    let fromParticular1: Bool
    @StateObject private var viewModel = ScreeningResultViewModel()

    var body: some View {
        ScreeningResultView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.configure(selectedScreening: screening)
                    viewModel.isComingFromParticularVC = fromParticular
                    viewModel.isComingFromParticularVC1 = fromParticular1
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ScreeningHistoryRoute: View {
    @Binding var path: [HomeRoute]
    let screening: Screening
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        HistoryView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.configure(selectedScreening: screening)
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

// MARK: - Dashboard root

@available(iOS 16.0, *)
private struct HomeDashboardRoute: View {
    @Binding var path: [HomeRoute]
    let navigationTitle: String
    @StateObject private var viewModel = HomeDashboardViewModel()

    var body: some View {
        HomeDashboardView(viewModel: viewModel)
            // `HomeDashboardHostingController` hid the bar entirely — the dashboard draws
            // its own greeting header.
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    // Legacy `viewDidLoad`. Deferred because it publishes `favorites`
                    // straight away when `FavoriteManager` is already populated, and this
                    // callback runs inside SwiftUI's view update.
                    DispatchQueue.main.async { viewModel.initialLoad() }
                },
                onWillAppear: {
                    viewModel.onHostWillAppear()
                    viewModel.syncFavoritesFromManager()
                }
            )
            // Legacy `viewDidLoad` registered these two observers.
            .onReceive(NotificationCenter.default.publisher(for: .favoritesUpdated)) { _ in
                viewModel.syncFavoritesFromManager()
                // Must match the view that `fetchFavoritesFromNetwork` showed it on,
                // otherwise the spinner is never taken down — and only when this screen
                // is the one that showed it, so a silent refresh leaves other spinners be.
                viewModel.hideFavoritesActivityIfOwned()
            }
            .onReceive(NotificationCenter.default.publisher(for: .favLanUpdated)) { notification in
                // Favorite tile titles are localized when they are read, so a language
                // switch has to re-render the dashboard even when the refreshed payload
                // comes back byte-identical. `reloadLocalizedChrome()` publishes only if
                // the language really changed, so this stays a no-op otherwise.
                viewModel.reloadLocalizedChrome()
                // Same refresh for every origin; only the spinner is conditional. A
                // language change already has one up on Settings, and a tab switch is a
                // background top-up over already-rendered cached favourites — the spinner
                // there anchors to the key window and froze the whole app until
                // `fetchMenus` returned. Leaving a lesson or a favourites video keeps it,
                // because the user may just have changed a favourite.
                viewModel.fetchFavoritesFromNetwork(showsToast: notification.favLanUpdateShowsFavoritesSpinner)
            }
    }
}

// MARK: - Half 2 destinations

@available(iOS 16.0, *)
private struct UserProfileRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = UserProfileViewModel()
    var body: some View {
        UserProfileView(viewModel: viewModel)
            // Legacy `backButtonOverrideAction` pushed a fresh dashboard because the UIKit
            // stack had no root to return to; here the previous screen is already below us.
            .homeScreenChrome(title: "Settings".localized, onBack: popLast($path))
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                }
                // `onAppear()` is driven by the SwiftUI view itself, exactly as it was
                // under the hosting controller — calling it here too would double every
                // request the screen makes.
            )
    }
}

@available(iOS 16.0, *)
private struct PatientProfileEditRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = PatientProfileEditViewModel()
    var body: some View {
        // Legacy controller hid the navigation bar for this screen and set no title.
        PatientProfileEditView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                }
                // `onAppear()` is driven by the SwiftUI view itself, exactly as it was
                // under the hosting controller — calling it here too would double every
                // request the screen makes.
            )
    }
}

@available(iOS 16.0, *)
private struct ProfilePrivacyRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = ProfilePrivacyViewModel()
    var body: some View {
        ProfilePrivacyView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.privacyTitle)
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                }
                // `onAppear()` is driven by the SwiftUI view itself, exactly as it was
                // under the hosting controller — calling it here too would double every
                // request the screen makes.
            )
    }
}

@available(iOS 16.0, *)
private struct WeeklySummaryDashboardRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = WeeklySummaryDashboardViewModel()
    var body: some View {
        WeeklySummaryDashboardView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct WeeklySummaryGraphRoute: View {
    @Binding var path: [HomeRoute]
    let summaryType: WeeklySummaryItems
    @StateObject private var viewModel = WeeklySummaryGraphViewModel()
    var body: some View {
        WeeklySummaryGraphView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.configure(summaryType: summaryType)
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct JournalEntryRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = JournalEntryViewModel()
    var body: some View {
        JournalEntryView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                    viewModel.onHostViewDidLoad()
                },
                onWillAppear: { viewModel.onHostWillAppear() },
                onWillDisappear: { viewModel.onHostWillDisappear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ProgressOnCourseWorkRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = ProgressOnCourseWorkViewModel()
    var body: some View {
        ProgressOnCourseWorkView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct ProgressOnCourseWorkDetailRoute: View {
    @Binding var path: [HomeRoute]
    let courses: [PatientCourseWorkItem]
    let selectedIndex: Int
    @StateObject private var viewModel = ProgressOnCourseWorkDetailViewModel()
    var body: some View {
        ProgressOnCourseWorkDetailView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.navigationChromeTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.configure(courses: courses, selectedIndex: selectedIndex)
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct HealthMetricsRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = HealthMetricsViewModel()
    var body: some View {
        HealthMetricsView(viewModel: viewModel)
            .homeScreenChrome(title: "Health Metrics".localized) { viewModel.openBack() }
            // Legacy controller installed a trailing "Reset" item; the calendar
            // button that opens "Select Date(s)" sits to its right.
            .homeTrailingBarItem {
                HStack(spacing: 16) {
                    Button("Reset".localized) { viewModel.resetFavorites() }
                        .font(.custom(Fonts().lexendRegular, size: 14))
                        .foregroundColor(.black)

                    Button {
                        viewModel.openDateRangePicker()
                    } label: {
                        Image("calendarIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    .accessibilityLabel(Text("Select Date(s)".localized))
                }
            }
            .homeHost(
                { viewModel.hostViewController = $0 },
                // Legacy kicked off the permission sheet + first load in `viewDidLoad`
                // and only refreshed on return visits (its `hasAppeared` flag).
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                    viewModel.requestAccessAndLoad()
                },
                onReturnAppear: { viewModel.onHostWillAppear() }
            )
    }
}

@available(iOS 16.0, *)
private struct HealthMetricDetailRoute: View {
    @Binding var path: [HomeRoute]
    let metric: HealthMetric
    @StateObject private var viewModel: HealthMetricDetailViewModel

    init(path: Binding<[HomeRoute]>, metric: HealthMetric) {
        _path = path
        self.metric = metric
        _viewModel = StateObject(wrappedValue: HealthMetricDetailViewModel(metric: metric))
    }

    var body: some View {
        HealthMetricDetailView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                }
            )
    }
}

@available(iOS 16.0, *)
private struct HealthDataRangeRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel: HealthDataRangeViewModel

    init(path: Binding<[HomeRoute]>, startDate: Date, endDate: Date) {
        _path = path
        _viewModel = StateObject(wrappedValue: HealthDataRangeViewModel(startDate: startDate, endDate: endDate))
    }

    var body: some View {
        HealthDataRangeView(viewModel: viewModel)
            .homeScreenChrome(title: viewModel.screenTitle) { viewModel.openBack() }
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: { viewModel.loadIfNeeded() }
            )
    }
}

@available(iOS 16.0, *)
private struct NeedToTalkRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel = NeedToTalkViewModel()
    var body: some View {
        NeedToTalkView(viewModel: viewModel)
            // The storyboard screen subclassed `ViewController`, so it carried the shared
            // `NavigationBack` button; the hosting controller that replaced it did not.
            .homeScreenChrome(
                title: NeedToTalkPresentation.navigationTitleKey.localized,
                onBack: popLast($path)
            )
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onHostDidLoad()
                }
            )
    }
}

@available(iOS 16.0, *)
private struct FavoritesWebRoute: View {
    @Binding var path: [HomeRoute]
    let urlString: String
    let title: String
    @StateObject private var viewModel: FavoritesVideosWebViewModel

    init(path: Binding<[HomeRoute]>, urlString: String, title: String) {
        _path = path
        self.urlString = urlString
        self.title = title
        _viewModel = StateObject(wrappedValue: FavoritesVideosWebViewModel(urlString: urlString))
    }

    var body: some View {
        FavoritesVideosWebView(viewModel: viewModel)
            // Legacy subclassed `ViewController`, whose `viewDidLoad` installs the shared
            // `NavigationBack` button — not the system chevron.
            .homeScreenChrome(title: title, onBack: popLast($path))
            .homeHost({ viewModel.hostViewController = $0 })
            .onDisappear { viewModel.onHostDidDisappear() }
    }
}

@available(iOS 16.0, *)
private struct DayFeedbackRoute: View {
    @Binding var path: [HomeRoute]
    @StateObject private var viewModel: UserIntroDayFeedbackViewModel

    init(path: Binding<[HomeRoute]>, hideSkipButton: Bool, dashboardNavigationTitle: String) {
        _path = path
        _viewModel = StateObject(wrappedValue: UserIntroDayFeedbackViewModel(
            startupDayData: nil,
            dashboardNavigationTitle: dashboardNavigationTitle,
            hideSkipButton: hideSkipButton
        ))
    }

    var body: some View {
        // `DayFeedbackView` already calls `onAppearRefreshIfNeeded()` from its own `onAppear`.
        DayFeedbackView(viewModel: viewModel)
            // Legacy `configureNavigationChrome()` put the greeting in the bar, not the
            // `dashboardNavigationTitle` the caller passed in (that only flags "pushed
            // from the dashboard", which is what makes the bar visible at all).
            .homeScreenChrome(title: viewModel.greetingTitle, onBack: popLast($path))
            .homeHost(
                { viewModel.hostViewController = $0 },
                onFirstAppear: {
                    viewModel.onOpenRoute = appendRoute($path)
                    viewModel.onClose = popLast($path)
                },
                onWillAppear: {
                    viewModel.configureNavigationChrome()
                    DayFeedbackEveningReminderScheduler.cancelEveningReminder()
                },
                onWillDisappear: { DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded() }
            )
    }
}

// MARK: - Bridge to tabs that are still UIKit

/// Wraps an existing hosting controller so a Home route can reach a screen owned by a
/// tab that has not been converted yet (Exercises, Taking Control). Transitional — each
/// case here becomes a native route when its tab converts.
@available(iOS 16.0, *)
private struct LegacyHostBridge: UIViewControllerRepresentable {
    let make: () -> UIViewController
    func makeUIViewController(context: Context) -> UIViewController { make() }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
private func legacyExerciseController(for route: ExercisesRoute) -> UIViewController {
    switch route {
    case .mindfulness:            return MindfulnessHostingController()
    case .progressive:            return ProgressiveHostingController()
    case .touchButterflyIntro:    return TouchButterflyIntroHostingController()
    case .touchButterflyHowTo:    return TouchButterflyHowToHostingController()
    case .handOverYourHeart:      return HandOverYourHeartHostingController()
    case .mindfulWalking:         return MindfulWalkingHostingController()
    case .movementDance:          return MovementDanceHostingController()
    case .movementRunning:        return MovementRunningHostingController()
    case .mindfulBodyMovement:    return MindfulBodyMovementHostingController()
    case .breathingTechnique:     return BreathingTechniqueHostingController()
    case .breathingType1:         return BreathingTechniqueType1HostingController()
    case .mindfulBreathing:       return MindfulBreathingHostingController()
    case .diaphragmaticBreathing: return DiaphragmaticBreathingHostingController()
    }
}

@available(iOS 16.0, *)
private extension TakingControlIndexHostingController {
    static func forRoute(initialSegment: Int) -> TakingControlIndexHostingController {
        let host = TakingControlIndexHostingController()
        host.configure(initialSegment: initialSegment)
        return host
    }
}
