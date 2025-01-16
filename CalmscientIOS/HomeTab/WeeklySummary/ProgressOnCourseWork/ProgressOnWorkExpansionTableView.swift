//
//  ProgressOnWorkExpansionTableView.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class ProgressOnWorkExpansionTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var tableData:[ProgressOfWorkCellData] = [] {
        didSet {
            reloadData()
        }
    }
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "ProgressCollapsableTableCell", bundle: nil)
        // Register custom cell class
        register(nib, forCellReuseIdentifier: "ProgressCollapsableTableCell")
        let nib2 = UINib(nibName: "ProgressExpandableTableCell", bundle: nil)
        // Register custom cell class
        register(nib2, forCellReuseIdentifier: "ProgressExpandableTableCell")
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 30
        // Set data source and delegate
        dataSource = self
        delegate = self
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ProgressOnCourseWorkHeaderView()
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = tableData[indexPath.row]
        if dataItem.exapansionState == false {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressExpandableTableCell", for: indexPath) as? ProgressExpandableTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.dataItem = tableData[indexPath.row]
            cell.cellExpansionClosure = {
                [weak self] _ in
                guard let self = self else {
                    return
                }
                self.tableData[indexPath.row].updateExpansionState(isExpanded: true)
                self.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCollapsableTableCell", for: indexPath) as? ProgressCollapsableTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.dataItem = tableData[indexPath.row]
            cell.cellExpansionClosure = {
                [weak self] _ in
                guard let self = self else {
                    return
                }
                self.tableData[indexPath.row].updateExpansionState(isExpanded: false)
                self.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
        
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection
        print("Selected item: \(tableData[indexPath.row])")
    }
    
}
