//
//  ProgressOnWorkDetailViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class ProgressOnWorkDetailViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var needToTalkSomeOneButton: LinearGradientButton!
    private lazy var summaryResultsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ProgressCollapsableTableCell", bundle: nil), forCellReuseIdentifier: "ProgressCollapsableTableCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SubsectionCell")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 0.0
        return tableView
    }()
    
    var tableData: [ProgressOfWorkCellData] = []
    var progressDetailData: [[String: Any]] = []
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Progress on course work"
        tableData = prepareData()
        print(tableData)
        
        self.view.addSubview(summaryResultsTableView)
        NSLayoutConstraint.activate([
            summaryResultsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            summaryResultsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            summaryResultsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            summaryResultsTableView.bottomAnchor.constraint(equalTo: needToTalkSomeOneButton.topAnchor, constant: -20),
        ])
        self.view.bringSubviewToFront(needToTalkSomeOneButton)
        summaryResultsTableView.allowsSelection = true
        summaryResultsTableView.isScrollEnabled = false
        summaryResultsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needToTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
    }
    
    @IBAction func needToTalkButtonAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func prepareData() -> [ProgressOfWorkCellData] {
        guard let index = index, index < progressDetailData.count,
              let courseData = progressDetailData[index] as? [String: Any],
              let sectionsList = courseData["sectionsList"] as? [[String: Any]] else {
            return []
        }
        
        return sectionsList.map { section in
            let title = section["sectionName"] as? String ?? ""
            let subtitles = (section["subSectionList"] as? [[String: Any]])?.compactMap { $0["subSectionName"] as? String } ?? []
            let percentages = (section["subSectionList"] as? [[String: Any]])?.compactMap { $0["completion"] as? String } ?? []
            let titlePer = section["completions"] as? String ?? "0%"
            return ProgressOfWorkCellData(title: title, subtitle: subtitles, percentage: percentages, titlePer: titlePer)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataItem = tableData[section]
        return dataItem.exapansionState ? dataItem.subtitle.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 150 : 0
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: UIView? = nil
        if section == 0 {
            let view = ProgressOnCourseWorkHeaderView()
            if let ind = index, ind < progressDetailData.count, let name = progressDetailData[ind]["courseName"] as? String, let perc = progressDetailData[ind]["completedPer"] as? Float {
                view.cellTitleLabel.text = name
                view.percentageLabel.text = "\(perc)%"
                view.progressView.progress = perc / 100.0
                view.courseLabel.text = "Sections"
            }
            header = view
        }
        return header
    }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let dataItem = tableData[indexPath.section]
                    if indexPath.row == 0 {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCollapsableTableCell", for: indexPath) as? ProgressCollapsableTableCell else {
                            return UITableViewCell()
                        }
                        cell.dataItem = dataItem
                        cell.cellExpansionClosure = { isExpanded in
                            dataItem.updateExpansionState(isExpanded: isExpanded)
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                        }
                        return cell
                    } else {
                        return UITableViewCell()
                    }
        }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        else{
            return 0
        }
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection if needed
        print("cell expansion row clicked")
        if indexPath.row == 0 {
            let dataItem = tableData[indexPath.section]
            
            // Toggle the expansion state
            dataItem.updateExpansionState(isExpanded: !dataItem.exapansionState)
            
            // Reload the section to reflect changes
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }

    
    }
    
}
