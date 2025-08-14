//
//  CustomCalender.swift
//  CalenderComponent
//
//  Created by KA on 20/03/24.
//

import Foundation
import UIKit
import FSCalendar

public protocol CalendarToViewDelegate : AnyObject {
    func calendardidChangeBounds(newBounds:CGRect)
    func userSelectedNewDate(selectedDate:Date)
}


class CustomCalender : UIView {
    
    @IBOutlet weak var customCalender: FSCalendar!
    
    public weak var calendarToViewDelegate:CalendarToViewDelegate?

    var eventIcons: [Date: UIImage] = [:]
    var eventIconColors: [Date: UIColor] = [:]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "CustomCalender")
        setupCalenderView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "CustomCalender")
        setupCalenderView()
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func setupCalenderView() {
        customCalender.allowsMultipleSelection = false
        customCalender.scope = .week
        customCalender.delegate = self
        customCalender.dataSource = self
        customCalender.today = nil
        customCalender.select(Date())
        customCalender.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        customCalender.backgroundColor = UIColor(named: "VCalenderBg")//UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1.0)

    }
    
    deinit {
        print("CustomCalender Deinit called")
    }
    
    func addEvent(forDate date: Date, icon: UIImage? = UIImage(systemName: "circle.fill"), iconColor: UIColor? = nil) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)

        // Store the icon and color if provided
        if let icon = icon {
            eventIcons[normalizedDate] = icon
        }
        
        // Store the icon color if provided (you can use a dictionary for storing color for each date)
        if let color = iconColor {
            eventIconColors[normalizedDate] = color
        }
        
        customCalender.reloadData()  // Reload calendar to reflect changes
    }


    
}

extension CustomCalender : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func createRoundedIcon(with systemImageName: String, diameter: CGFloat, color: UIColor) -> UIImage? {
        // Create a square UIGraphics context
        let size = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Create a path for the circle
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        path.addClip()
        
        if let iconImage = UIImage(systemName: systemImageName) {
                // Draw the icon inside the circle, scaled to fit
                iconImage.withTintColor(color).draw(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            }
        
        // Capture the image
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }

    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
           let calendar = Calendar.current
           let normalizedDate = calendar.startOfDay(for: date)
        
        if let _ = eventIcons[normalizedDate] {
                  // Return a rounded heart icon for the date
                let iconColor = eventIconColors[normalizedDate] ?? .red
                  return createRoundedIcon(with: "circle.fill", diameter: 13, color: iconColor)  // Adjust diameter as needed
              }
           
           // Return the custom icon if it exists for the date
           return eventIcons[normalizedDate]
       }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, imageOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 3)
    }

    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.customCalender.frame.size.height = bounds.height
        calendarToViewDelegate?.calendardidChangeBounds(newBounds: bounds)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("User selected date is \(convertToLocalTimeZone(date: date))")
        calendarToViewDelegate?.userSelectedNewDate(selectedDate: convertToLocalTimeZone(date: date))
    }
    
    func convertToLocalTimeZone(date: Date) -> Date {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let localDate = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(for: date), to: date)!
        return localDate
    }

}
