//
//  AddAppoinementsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 11/04/24.
//

import UIKit

class AddAppoinementsViewController: ViewController, CalendarToViewDelegate {

    @IBOutlet weak var calenderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calenderView: CustomCalender!
    @IBOutlet weak var addAppointmentsTableView: UITableView!
    
    @IBOutlet weak var cancelButton: BorderShadowButton!
    @IBOutlet weak var saveButton: LinearGradientButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addAppointmentsTableView.separatorStyle = .none
        calenderView.calendarToViewDelegate = self
        addAppointmentsTableView.register(UINib(nibName: "AddAppointmentsTableCell", bundle: nil), forCellReuseIdentifier: "AddAppointmentsTableCell")
        addAppointmentsTableView.dataSource = self
        addAppointmentsTableView.delegate = self
        self.title = "Add Appointment"
        saveButton.setAttributedTitleWithGradientDefaults(title: "Save")
        cancelButton.setAttributedTitleWithGradientDefaults(title: "Cancel")
        // Do any additional setup after loading the view.
    }
    
    func userSelectedNewDate(selectedDate: Date) {
    }
    
    func calendardidChangeBounds(newBounds: CGRect) {
        calenderHeightConstraint.constant = newBounds.height
    }
        

}

extension AddAppoinementsViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAppointmentsTableCell", for: indexPath) as! AddAppointmentsTableCell
        cell.appointmentsCellCollectionView.reloadData()
        switch indexPath.row {
        case 0: cell.titleLabel.text = "Morning"
        case 1: cell.titleLabel.text = "Afternoon"
        case 2: cell.titleLabel.text = "Evening"
        default:
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
}
