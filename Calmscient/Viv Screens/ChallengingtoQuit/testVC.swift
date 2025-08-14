//
//  testVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class testVC: ViewController, NCalendarToViewDelegate {
    
    @IBOutlet weak var newCalenderView: NewCalender!
    @IBOutlet weak var calenderHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newCalenderView.calendarToViewDelegate = self
        // Do any additional setup after loading the view.
    }
    
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calenderHeight.constant = newBounds.height
    }
    
    func NuserSelectedNewDate(selectedDate: Date) {
        print("viv the selected date is", selectedDate)
    }
    

}
