//
//  WeeklySummaryGraphViewController.swift
//  Calmscient
//
//  UIKit weekly summary graph screen (iOS 15 fallback; iOS 16+ uses `WeeklySummaryGraphHostingController`).
//
//  Vivek
//  18 May 2026
//

import UIKit

class WeeklySummaryGraphViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var needToTalkSomeOneButton: LinearGradientButton!
    
    private let hardCodedStartDate:String = "05/12/2024"
    private let hardCodedEndDate:String = "05/27/2024"
    var avgSleepHrs: Float = 0
    
    
    var summaryType:WeeklySummaryItems = .WeeklySummarySummaryOfMood {
        didSet {
            self.tableDataList = summaryType.getTableCellList()
        }
    }
    
    private let dateDifference = -6
    
    var dateRange:(fromDate:Date, toDate:Date) = (Date().getOlderDateWithDaysDifference(minusDays: -6), Date())
    var chartData:[GraphData] = []
    var tableDataList:[WeeklySummaryGraphViewTableCell] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguage()
        let needToTalk = "Need to talk with someone?".localized
        needToTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: needToTalk)
        needToTalkSomeOneButton.applyNeedToTalkButtonVisibility()
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "ChartViewHeaderTableCell", bundle: nil), forCellReuseIdentifier: "ChartViewHeaderTableCell")
        tableView.register(UINib(nibName: "ChartViewTableCell", bundle: nil), forCellReuseIdentifier: "ChartViewTableCell")
        tableView.register(UINib(nibName: "SleepSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SleepSummaryTableViewCell")
        getDataFromAPI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    // MARK: - Network Hooks ✅
      override func onNetworkRestored() {
          // Auto-refresh data when internet comes back
          getDataFromAPI()
      }
    
    override func onNetworkLost() {
           // Optional: stop any loading indicators
           self.view.hideToastActivity()
       }
      
    func setupLanguage() {
        needToTalkSomeOneButton.applyNeedToTalkButtonVisibility()
    }
    @IBAction func needToTalkButtonAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
               let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
               vc?.title = "Emergency resource"
               self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func getDataFromAPI() {
        guard isConnected else { return } // ✅ isConnected from BaseViewController

        self.view.showToastActivity()
        tableDataList = summaryType.getTableCellList()
        summaryType.getServerResponsefrom(startDate: dateRange.fromDate.dateToString(format: "MM/dd/yyyy"), and: dateRange.toDate.dateToString(format: "MM/dd/yyyy")) { [weak self] graphData, serverResponse, error in
            self?.view.hideToastActivity()
            guard let responseData = graphData else {
                return
            }
            self?.chartData = responseData
            if let chartData = self?.chartData {
                for data in chartData {
                    print("ChartData - xValue: \(data.xValue), yValue: \(data.yValue), additionalInfo: \(data.additionalInfo ?? "nil"), graphType: \(data.graphDataType)")
                }
            }

            self?.tableView.reloadData()
        }
    }

    private func prepareBarChartData(data:[GraphData]) -> [GraphData] {
        let badCount = data.filter { $0.yValue == 1 }.count
        let couldBeBetterCount = data.filter { $0.yValue == 2 }.count
        let fairCount = data.filter { $0.yValue == 3 }.count
        let goodCount = data.filter { $0.yValue == 4 }.count
        let excellentCount = data.filter { $0.yValue == 5 }.count
        
        var preparedData: [GraphData] = []
        
        // Use numeric xAxis values expected by MoodAxisFormatter
        preparedData.append(GraphData(yAxisValue: badCount, xAxisValue: "1", additionalInfo: "BAD", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: couldBeBetterCount, xAxisValue: "2", additionalInfo: "COULD BE BETTER", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: fairCount, xAxisValue: "3", additionalInfo: "FAIR", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: goodCount, xAxisValue: "4", additionalInfo: "GOOD", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: excellentCount, xAxisValue: "5", additionalInfo: "EXCELLENT", graphType: .WeeklySummarySummaryOfMood))
        
        return preparedData
    }
    
    private func normalizeMood(_ value: String?) -> String? {
//        guard let value = value?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }

        guard let value = value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased() else { return nil }
        
        switch value {
        case "excellent", "excelente":
            return "EXCELLENT"
        case "good", "bueno":
            return "GOOD"
        case "fair", "justo", "masomenos", "mas o menos":
            return "FAIR"
        case "could be better", "could be\nbetter", "podría ser mejor", "podría ser\nmejor", "podria ser mejor", "podria ser\nmejor":
            return "COULD BE BETTER"
        case "bad", "mal", "悪い":
            return "BAD"
        case "もっと良くしたい", "もう少し良くなれる":
            return "COULD BE BETTER"
        case "まあまあ":
            return "FAIR"
        case "良い":
            return "GOOD"
        case "とても良い", "素晴らしい":
            return "EXCELLENT"
        default:
            return nil
        }
    }

}

