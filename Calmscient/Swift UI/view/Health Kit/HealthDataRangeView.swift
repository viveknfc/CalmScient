//
//  HealthDataRangeView.swift
//  Calmscient
//
//  Results of the "Select Date(s)" search: one card per day of the range, each
//  listing every wearable metric the backend returned for that date.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct HealthDataRangeView: View {

    @ObservedObject var viewModel: HealthDataRangeViewModel

    private enum Style {
        static let accent = Color(hex: "#6D6BB3")
        static let background = Color(hex: "#F6F5FA")
        static let separator = Color(hex: "#EFEDF6")
        static let label = Color(hex: "#7C7C8A")
        static let cardCorner: CGFloat = 16
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {

                Text(viewModel.rangeText)
                    .font(.custom(Fonts().lexendRegular, size: 12))
                    .foregroundStyle(Style.label)
                    .textCase(.uppercase)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 2)

                ForEach(viewModel.days) { day in
                    dayCard(day)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 18)
        }
        .background(Style.background)
        .refreshable { await viewModel.refresh() }
        .overlay {
            if viewModel.isLoading && viewModel.days.isEmpty {
                ProgressView()
            }
        }
        .onAppear { viewModel.loadIfNeeded() }
    }

    // MARK: - Day card

    private func dayCard(_ day: WearableRangeDayPresentation) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(spacing: 9) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Style.accent)

                Text(day.dateHeader)
                    .font(.custom(Fonts().lexendSemiBold, size: 16))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, day.isEmpty ? 10 : 12)

            if day.isEmpty {
                Text("No records".localized)
                    .font(.custom(Fonts().lexendRegular, size: 13))
                    .foregroundStyle(Style.label)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            } else {
                ForEach(Array(day.categories.enumerated()), id: \.element.id) { index, category in
                    VStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                            .fill(Style.separator)
                            .frame(height: 1)

                        categoryBlock(category)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                    }
                    .padding(.bottom, index == day.categories.count - 1 ? 4 : 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Style.cardCorner))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func categoryBlock(_ category: WearableRangeCategoryPresentation) -> some View {
        VStack(alignment: .leading, spacing: 9) {

            HStack(spacing: 7) {
                Image(systemName: category.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Style.accent)

                Text(category.title)
                    .font(.custom(Fonts().lexendMedium, size: 14))
                    .foregroundStyle(Color.primary)
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(category.rows) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(row.title)
                            .font(.custom(Fonts().lexendRegular, size: 13))
                            .foregroundStyle(Style.label)

                        Spacer(minLength: 12)

                        Text(row.valueText)
                            .font(.custom(Fonts().lexendMedium, size: 13))
                            .foregroundStyle(Style.accent)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
}

// MARK: - UIKit bridge

@available(iOS 16.0, *)
final class HealthDataRangeHostingController: UIViewController {

    private let viewModel: HealthDataRangeViewModel
    private var hostingController: UIHostingController<HealthDataRangeView>!

    init(startDate: Date, endDate: Date) {
        self.viewModel = HealthDataRangeViewModel(startDate: startDate, endDate: endDate)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: HealthDataRangeView(viewModel: viewModel))
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

    // Mirrors `HealthMetricDetailHostingController`'s bar styling.
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
struct HealthDataRangeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthDataRangeView(viewModel: .previewModel())
        }
    }
}
#endif
