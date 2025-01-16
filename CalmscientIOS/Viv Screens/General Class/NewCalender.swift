//
//  NewCalender.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import Foundation
import UIKit
import FSCalendar

public protocol NCalendarToViewDelegate : AnyObject {
    func NcalendardidChangeBounds(newBounds:CGRect)
    func NuserSelectedNewDate(selectedDate:Date)
}


class NewCalender : UIView, UISheetPresentationControllerDelegate, NewPickerViewDelegate {
    
    @IBOutlet weak var one: UIButton!
    
    @IBOutlet weak var customCalender: FSCalendar!
    
    @IBOutlet weak var monthandYearButton: UIButton!
    
    var datePicker: UIDatePicker?
    var containerView = UIView()
    var dimmingView: UIView?
    
    public weak var calendarToViewDelegate:NCalendarToViewDelegate?

    var eventIcons: [Date: UIImage] = [:]
    var eventIconColors: [Date: UIColor] = [:]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "NewCalender")
        setupCalenderView()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "NewCalender")
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
        
        updateMonthAndYearButtonTitle(for: customCalender.currentPage)
    }
    
    private func updateMonthAndYearButtonTitle(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let title = dateFormatter.string(from: date)
        
        let downArrow = NSAttributedString(string: " \u{25BC}", attributes: [
             .font: UIFont(name: Fonts().lexendRegular, size: 14)!, // Adjust size as needed
             .foregroundColor: UIColor(named: "GradientButtonColor1")! // Adjust arrow color if needed
         ])
         
         let attributedTitle = NSMutableAttributedString(string: title)
         attributedTitle.append(downArrow)
         
         // Set the attributed title to the button
         monthandYearButton.setAttributedTitle(attributedTitle, for: .normal)
         
         // Set the text color for the button (for the month and year)
        monthandYearButton.setTitleColor(UIColor(named: "GradientButtonColor1"), for: .normal)

    }
    
    
    @IBAction func monthandYearButtonSelected(_ sender: Any) {
        guard let parentViewController = self.findViewController() else {
            print("No parent view controller found")
            return
        }
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let vc = next.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
            fatalError("Could not instantiate view controller with identifier 'BottomSheetTimeAndAlarmVC'")
        }
        
        vc.delegate = self
        
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            let dimmingView = UIView(frame: window.bounds)
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dimmingView)
            self.dimmingView = dimmingView // Store the reference
        }
        
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return 270 // Replace with desired height
                    }
                    sheet.detents = [customDetent]
                } else {
                    sheet.detents = [.medium()]
                    // Fallback on earlier versions
                }
                
                
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

                sheet.delegate = self // To handle delegate methods and adjust dimming view

            }
        } else {
            // Fallback on earlier versions
        }

        vc.isModalInPresentation = true
        parentViewController.present(vc, animated: true, completion: nil)

    }
    
    func didSelectDate(_ date: Date, indexPath: IndexPath?) {
        self.customCalender.setCurrentPage(date, animated: true) // Update the calendar
        self.customCalender.select(date, scrollToDate: true)
        self.calendarToViewDelegate?.NuserSelectedNewDate(selectedDate: convertToLocalTimeZone(date: date))
        
        removeDimmingView()
    }

    
    func didDismissPicker() {
           // Remove the dimming view when picker is dismissed
           removeDimmingView()
       }
    
    private func removeDimmingView() {
           dimmingView?.removeFromSuperview()
           dimmingView = nil
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

extension NewCalender : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
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
        // Update the height by adding 50 to the current height of the bounds
        self.customCalender.frame.size.height = bounds.height + 50
        
        // Create a new CGRect with the updated height
        let newHeight = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height + 50)
        
        // Pass the updated CGRect to the delegate
        calendarToViewDelegate?.NcalendardidChangeBounds(newBounds: newHeight)
    }

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("User selected date is \(convertToLocalTimeZone(date: date))")
        calendarToViewDelegate?.NuserSelectedNewDate(selectedDate: convertToLocalTimeZone(date: date))
    }
    
    func convertToLocalTimeZone(date: Date) -> Date {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let localDate = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(for: date), to: date)!
        return localDate
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthAndYearButtonTitle(for: calendar.currentPage)
    }

}

extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}



class PickerViewController: UIViewController {
    var datePicker: UIDatePicker!
    var onDateSelected: ((Date) -> Void)? // Explicit type
    var onCancel: (() -> Void)?          // Explicit type
    private var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Create a container view
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Create a date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.setValue(UIColor(named: "GradientButtonColor1"), forKey: "textColor") // Set text color

            // Set font for the date picker labels
                    for subview in datePicker.subviews {
                        if let label = subview as? UILabel {
                            label.font = UIFont(name: Fonts().lexendRegular, size: 12)! // Set your desired font and size
                        }
                    }
        }
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.locale = Locale(identifier: "en_US")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(datePicker)
        
        // Create a custom background for the toolbar to have rounded corners
        let toolbarBackgroundView = UIView()
        toolbarBackgroundView.backgroundColor = .white
        toolbarBackgroundView.layer.cornerRadius = 12
        toolbarBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        toolbarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toolbarBackgroundView)

        // Create a toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarBackgroundView.addSubview(toolbar)

        // Add Cancel and OK buttons
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(okButtonTapped))
        okButton.tintColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
        toolbar.setItems([cancelButton, spacer, okButton], animated: false)
        
        // Set constraints for the container view
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: 300),
                containerView.heightAnchor.constraint(equalToConstant: 300),

                toolbarBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
                toolbarBackgroundView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                toolbarBackgroundView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                toolbarBackgroundView.heightAnchor.constraint(equalToConstant: 44),

                toolbar.topAnchor.constraint(equalTo: toolbarBackgroundView.topAnchor),
                toolbar.leftAnchor.constraint(equalTo: toolbarBackgroundView.leftAnchor),
                toolbar.rightAnchor.constraint(equalTo: toolbarBackgroundView.rightAnchor),
                toolbar.bottomAnchor.constraint(equalTo: toolbarBackgroundView.bottomAnchor),

                datePicker.topAnchor.constraint(equalTo: toolbarBackgroundView.bottomAnchor),
                datePicker.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                datePicker.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
    }

    @objc func cancelButtonTapped() {
        onCancel?() // Call the cancel closure if set
        dismiss(animated: true, completion: nil)
    }

    @objc func okButtonTapped() {
        onDateSelected?(datePicker.date) // Call the date selection closure if set
        dismiss(animated: true, completion: nil)
    }

}