extension WeeklySummaryGraphViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryType.getTableCellList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cellType = tableDataList[indexPath.row]
        
        switch cellType {
            
        case .GraphSelectionTableHeaderCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewHeaderTableCell", for: indexPath) as? ChartViewHeaderTableCell else {
                return UITableViewCell()
            }
            cell.userSelectedNewDates = { [weak self] (fromDate, toDate) in
                self?.dateRange = (fromDate,toDate)
                self?.chartData = []
                self?.tableView.reloadData()
                self?.getDataFromAPI()
            }
            cell.selectionStyle = .none
            return cell
        case .WeeklySummaryGraphViewCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewTableCell", for: indexPath) as? ChartViewTableCell else {
                return UITableViewCell()
            }
            cell.chartViewTitleLabel.text = summaryType.graphTitle
            if summaryType == .WeeklySummarySummaryOfMood {
                cell.setupMoodLineChartView(graphData: chartData)
            } else {
                cell.setupLineChartView(graphDataValues: chartData)
            }
            return cell
        case .WeeklySummaryBarChartViewCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewTableCell", for: indexPath) as? ChartViewTableCell else {
                return UITableViewCell()
            }
            cell.chartViewTitleLabel.text = "Days at each mood".localized
            cell.setupbarChartView(data: self.prepareBarChartData(data: chartData))
            return cell
        case .WeeklySummarySleepAverageViewCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SleepSummaryTableViewCell", for: indexPath) as? SleepSummaryTableViewCell else {
                return UITableViewCell()
            }
            if !chartData.isEmpty {
                let list = chartData.sorted { $0.yValue > $1.yValue }
                let nonZeroSortedList = chartData.filter { $0.yValue > 0 }.sorted { $0.yValue < $1.yValue }
                let sleepHrs = chartData.map { $0.yValue }
                var totalSleepHrs: Float = 0
                for hour in sleepHrs {
                    totalSleepHrs += Float(hour)
                }
                
                let filteredDataForAvg = chartData.filter { $0.yValue > 0 }
                
                if filteredDataForAvg.isEmpty {
                    // No positive values, so handle accordingly, maybe set avgSleepHrs to 0 or some default
                    avgSleepHrs = 0
                    print("No positive sleep hours found, average sleep hours is set to 0")
                } else {
                    avgSleepHrs = totalSleepHrs / Float(filteredDataForAvg.count)
                    print("The total sleep hours is \(totalSleepHrs), filtered count is \(filteredDataForAvg.count), so average sleep hours is \(avgSleepHrs)")
                }
                
                if let least = nonZeroSortedList.first {
                    cell.leastHrsSleptLbl.text = "\(least.yValue) hrs"
                } else {
                    cell.leastHrsSleptLbl.text = "0 hrs"
                }
                
                if let first = list.first { // let last = list.last
                    cell.mostHrsSleptLbl.text = "\(first.yValue) hrs"
//                    cell.leastHrsSleptLbl.text = "\(last.yValue) hrs"
                    cell.avgHrsSleptLbl.text = String(format: "%.2f", avgSleepHrs) + " hrs"
                    let attrText = NSMutableAttributedString(string: "\(String(format: "%.2f", avgSleepHrs)) / ", attributes: [.font : UIFont(name: Fonts().lexendMedium, size: 14) ?? "", .foregroundColor : UIColor(hex: "#9B9B9B")])
                    attrText.append(NSMutableAttributedString(string: "12", attributes: [.font : UIFont(name: Fonts().lexendMedium, size: 14) ?? "",.foregroundColor: UIColor(hex: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ?  "#FFFFFF" : "#000000")]))
                    cell.noOfHrsSlept.attributedText = attrText
                    cell.configureCell(with: avgSleepHrs)

                }
            }
            return cell
        }
//        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if summaryType.getTableCellList()[indexPath.row] == .WeeklySummarySleepAverageViewCell {
//            return UITableView.automaticDimension
//        } else {
            return summaryType.getTableCellList()[indexPath.row].getCellHeight()
//        }
    }
    
}
