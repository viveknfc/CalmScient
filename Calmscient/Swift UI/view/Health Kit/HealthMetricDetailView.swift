//
//  HealthMetricDetailView.swift
//  Calmscient
//
//  Created by NFC Solutions on 12/08/26.
//

import SwiftUI
import UIKit

// MARK: - Detail screen (date range + dated value list)

@available(iOS 16.0, *)
struct HealthMetricDetailView: View {

    @ObservedObject var viewModel: HealthMetricDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                // Date range selection (reuses the app-wide calendar bottom sheet)
                VStack(alignment: .leading, spacing: 14) {
                    dateField(title: "From".localized,
                              valueText: viewModel.fromDateText) {
                        viewModel.presentFromDatePicker()
                    }

                    dateField(title: "To".localized,
                              valueText: viewModel.toDateText) {
                        viewModel.presentToDatePicker()
                    }

                    Button {
                        viewModel.loadRange()
                    } label: {
                        Text("Go".localized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LoginDesignSystem.ColorName.loginGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 20)
                }

                // Dated value list
                if viewModel.rows.isEmpty && !viewModel.isLoading {
                    Text("No data for the selected date.".localized)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.rows) { row in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(row.dateHeader)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            valueCard(valueText: row.valueText)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewModel.isLoading && viewModel.rows.isEmpty {
                ProgressView()
            }
        }
        .onAppear { if viewModel.rows.isEmpty { viewModel.loadCurrentDate() } }
    }

    // A "From"/"To" label above the shared calendar field (WeeklySummaryGraphDateRangeHeaderView).
    private func dateField(title: String,
                           valueText: String,
                           onTap: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom(Fonts().lexendRegular, size: 13))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            WeeklySummaryGraphDateRangeHeaderView(
                dateRangeText: valueText,
                onCalendarTap: onTap
            )
        }
    }

    // Mirrors HealthMetricRowView's look (icon + title + value), without the star.
    private func valueCard(valueText: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 40, height: 40)
                Image(systemName: viewModel.metric.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.pink)
            }

            Text(viewModel.metric.titleKey.localized)
                .font(.system(size: 16))
                .foregroundStyle(.primary)

            Spacer()

            Text(valueText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
