//
//  WeeklySummaryDashboardViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//
//  iOS 16+: embeds `WeeklySummaryDashboardHostingController` (SwiftUI grid).
//

import SwiftUI
import UIKit

class WeeklySummaryDashboardViewController: ViewController {

    private lazy var dashboardCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = view.bounds.width - 42
        flowLayout.itemSize = CGSize(width: cellWidth / 2, height: 125)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
        flowLayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 16.0, *) {
            installSwiftUIWeeklySummaryHost()
        } else {
            installLegacyCollectionView()
        }
    }

    @available(iOS 16.0, *)
    private func installSwiftUIWeeklySummaryHost() {
        let host = WeeklySummaryDashboardHostingController()
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        // Margins + SwiftUI host layout live inside `WeeklySummaryDashboardHostingController`.
    }

    private func installLegacyCollectionView() {
        navigationController?.isNavigationBarHidden = false
        let nib = UINib(nibName: "WeeklySummaryDashboardCell", bundle: nil)
        dashboardCollectionView.backgroundColor = UIColor(named: "AppBackGroundColor")
        dashboardCollectionView.register(nib, forCellWithReuseIdentifier: "WeeklySummaryDashboardCell")
        dashboardCollectionView.delegate = self
        dashboardCollectionView.dataSource = self
        view.addSubview(dashboardCollectionView)
        dashboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashboardCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            dashboardCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dashboardCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dashboardCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        dashboardCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if #unavailable(iOS 16.0) {
            title = "Weekly summary".localized
        }
    }
}

// MARK: - Legacy collection (iOS 15 and below)

extension WeeklySummaryDashboardViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    private var legacyCatalogEntries: [WeeklySummaryDashboardCatalogEntry] {
        WeeklySummaryDashboardCatalog.gridEntries
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        legacyCatalogEntries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "WeeklySummaryDashboardCell",
            for: indexPath
        ) as? WeeklySummaryDashboardCell else {
            return UICollectionViewCell()
        }
        let entry = legacyCatalogEntries[indexPath.row]
        cell.cellImageView.image = UIImage(named: entry.item.getAssetName())
        cell.cellTitleLabel.text = entry.item.localized
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isConnected else {
            NoInternetBanner.shared.openDetails()
            return
        }
        guard let nav = navigationController else { return }
        WeeklySummaryDashboardNavigation.push(entry: legacyCatalogEntries[indexPath.row], from: nav)
    }
}
