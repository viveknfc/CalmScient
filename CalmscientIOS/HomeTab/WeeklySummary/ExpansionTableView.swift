//
//  ExpansionTableView.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

public class ExpansionTableData {
    let title:String
    let leftSubTitle:String
    let rightSubTitle:String
    var exapansionState:Bool = false
    
    func updateExpansionState(isExpanded:Bool) {
        self.exapansionState = isExpanded
    }
    
    init(title: String, leftSubTitle: String, rightSubTitle: String) {
        self.title = title
        self.leftSubTitle = leftSubTitle
        self.rightSubTitle = rightSubTitle
    }
}

class ExpansionTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
        var tableData:[ExpansionTableData] = [] {
            didSet {
                reloadData()
            }
        }
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "ExpansionTableViewCell", bundle: nil)
        // Register custom cell class
        register(nib, forCellReuseIdentifier: "ExpansionTableViewCell")
        let nib2 = UINib(nibName: "CollapsedTableViewCell", bundle: nil)
        // Register custom cell class
        register(nib2, forCellReuseIdentifier: "CollapsedTableViewCell")
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

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let dataItem = tableData[indexPath.row]
            if dataItem.exapansionState == false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedTableViewCell", for: indexPath) as? CollapsedTableViewCell else {
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpansionTableViewCell", for: indexPath) as? ExpansionTableViewCell else {
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
