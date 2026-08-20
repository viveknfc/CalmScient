//
//  HealthMetricDetailView.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import SwiftUI
import UIKit

// MARK: - Detail screen (Week / Month / Year averages chart + insights)

@available(iOS 16.0, *)
struct HealthMetricDetailView: View {

    @ObservedObject var viewModel: HealthMetricDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                HealthMetricPeriodTabsView(
                    periods: viewModel.periods,
                    selectedPeriod: viewModel.selectedPeriod,
                    onSelect: { viewModel.select($0) }
                )

                if !viewModel.periodRangeText.isEmpty {
                    Text(viewModel.periodRangeText)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 12))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }

                HealthMetricChartCardView(
                    title: viewModel.chartTitle,
                    points: viewModel.points,
                    orderedLabels: viewModel.orderedLabels,
                    useBars: viewModel.useBars,
                    showsLegend: viewModel.showsLegend,
                    emptyMessage: emptyMessage
                )

                if !viewModel.insights.isEmpty {
                    HealthMetricInsightsCardView(insights: viewModel.insights)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            // First load is covered by the shared toast spinner; tab switches keep
            // the previous chart on screen behind this one.
            if viewModel.isLoading && viewModel.hasLoaded {
                ProgressView()
            }
        }
        .onAppear { viewModel.loadIfNeeded() }
    }

    private var emptyMessage: String {
        viewModel.hasLoaded
            ? "No data available for this period.".localized
            : ""
    }
}

// MARK: - UIKit bridge

@available(iOS 16.0, *)
final class HealthMetricDetailHostingController: UIViewController {

    private let viewModel: HealthMetricDetailViewModel
    private var hostingController: UIHostingController<HealthMetricDetailView>!

    init(metric: HealthMetric) {
        self.viewModel = HealthMetricDetailViewModel(metric: metric)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: HealthMetricDetailView(viewModel: viewModel))
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
        applyNavigationChrome()
    }

    // Mirrors HealthMetricsHostingController's bar styling.
    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.screenTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [.font: customFont, .foregroundColor: UIColor.black]
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
        backButton.addAction(UIAction { [weak self] _ in self?.viewModel.openBack() }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct HealthMetricDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthMetricDetailView(viewModel: .previewModel())
        }
    }
}
#endif
