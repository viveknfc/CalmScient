//
//  HealthMetricScreen.swift
//  Calmscient
//

import SwiftUI
import UIKit

// MARK: - Screen (composes the sections)

@available(iOS 16.0, *)
struct HealthMetricsView: View {

    @ObservedObject var viewModel: HealthMetricsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                ForEach(viewModel.sections) { section in
                    HealthMetricSectionView(section: section, onToggleFavorite: viewModel.toggleFavorite, onTap: viewModel.openDetail(forId:))
                        .padding(.horizontal, 20)
                }

                // Only a finished load can say "there is nothing here". Kept as a safety
                // net: the view model publishes one section per category from `init()`, so
                // in practice `sections` is never empty and this does not appear.
                if viewModel.isInitialLoadFinished && viewModel.sections.isEmpty && !viewModel.isLoading {
                    Text("No health data yet. Add data in the Health app, then pull to refresh.".localized)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable { await viewModel.refresh() }
        // There is deliberately no loading placeholder here any more.
        //
        // A full-screen `ProgressView` was covering the page until the first read finished,
        // and it was the visible half of the problem: the navigation transition landed on a
        // page that had the finished nav bar and an otherwise empty body, then the whole list
        // appeared in one crossfade half a second later. Two separate events, which reads as
        // a flash rather than as loading.
        //
        // The view model now publishes the real sections from `init()` — the catalog is
        // static, so every row exists before any value does, showing "--" until it is read —
        // so the page arrives complete and only the numbers change. Nothing is ever covered,
        // and there is nothing left to crossfade.

        // Date range calendar — a popup over this screen, so "Search" pushes the
        // results from here and back from the results returns to Health Metrics.
        .overlay {
            if viewModel.isDateRangePickerPresented {
                HealthDateRangePickerView(viewModel: viewModel.dateRangePicker)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isDateRangePickerPresented)
    }
}

// MARK: - UIKit bridge (push onto the shared nav stack)

@available(iOS 16.0, *)
final class HealthMetricsHostingController: UIViewController {

    private let viewModel = HealthMetricsViewModel()
    private var hostingController: UIHostingController<HealthMetricsView>!
    private var hasAppeared = false
    /// First load + permission prompt happen once, from `viewDidAppear`.
    private var hasRequestedHealthAccess = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: HealthMetricsView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false

        // Load values on return visits (first load is kicked off in viewDidAppear).
        if hasAppeared { viewModel.onHostWillAppear() }
        hasAppeared = true

        applyNavigationChrome()
    }

    /// The permission sheet + first load used to run from `viewDidLoad`, i.e. while the
    /// push animation was still in flight — presenting HealthKit's modal on top of a
    /// running transition is what made the page flick. `viewDidAppear` is the same work,
    /// once, just after the screen has settled.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasRequestedHealthAccess else { return }
        hasRequestedHealthAccess = true
        viewModel.requestAccessAndLoad()   // permission sheet + first load
    }

    // MARK: - Navigation chrome (mirrors WeeklySummaryDashboardHostingController)
    // Opaque white bar + Lexend title + the app-wide "NavigationBack" back button.
    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Health Metrics".localized

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.black,
            ]
        }
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.compactScrollEdgeAppearance = appearance
            navBar.shadowImage = UIImage()
        }

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openBack()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        // Reset favorites (nav bar, right side)
        let resetItem = UIBarButtonItem(
            title: "Reset".localized,
            style: .plain,
            target: self,
            action: #selector(resetFavoritesTapped))
        if let resetFont = UIFont(name: Fonts().lexendRegular, size: 14) {
            resetItem.setTitleTextAttributes([.font: resetFont, .foregroundColor: UIColor.black], for: .normal)
            resetItem.setTitleTextAttributes([.font: resetFont, .foregroundColor: UIColor.black], for: .highlighted)
        }
        // Calendar (opens "Select Date(s)"). The first element of
        // `rightBarButtonItems` is the right-most, so this sits after Reset.
        let calendarButton = UIButton(type: .custom)
        calendarButton.setImage(UIImage(named: "calendarIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        calendarButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openDateRangePicker()
        }, for: .touchUpInside)
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        calendarButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        calendarButton.heightAnchor.constraint(equalToConstant: 24).isActive = true

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: calendarButton), resetItem]
    }

    @objc private func resetFavoritesTapped() {
        viewModel.resetFavorites()
    }
}


#if DEBUG
@available(iOS 16.0, *)
struct HealthMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthMetricsView(viewModel: .previewModel())
        }
    }
}
#endif
