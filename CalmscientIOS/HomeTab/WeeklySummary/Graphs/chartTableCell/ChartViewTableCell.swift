//
//  ChartViewTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 01/05/24.
//

import UIKit
import DGCharts

class ChartViewTableCell: UITableViewCell {

    @IBOutlet weak var chartViewTitleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var barChartView: BarChartView!
    var graphData:[GraphData] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        
        lineChartView.doubleTapToZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        graphData = []
        
        lineChartView.data = nil
        lineChartView.notifyDataSetChanged()
        barChartView.data = nil
        barChartView.notifyDataSetChanged()
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
//        borderView.layer.borderWidth = 1
//        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        borderView.applyShadow()
    }
    
    func setupMoodLineChartView(graphData:[GraphData]) {
        
        self.graphData = graphData
        //Hide Bar Chart
        self.bringSubviewToFront(lineChartView)
        barChartView.isHidden = true
        lineChartView.isHidden = false
        guard graphData.count > 0 else {
            lineChartView.data = nil
            lineChartView.notifyDataSetChanged()
            lineChartView.noDataText = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No Data Found" : "No se encontraron datos"
            lineChartView.animate(xAxisDuration: 0.01)
            return
        }
       
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        lineChartView.xAxis.valueFormatter = XAxisLineChartFormatter(graphData: graphData)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesBehindDataEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelCount = graphData.count - 1
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = Double(graphData.count - 1)
        lineChartView.rightAxis.enabled = false
        
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.valueFormatter = MoodChartYAxisFormatter()
        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.zeroLineWidth = 0
        leftAxis.labelCount = 5
        leftAxis.axisMaximum = 5
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [2, 2]
        leftAxis.drawBottomYLabelEntryEnabled = false
    
        var chartDataEntries:[ChartDataEntry] = []
        for (idx,datum) in graphData.enumerated() {
            let entry = ChartDataEntry(x: Double(idx), y: Double(datum.yValue))
            print("GDTest \(entry.x) & \(entry.y)")
            chartDataEntries.append(entry)
        }
        
        let chartDataSet = LineChartDataSet(entries: chartDataEntries)
        chartDataSet.lineWidth = 2
        chartDataSet.colors = [UIColor(named: "lineChartViewLineColor")!]
        chartDataSet.circleColors = [UIColor.white]
        chartDataSet.circleRadius = 5
        chartDataSet.circleHoleColor = UIColor(named: "lineChartViewInternalCircleColor")
        chartDataSet.circleHoleRadius = 2
        chartDataSet.drawValuesEnabled = false
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        
        let marker = LineChartViewMarkerView(color: UIColor(named: "chartsMarkerColor") ?? UIColor.lightGray,
                                             font: UIFont(name: Fonts().lexendRegular, size: 12)!,
                                             textColor: .black,
                                             insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),xAxisValueFormatter: XAxisLineChartFormatter(graphData: graphData), data: graphData)
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 100, height: 45)
//        lineChartView.marker = marker
        lineChartView.fitScreen()
        lineChartView.extraRightOffset = 20
        lineChartView.extraLeftOffset = 10
        lineChartView.extraTopOffset = 30
        lineChartView.extraBottomOffset = 10
        lineChartView.animate(xAxisDuration: 2.5)
        
    }
    
    
    private func getYAxisMaximumValue() -> Int {
        var maxValue = 0
        for datum in graphData {
            if maxValue < datum.yValue {
                maxValue = datum.yValue
            }
        }
        print("Y max value that we are getting is ",maxValue)
        return maxValue
    }
    
    
    
    func setupLineChartView(graphDataValues:[GraphData]) {
        
        for graphValue in graphDataValues {
            print("the graph value is", graphValue.yValue)
        }
        
        self.graphData = graphDataValues
        //Hide Bar Chart
        self.bringSubviewToFront(lineChartView)
        barChartView.isHidden = true
        lineChartView.isHidden = false

        guard graphData.count > 0 else {
            lineChartView.data = nil
            lineChartView.notifyDataSetChanged()
            lineChartView.noDataText = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No Data Found" : "No se encontraron datos"
            lineChartView.animate(xAxisDuration: 0.01)
            return
        }
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        lineChartView.xAxis.valueFormatter = XAxisLineChartFormatter(graphData: self.graphData)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesBehindDataEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        if (self.graphData.count > 0) {
            lineChartView.xAxis.labelCount = self.graphData.count // -1 was there
            lineChartView.xAxis.axisMinimum = 0
            lineChartView.xAxis.axisMaximum = Double(self.graphData.count - 1)
            lineChartView.xAxis.granularity = 1.0 //new
            lineChartView.xAxis.granularityEnabled = true //new
            lineChartView.xAxis.forceLabelsEnabled = true //new

        } else {
            lineChartView.xAxis.labelCount = 0
        }
      
        
        lineChartView.rightAxis.enabled = false
        
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.valueFormatter = ScoreAxisFormatter()
        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.zeroLineWidth = 0
        // Determine maximum Y value
        let maxYValue = self.graphData.map { $0.yValue }.max() ?? 0

        // Adjust granularity based on max Y value
//        if maxYValue > 20 {
//            leftAxis.granularity = 3
//        } else if maxYValue > 10 {
//            leftAxis.granularity = 2
//        } else {
//            leftAxis.granularity = 1
//        }
//
//        
//        if (self.graphData.count > 0) {
//            leftAxis.labelCount = self.getYAxisMaximumValue()
//            leftAxis.axisMaximum = Double(self.getYAxisMaximumValue())
//            leftAxis.axisMinimum = 0
//        } else {
//            leftAxis.labelCount = 0
//        }
        
        if self.graphData.count > 0 {
            let granularity: Double
            if maxYValue > 20 {
                granularity = 3
            } else if maxYValue > 10 {
                granularity = 2
            } else {
                granularity = 1
            }
            
            leftAxis.granularity = granularity
            leftAxis.granularityEnabled = true

            let adjustedMaxY = ceil(Double(maxYValue) / granularity) * granularity
            leftAxis.axisMaximum = adjustedMaxY
            leftAxis.axisMinimum = 0
            leftAxis.labelCount = Int((adjustedMaxY / granularity) + 1)
        } else {
            leftAxis.labelCount = 0
        }

        
        leftAxis.gridLineDashLengths = [2, 2]
        leftAxis.drawBottomYLabelEntryEnabled = false
    
        var chartDataEntries:[ChartDataEntry] = []
        for (idx,datum) in self.graphData.enumerated() {
            let entry = ChartDataEntry(x: Double(idx), y: Double(datum.yValue))
            print("KIS \(entry.x) & \(entry.y)")
            chartDataEntries.append(entry)
        }
        
        let chartDataSet = LineChartDataSet(entries: chartDataEntries)
        chartDataSet.lineWidth = 2
        chartDataSet.colors = [UIColor(named: "lineChartViewLineColor")!]
        chartDataSet.circleColors = [UIColor.white]
        chartDataSet.circleRadius = 5
        chartDataSet.circleHoleColor = UIColor(named: "lineChartViewInternalCircleColor")
        chartDataSet.circleHoleRadius = 2
        chartDataSet.drawValuesEnabled = false
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        
        let marker = LineChartViewMarkerView(color: UIColor(named: "chartsMarkerColor") ?? UIColor.lightGray,
                                             font: UIFont(name: Fonts().lexendRegular, size: 12)!,
                                             textColor: .black,
                                             insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),xAxisValueFormatter: XAxisLineChartFormatter(graphData: graphDataValues), data: graphDataValues)
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 100, height: 45)
        lineChartView.marker = marker
        lineChartView.fitScreen()
        lineChartView.extraRightOffset = 20
        lineChartView.extraLeftOffset = 20
        lineChartView.extraTopOffset = 30
        lineChartView.extraBottomOffset = 10
        lineChartView.animate(xAxisDuration: 2.5)
    }
    
    public func setupbarChartView(data:[GraphData]) {
        self.graphData = data
        
        for graph in data {
            print("the graph data for bar chart is", graph.xValue) //graphData.last?.xValue ?? "NA"
        }
        
        
        self.bringSubviewToFront(barChartView)
        lineChartView.isHidden = true
        barChartView.isHidden = false
        
        guard graphData.count > 0 else {
            barChartView.data = nil
            barChartView.notifyDataSetChanged()
            barChartView.noDataText = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No Data Found" : "No se encontraron datos"
            barChartView.animate(xAxisDuration: 0.01)
            return
        }
        
        // Do any additional setup after loading the view.
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.legend.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimum = 1
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 0
        
        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = UIFont(name: Fonts().lexendRegular, size: 12)!

        leftAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelCount = self.getYAxisMaximumValue()
        leftAxis.axisMaximum = Double(self.getYAxisMaximumValue())
        leftAxis.valueFormatter = MoodValueAxisFormatter()
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        barChartView.rightAxis.enabled = false
        
        barChartView.xAxis.drawGridLinesEnabled = false
        
        
        
        let xAxis = barChartView.xAxis
        barChartView.xAxis.labelTextColor = UIColor(named: "lineChartLabelColor")!
        xAxis.drawAxisLineEnabled = false
        xAxis.labelCount = 5
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: Fonts().lexendRegular, size: 12)!
        xAxis.valueFormatter = MoodAxisFormatter()
        var entries:[BarChartDataEntry] = []
        let colors = [UIColor(named: "barColor1")!,UIColor(named: "barColor2")!,UIColor(named: "barColor3")!,UIColor(named: "barColor4")!,UIColor(named: "barColor5")!]
        for (idx,val) in graphData.enumerated() {
            let entry = BarChartDataEntry(x: Double(idx+1), y: Double(val.yValue)) //+1 added
            print("the entry of BarChartDataEntry is", entry)
            entries.append(entry)    
        }
        let dataset = BarChartDataSet(entries: entries)
        dataset.colors = colors
        
        let barChartData = BarChartData(dataSet: dataset)
        barChartData.barWidth = 0.5
        barChartView.data = barChartData
        barChartView.data?.setDrawValues(false)
        
        let marker = XYMarkerView(color: UIColor(named: "chartsMarkerColor") ?? UIColor.lightGray,
                                  font: UIFont(name: Fonts().lexendRegular, size: 12)!,
                                  textColor: .black,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: MoodAxisFormatter(), yAxisFormatter: MoodValueAxisFormatter())
        marker.chartView = barChartView
        marker.minimumSize = CGSize(width: 100, height: 45)
