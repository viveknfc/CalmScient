//
//  WeeklySummaryResultsViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

class WeeklySummaryResultsViewController: ViewController, CalendarToViewDelegate {
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calender: CustomCalender!
    
    
    private lazy var summaryResultsTableView:ExpansionTableView = {
        return ExpansionTableView(frame: .zero)
    }()
    var tableData:[ExpansionTableData]!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableData = prepareData()
        self.calender.calendarToViewDelegate = self
        self.view.addSubview(summaryResultsTableView)
        summaryResultsTableView.tableData = self.tableData
        summaryResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryResultsTableView.topAnchor.constraint(equalTo: calender.bottomAnchor, constant: 8),
            summaryResultsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            summaryResultsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            summaryResultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        summaryResultsTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    func calendardidChangeBounds(newBounds: CGRect) {
        calendarHeightConstraint.constant = newBounds.height
    }
    
    func userSelectedNewDate(selectedDate: Date) {
    }
    
    
    private func prepareData() -> [ExpansionTableData] {
        let d1 = ExpansionTableData(title: "08/14/2023", leftSubTitle: "8 Hours", rightSubTitle: "+1 Hours sleep needed")
        let d2 = ExpansionTableData(title: "08/15/2023", leftSubTitle: "n Hours", rightSubTitle: "+n Hours sleep needed")
        let d3 = ExpansionTableData(title: "08/16/2023", leftSubTitle: "Had a lot of stress at work today. Didn’t really sleep that well.", rightSubTitle: "")
        let d4 = ExpansionTableData(title: "08/17/2023", leftSubTitle: "n-z+1 Hours", rightSubTitle: "n-z Hours sleep needed")
        return [d1,d2,d3,d4]
    }
    
}
