//
//  GlossyController.swift
//  CalmscientIOS
//
//  Created by BVK on 30/09/24.
//

import UIKit

class GlossyController: ViewController,  UITableViewDataSource, UITableViewDelegate {
    var selectedIndexPath: IndexPath?
    private let glossaryItemsCount = 21
    
    @IBOutlet weak var glossyTableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        glossyTableview.dataSource = self
        glossyTableview.delegate = self
        glossyTableview.translatesAutoresizingMaskIntoConstraints = false
        glossyTableview.register(UINib(nibName: "glossyTableCellTableViewCell", bundle: nil), forCellReuseIdentifier: "glossyTableCellTableViewCell")
        
        glossyTableview.rowHeight = UITableView.automaticDimension
        glossyTableview.estimatedRowHeight = 100
 
    }

    override func viewWillAppear(_ animated: Bool) {//kiran diagnostics
        super.viewWillAppear(animated)
    
        self.title = AppHelper.getLocalizeString(str:"Glossary") // Please check the localisation for Glossy we replaced with Glossary
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return glossaryItemsCount
        }
        
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "glossyTableCellTableViewCell", for: indexPath) as! glossyTableCellTableViewCell
 
        let title = "gls_term_\(indexPath.section + 1)".localized
        let summary = "gls_sum_\(indexPath.section + 1)".localized
        cell.titleLabel?.text = title
        cell.summaryLabel.text = summary
        cell.roundLabel.text = String(title.prefix(1)).uppercased()
 
//        cell.contentView.applyShadow()
        
        let isExpanded = (selectedIndexPath == indexPath)
        cell.isExpanded = isExpanded
        
        cell.plusButtonAction = { [weak self, weak tableView] in
            guard let self = self, let tableView = tableView else { return }
            self.toggleExpansion(at: indexPath, in: tableView)
        }

        cell.selectionStyle = .none
        return cell
    }


        // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        toggleExpansion(at: indexPath, in: tableView)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if selectedIndexPath == indexPath {
            return UITableView.automaticDimension // Expand to fit the summary text
        } else {
            return 75 // Default collapsed height
        }
    }
    
    private func toggleExpansion(at indexPath: IndexPath, in tableView: UITableView) {
        var indexPathsToReload: [IndexPath] = []

        if let previousIndexPath = selectedIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }

        if selectedIndexPath == indexPath {
            // Collapse if same cell tapped again
            selectedIndexPath = nil
        } else {
            // Expand new cell
            selectedIndexPath = indexPath
            indexPathsToReload.append(indexPath)
        }

        tableView.reloadRows(at: indexPathsToReload, with: UITableView.RowAnimation.automatic)

    }

    }






