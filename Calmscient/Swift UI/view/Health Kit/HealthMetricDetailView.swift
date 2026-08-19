//
//  HealthMetricDetailView.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import SwiftUI
import UIKit

// MARK: - Metric trend screen (period control + chart + data source + insight)

@available(iOS 16.0, *)
struct HealthMetricDetailView: View {

    @ObservedObject var viewModel: HealthMetricDetailViewModel

    /// `#6D6BB3` — the brand purple behind the calendar's Search button, and the colour the
    /// rest of the app reaches for under this same name. Not the login flow's
    /// `ColorName.purple`, which is a noticeably more saturated violet.
    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop

    /// The unselected pill / segmented track. Same tint and opacity as the date picker's
    /// in-range band, so the two screens read as one family.
    private var brandPurpleSoft: Color { brandPurple.opacity(0.14) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                periodControl

                ZStack {
                    HealthTrendChartCardView(
                        title: viewModel.chartTitle,
                        unit: viewModel.metric.unit,
                        data: viewModel.chart
                    )
                    // The spinner sits over the card instead of replacing it, so switching
                    // tabs doesn't collapse the layout and bounce the sections below.
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }

                dataSourceSection
                insightCard
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Weekly / Monthly / Yearly

    private var periodControl: some View {
        HStack(spacing: 0) {
            ForEach(HealthTrendPeriod.allCases) { period in
                let isSelected = period == viewModel.period
                Button {
                    viewModel.select(period: period)
                } label: {
                    Text(period.localizedTitle)
                        .font(.custom(isSelected ? Fonts().lexendMedium : Fonts().lexendRegular,
                                      size: 15))
                        .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(brandPurple)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(brandPurpleSoft)
        )
        .animation(.easeInOut(duration: 0.2), value: viewModel.period)
    }

    // MARK: - Data source

    private var dataSourceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data Source".localized)
                .font(.custom(Fonts().lexendRegular, size: 13))
                .foregroundStyle(.secondary)

            ForEach(viewModel.dataSources) { source in
                let isSelected = source.id == viewModel.selectedDataSourceId
                Button {
                    viewModel.selectedDataSourceId = source.id
                } label: {
                    Text(source.title)
                        .font(.custom(isSelected ? Fonts().lexendMedium : Fonts().lexendRegular,
                                      size: 15))
                        .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected
                                      ? AnyShapeStyle(brandPurple)
                                      : AnyShapeStyle(brandPurpleSoft))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
            }
        }
    }

    // MARK: - Insight

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(brandPurple))

            VStack(alignment: .leading, spacing: 6) {
                Text("Insight".localized)
                    .font(.custom(Fonts().lexendMedium, size: 16))
                    .foregroundStyle(.primary)

                Text(viewModel.insightText)
                    .font(.custom(Fonts().lexendRegular, size: 14))
                    .foregroundStyle(.primary.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
