//
//  JournalEntryMainViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class JournalEntryMainViewController: ViewController, PopOverActionDelegate, AlertViewActionProtocol, CalendarToViewDelegate { //JournalEntryEditViewActions
    
    fileprivate var deleteAlertBackGroundView:UIView?
    fileprivate var editJournalBackGroundView:UIView?
    fileprivate var successAlertBackGroundView:UIView?

    fileprivate lazy var tableMenuPopOver:TablePopOverViewController = {
        let next = UIStoryboard(name: "TablePopOver", bundle: nil)
        guard let popOverVC = next.instantiateViewController(withIdentifier: "TablePopOverViewController") as? TablePopOverViewController else {
            fatalError("TablePopOverViewController is Missing")
        }
        popOverVC.tablePopOverDelegate = self
        return popOverVC
    }()
    
//    fileprivate lazy var editJournalView:JournalEntryEditView = {
//        let journalEntryEditView = JournalEntryEditView(frame: .zero)
////        journalEntryEditView.journalEntryEditActionDelegate = self
//        return journalEntryEditView
//    }()
    
    fileprivate lazy var deleteAlertView:CustomImageAlertView = {
        let deleteAlertView = CustomImageAlertView(frame: .zero)
        deleteAlertView.contentLabel.text = "Are you sure you want to delete Journal entry data"
        deleteAlertView.titleLabel.text = "Delete"
        deleteAlertView.alertActionDelegate = self
        return deleteAlertView
    }()
    
    fileprivate lazy var successAlertView:CustomImageAlertView = {
        let successAlertView = CustomImageAlertView(frame: .zero)
        deleteAlertView.contentLabel.text = "Journal entry data is updated successfully."
        deleteAlertView.titleLabel.text = "Success"
        successAlertView.cancelButton.isHidden = true
        successAlertView.okButton.isHidden = true
        return successAlertView
    }()
    private let dataType:WeeklySummaryItems = .WeeklySummaryJournalEntry
    private var tableData:[JournalEntryDataItem] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var selectedDate:Date = Date()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var needToTalkSomeOneButton: LinearGradientButton!
    
    @IBOutlet weak var calenderHeight: NSLayoutConstraint!
    @IBOutlet weak var calendar: CustomCalender!
    private let dataDatesDifference = -15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.calendarToViewDelegate = self
        needToTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
        setUpTableView()
        getJournalData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        needToTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
    }
    
    private func getJournalData() {
        self.view.showToastActivity()
        let datesDiffer = selectedDate.getFromDateAndToDate(minusDays: dataDatesDifference)
        let requestForm = dataType.getAPIRequestForWeeklySummary(with: datesDiffer.fromDate, endDate: datesDiffer.toDate)
        guard let requestURL = requestForm.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: JournalResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                self?.view.hideToastActivity()
                guard let self = self else {
                    return
                }
                if let err = error {
                    self.view.showToast(message: err.localizedDescription)
                } else if let response = response {
     
                    if response.response.responseCode == 200 {
                        self.tableData = response.journalEntriesList.map({ obj in
                            return JournalEntryDataItem(entry: obj)
                        })
                    } else {
                        self.view.showToast(message: response.response.responseMessage)
                    }
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "JournalEntryExpandedTableCell", bundle: nil)
        // Register custom cell class
        tableView.register(nib, forCellReuseIdentifier: "JournalEntryExpandedTableCell")
        let nib2 = UINib(nibName: "JournalEntryCollapsedTableCell", bundle: nil)
        // Register custom cell class
        tableView.register(nib2, forCellReuseIdentifier: "JournalEntryCollapsedTableCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
        // Set data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func userSelectedPopOverRow(index: Int, title: String) {
        print("Selected Title \(title)")
        self.tableMenuPopOver.dismiss(animated: true)
        if index == 2 {
            showDeleteAlertMessageView()
        } else {
//            self.showEditJournalView()
        }
    }
    
    func calendardidChangeBounds(newBounds: CGRect) {
        calenderHeight.constant = newBounds.height
    }
    
    func userSelectedNewDate(selectedDate: Date) {
        self.selectedDate = selectedDate
        getJournalData()
    }
    
    
    //MARK: - ImageAlertViewActions
    func didClickOnYESButton() {
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.deleteAlertView.removeFromSuperview()
            self.deleteAlertBackGroundView?.removeFromSuperview()
            self.deleteAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
    }

    func didClickOnNOButton() {
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.deleteAlertView.removeFromSuperview()
            self.deleteAlertBackGroundView?.removeFromSuperview()
            self.deleteAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
    }
    
    //MARK: - JournalEntryEditViewActions
//    func closeAction() {
//       closeJournalView()
//    }
    
//    func saveAction(updatedText: String) {
//        print("save journal entru clicked from journal entry main vc")
//        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
//            self.editJournalView.removeFromSuperview()
//            self.editJournalBackGroundView?.removeFromSuperview()
//            self.editJournalBackGroundView = nil
//            self.navigationController?.navigationBar.layer.zPosition = 0
//            
//        }, completion: {_ in 
//            self.showSuccessMessageView()
//        })
//    }
//    
//    func closeJournalView() {
//        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
//            self.editJournalView.removeFromSuperview()
//            self.editJournalBackGroundView?.removeFromSuperview()
//            self.editJournalBackGroundView = nil
//            self.navigationController?.navigationBar.layer.zPosition = 0
//            
//        },completion: nil)
//    }
}

