//
//  SummaryOfMoodViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 01/05/24.
//

import UIKit



class WeeklySummaryGraphViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var needToTalkSomeOneButton: LinearGradientButton!
    
    private let hardCodedStartDate:String = "05/12/2024"
    private let hardCodedEndDate:String = "05/27/2024"
    
    
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
        let needToTalk = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Need to talk with someone?" : "¿Necesitas hablar con alguien?"
        needToTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: needToTalk)
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
    func setupLanguage() {
        
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
        }
    }
    @IBAction func needToTalkButtonAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
               let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
               vc?.title = "Emergency resource"
               self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func getDataFromAPI() {
        self.view.showToastActivity()
        tableDataList = summaryType.getTableCellList()
        summaryType.getServerResponsefrom(startDate: dateRange.fromDate.dateToString(format: "MM/dd/yyyy"), and: dateRange.toDate.dateToString(format: "MM/dd/yyyy")) { [weak self] graphData, serverResponse, error in
            self?.view.hideToastActivity()
            guard let responseData = graphData else {
                return
            }
            self?.chartData = responseData
            print("the chart data is", self?.chartData ?? "")
            self?.tableView.reloadData()
        }
    }

    private func prepareBarChartData(data:[GraphData]) -> [GraphData] {
        
        let badData:[GraphData] = data.filter { obj in
            return obj.additionalInfo?.lowercased().trimmingCharacters(in: .whitespaces) == "BAD".lowercased()
        }
        let couldbeBetterData:[GraphData] = data.filter { obj in
            return obj.additionalInfo?.lowercased().trimmingCharacters(in: .whitespaces) == "COULD BE BETTER".lowercased()
        }
        let fairData = data.filter { obj in
            return obj.additionalInfo?.lowercased().trimmingCharacters(in: .whitespaces) == "FAIR".lowercased()
        }
        let goodData = data.filter { obj in
            return obj.additionalInfo?.lowercased().trimmingCharacters(in: .whitespaces) == "GOOD".lowercased()
        }
        let excellentData = data.filter { obj in
            return obj.additionalInfo?.lowercased().trimmingCharacters(in: .whitespaces) == "EXCELLENT".lowercased()
        }
        var preparedData:[GraphData] = []

        preparedData.append(GraphData(yAxisValue: badData.count, xAxisValue: "VBAD", additionalInfo: "BAD", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: couldbeBetterData.count , xAxisValue: "COULD BE BETTER", additionalInfo: "COULD BE BETTER", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: fairData.count, xAxisValue: "FAIR", additionalInfo: "FAIR", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: goodData.count, xAxisValue: "GOOD", additionalInfo: "GOOD", graphType: .WeeklySummarySummaryOfMood))
        preparedData.append(GraphData(yAxisValue: excellentData.count, xAxisValue: "EXCELLENT", additionalInfo: "EXCELLENT", graphType: .WeeklySummarySummaryOfMood))
        
        return preparedData
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
            cell.chartViewTitleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Days at each mood" : "Días en cada estado de ánimo"
            cell.setupbarChartView(data: self.prepareBarChartData(data: chartData))
            return cell
        case .WeeklySummarySleepAverageViewCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SleepSummaryTableViewCell", for: indexPath) as? SleepSummaryTableViewCell else {
                return UITableViewCell()
            }
            if !chartData.isEmpty {
                let list = chartData.sorted { $0.yValue > $1.yValue }
                let sleepHrs = chartData.map { $0.yValue }
                var totalSleepHrs: Float = 0
                for hour in sleepHrs {
                    totalSleepHrs += Float(hour)
                }
                
                let filteredDataForAvg = chartData.filter { $0.yValue > 0 }
                
                let avgSleepHrs = totalSleepHrs/Float(filteredDataForAvg.count)
                print("the total sleep hours is ",totalSleepHrs, " and the list count is ",list.count, " filtered data for avg count is ",filteredDataForAvg, "so avg sleep hours is ", avgSleepHrs)
                
                if let first = list.first, let last = list.last {
                    cell.mostHrsSleptLbl.text = "\(first.yValue) hrs"
                    cell.leastHrsSleptLbl.text = "\(last.yValue) hrs"
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
