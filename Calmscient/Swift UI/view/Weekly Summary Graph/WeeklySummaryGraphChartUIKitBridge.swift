//
//  WeeklySummaryGraphChartUIKitBridge.swift
//  Calmscient
//
//  UIKit bridge for sleep summary card (`SleepSummaryTableViewCell`).
//
//  Vivek
//  18 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct WeeklySummaryGraphSleepSummaryRepresentable: UIViewRepresentable {
    let presentation: WeeklySummaryGraphSleepPresentation
    let title: String
    let mostHoursTitle: String
    let averageHoursTitle: String
    let leastHoursTitle: String

    func makeUIView(context: Context) -> WeeklySummaryGraphSleepHostView {
        WeeklySummaryGraphSleepHostView()
    }

    func updateUIView(_ uiView: WeeklySummaryGraphSleepHostView, context: Context) {
        uiView.apply(
            presentation: presentation,
            title: title,
            mostHoursTitle: mostHoursTitle,
            averageHoursTitle: averageHoursTitle,
            leastHoursTitle: leastHoursTitle
        )
    }
}

@available(iOS 16.0, *)
final class WeeklySummaryGraphSleepHostView: UIView {

    private let sleepCell: SleepSummaryTableViewCell

    override init(frame: CGRect) {
        guard let cell = Bundle.main.loadNibNamed("SleepSummaryTableViewCell", owner: nil, options: nil)?.first as? SleepSummaryTableViewCell else {
            fatalError("Unable to load SleepSummaryTableViewCell")
        }
        sleepCell = cell
        super.init(frame: frame)
        sleepCell.selectionStyle = .none
        addPinnedSubview(sleepCell.contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(
        presentation: WeeklySummaryGraphSleepPresentation,
        title: String,
        mostHoursTitle: String,
        averageHoursTitle: String,
        leastHoursTitle: String
    ) {
        sleepCell.titleLbl.text = title
        sleepCell.mostHrsSleptTitle.text = mostHoursTitle
        sleepCell.avgHrsSleptTitle.text = averageHoursTitle
        sleepCell.leastHrsSleptTitle.text = leastHoursTitle
        sleepCell.mostHrsSleptLbl.text = presentation.mostHoursText
        sleepCell.avgHrsSleptLbl.text = presentation.averageHoursDetailText
        sleepCell.leastHrsSleptLbl.text = presentation.leastHoursText

        let averageValue = Float(presentation.averageHoursText) ?? 0
        sleepCell.configureCell(with: averageValue)

        let attrText = NSMutableAttributedString(
            string: "\(presentation.averageHoursText) / ",
            attributes: [
                .font: UIFont(name: Fonts().lexendMedium, size: 14) ?? UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(hex: "#9B9B9B"),
            ]
        )
        let isDark = (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as? Bool ?? false
        attrText.append(NSMutableAttributedString(
            string: presentation.averageHoursDenominator,
            attributes: [
                .font: UIFont(name: Fonts().lexendMedium, size: 14) ?? UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(hex: isDark ? "#FFFFFF" : "#000000"),
            ]
        ))
        sleepCell.noOfHrsSlept.attributedText = attrText
    }
}

@available(iOS 16.0, *)
private extension UIView {
    func addPinnedSubview(_ child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