extension JournalEntryMainViewController : EditActionProtocol, UIPopoverPresentationControllerDelegate {
    func didClickOnEditAction(forCellIndex: IndexPath) {
        
        print("calling didClickOnEditAction")
        
        guard let cell = self.tableView.cellForRow(at: forCellIndex) as? JournalEntryExpandedTableCell else {
            return
        }
        let cellFrame = cell.frame
        let editButtonFrame = cell.editCellButton.frame
        let popOverRect = CGRect(x: editButtonFrame.minX + (editButtonFrame.width/2), y: cellFrame.minY + editButtonFrame.minY + (editButtonFrame.height / 2), width: editButtonFrame.width, height: editButtonFrame.height)

        let popOverVC = self.tableMenuPopOver
        popOverVC.modalPresentationStyle = .popover
        popOverVC.preferredContentSize = CGSize(width: 120, height: 45)
        
        let popoverPresentationController = popOverVC.popoverPresentationController
        popoverPresentationController?.delegate = self
        popoverPresentationController?.sourceView = self.tableView // Set the source view for positioning
        popoverPresentationController?.sourceRect = popOverRect
        popOverVC.popoverPresentationController?.permittedArrowDirections = .any
        // Present the popover
        present(popOverVC, animated: true, completion: nil)
    
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
//    fileprivate func showEditJournalView() {
//        editJournalBackGroundView = UIView(frame: .zero)
//        editJournalBackGroundView?.frame = self.view.frame
//        editJournalBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
//        editJournalBackGroundView?.addSubview(editJournalView)
//        editJournalView.translatesAutoresizingMaskIntoConstraints = false
//        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.navigationController?.navigationBar.layer.zPosition = -1
//            self.view.addSubview(self.editJournalBackGroundView!)
//            self.editJournalView.journalTextView.becomeFirstResponder()
//        }, completion: nil)
//        editJournalView.layer.cornerRadius = 5
//        editJournalView.layer.masksToBounds = true
//        editJournalView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        editJournalView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        editJournalView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
//        editJournalView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.5).isActive = true
//    }
    
    fileprivate func showSuccessMessageView() {
        successAlertBackGroundView = UIView(frame: .zero)
        successAlertBackGroundView?.frame = self.view.frame
        successAlertBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        successAlertBackGroundView?.addSubview(successAlertView)
        successAlertView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.successAlertBackGroundView!)
        }, completion:{_ in 
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.successAlertView.removeFromSuperview()
                    self.successAlertBackGroundView?.removeFromSuperview()
                    self.successAlertBackGroundView = nil
                    self.navigationController?.navigationBar.layer.zPosition = 0
                }, completion: nil)
            })
        } )
        successAlertView.layer.cornerRadius = 10
        successAlertView.layer.masksToBounds = true
        successAlertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        successAlertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        successAlertView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        successAlertView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.3).isActive = true
    }
    
    fileprivate func showDeleteAlertMessageView() {
        deleteAlertBackGroundView = UIView(frame: .zero)
        deleteAlertBackGroundView?.frame = self.view.frame
        deleteAlertBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        deleteAlertBackGroundView?.addSubview(deleteAlertView)
        deleteAlertView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.deleteAlertBackGroundView!)
        }, completion: nil)
        deleteAlertView.layer.cornerRadius = 10
        deleteAlertView.layer.masksToBounds = true
        deleteAlertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        deleteAlertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        deleteAlertView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        deleteAlertView.heightAnchor.constraint(equalToConstant: 333).isActive = true
    }
    
}

extension JournalEntryMainViewController : UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = tableData[indexPath.row]
        if dataItem.exapansionState == false {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCollapsedTableCell", for: indexPath) as? JournalEntryCollapsedTableCell else {
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
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryExpandedTableCell", for: indexPath) as? JournalEntryExpandedTableCell else {
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
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            cell.cellIndexPath = indexPath
            cell.editActionDelegate = self
            return cell
        }
        
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection
        print("Selected item: \(tableData[indexPath.row])")
    }
    
}