//        barChartView.marker = marker
        
        barChartView.animate(yAxisDuration: 2)
    }
    
}



public class MoodAxisFormatter:AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        switch value {
        case 5: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "EXCELLENT" : "EXCELENTE"
        case 3: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "FAIR" : "JUSTO"
        case 2: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "COULD BE\n BETTER" : "PODRÍA SER\n MEJOR"
        case 1: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "BAD" : "MALO"
        case 4: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "GOOD" : "BUENO"
        default: return ""
        }
    }
    
    
}

public class MoodValueAxisFormatter:AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        print("Y value is \(Int(value))")
        return "\(Int(value))"
    }
    
    
}


public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: MoodAxisFormatter
    public var yAxisFormatter: MoodValueAxisFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: MoodAxisFormatter, yAxisFormatter: MoodValueAxisFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        self.xAxisValueFormatter = xAxisValueFormatter
        self.yAxisFormatter = yAxisFormatter
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let string = "\(self.xAxisValueFormatter.stringForValue(entry.x, axis: XAxis()).localizedLowercase): \(self.yAxisFormatter.stringForValue(entry.y, axis: YAxis())) Days"
        setLabel(string)
    }
    
}

public class LineChartViewMarkerView: BalloonMarker {
    public var chartData: [GraphData]
    
