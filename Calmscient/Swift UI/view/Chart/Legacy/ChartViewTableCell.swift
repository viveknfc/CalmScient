//
//  ChartViewTableCell.swift
//  Calmscient
//
//  UIKit table cell hosting DGCharts (iOS 15 weekly summary graph fallback only).
//
//  Vivek
//  18 May 2026
//

import DGCharts
import UIKit

final class ChartViewTableCell: UITableViewCell {

    @IBOutlet weak var chartViewTitleLabel: UILabel!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var lineChartView: LineChartView!
    @IBOutlet private weak var barChartView: BarChartView!

    var graphData: [GraphData] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        lineChartView.doubleTapToZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        graphData = []
        lineChartView.data = nil
        lineChartView.notifyDataSetChanged()
        barChartView.data = nil
        barChartView.notifyDataSetChanged()
    }

    private func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
        borderView.applyShadow()
    }

    func setupMoodLineChartView(graphData: [GraphData]) {
        self.graphData = graphData
        bringSubviewToFront(lineChartView)
        barChartView.isHidden = true
        lineChartView.isHidden = false
        WeeklySummaryChartConfigurator.configureMoodLineChart(lineChartView, graphData: graphData)
    }

    func setupLineChartView(graphDataValues: [GraphData]) {
        graphData = graphDataValues
        bringSubviewToFront(lineChartView)
        barChartView.isHidden = true
        lineChartView.isHidden = false
        WeeklySummaryChartConfigurator.configureScoreLineChart(lineChartView, graphData: graphDataValues)
    }

    func setupbarChartView(data: [GraphData]) {
        graphData = data
        bringSubviewToFront(barChartView)
        lineChartView.isHidden = true
        barChartView.isHidden = false
        WeeklySummaryChartConfigurator.configureBarChart(barChartView, graphData: data)
    }
}