    public var xAxisValueFormatter:XAxisLineChartFormatter
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: XAxisLineChartFormatter, data:[GraphData]) {
        self.xAxisValueFormatter = xAxisValueFormatter
        self.chartData = data
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let obj = chartData[Int(entry.x)]
        setLabel(obj.getMarkerTextValue())
    }
    
}


public class XAxisLineChartFormatter: AxisValueFormatter {
    
    var graphData:[GraphData]
    init(graphData: [GraphData]) {
        self.graphData = graphData
        print("graph data is", graphData)
    }
    
    public func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        let index = Int(round(value))
//           print("Rounded value: \(index)")
           if index >= 0 && index < graphData.count {
               let obj = graphData[index].getXAxisLabelValue()
               return obj
           } else {
               return ""
           }

    }
    
}

public class ScoreAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        return "\(Int(value))"
    }
    
}

public class MoodChartYAxisFormatter: AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        switch Int(value) {
        case 5: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "EXCELLENT" : "EXCELENTE"
        case 3: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "FAIR" : "JUSTO"
        case 2: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "COULD BE\n BETTER" : "PODRÍA SER\n MEJOR"
        case 1: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "BAD" : "MALO"
        case 4: return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "GOOD" : "BUENO"
        default: return "N/A"
        }
    }
    
}


