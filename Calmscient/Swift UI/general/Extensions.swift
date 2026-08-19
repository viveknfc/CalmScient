//
//  Extensions.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit
import AVFoundation

//MARK: - Extension : Color

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Shared back control for nav bars and SwiftUI headers (`NavigationBack` asset, 32×32).
struct MedicationNavigationBackButton: View {
    let onBack: () -> Void

    var body: some View {
        Button(action: onBack) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .frame(width: 32, height: 32)
        .fixedSize()
    }
}

@MainActor
enum MedicationFlowNavigationBarBackItem {
    private static let iconSide: CGFloat = 32

    /// Leading bar button using `MedicationNavigationBackButton`; retain the returned hosting controller for the lifetime of the owning view controller.
    static func leadingBarButton(onBack: @escaping () -> Void) -> (UIBarButtonItem, UIHostingController<MedicationNavigationBackButton>) {
        let host = UIHostingController(rootView: MedicationNavigationBackButton(onBack: onBack))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.sizingOptions = [.intrinsicContentSize]

        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(host.view)
        NSLayoutConstraint.activate([
            wrap.widthAnchor.constraint(equalToConstant: iconSide),
            wrap.heightAnchor.constraint(equalToConstant: iconSide),
            host.view.topAnchor.constraint(equalTo: wrap.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
        ])
        return (UIBarButtonItem(customView: wrap), host)
    }
}

// MARK: - Navigation bar chrome
//
// Every retired hosting controller ran this from `viewWillAppear`: an opaque background,
// no shadow, and a Lexend Medium **18** title. A SwiftUI screen has no such controller,
// so without it the bar falls back to the app-wide default `AppDelegate` installs
// (Lexend Medium 20) and stays translucent — every converted title renders a size larger,
// and content scrolling underneath (the medications calendar) shows through behind it.

@MainActor
enum AppNavigationBarChrome {

    static func makeAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.black,
            ]
        }
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        return appearance
    }

    /// Mirrors the legacy `applyNavigationChrome()` for a controller in the stack.
    static func apply(to controller: UIViewController) {
        let appearance = makeAppearance()
        let item = controller.navigationItem
        item.largeTitleDisplayMode = .never
        item.standardAppearance = appearance
        item.scrollEdgeAppearance = appearance
        item.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            item.compactScrollEdgeAppearance = appearance
        }

        guard let navBar = controller.navigationController?.navigationBar else { return }
        navBar.isTranslucent = false
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            navBar.compactScrollEdgeAppearance = appearance
        }
        navBar.shadowImage = UIImage()
    }
}

/// Applies `AppNavigationBarChrome` to whichever controller owns this SwiftUI screen,
/// at the same point in the lifecycle the hosting controller used to.
@available(iOS 16.0, *)
struct AppNavigationBarChromeApplier: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> Applier { Applier() }
    func updateUIViewController(_ uiViewController: Applier, context: Context) {}

    final class Applier: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            var candidate = parent
            while let current = candidate {
                if current.navigationController != nil {
                    AppNavigationBarChrome.apply(to: current)
                    return
                }
                candidate = current.parent
            }
        }
    }
}

@available(iOS 16.0, *)
extension View {
    /// Restores the opaque bar + Lexend Medium 18 title the hosting controllers applied.
    func appNavigationBarChrome() -> some View {
        background(
            AppNavigationBarChromeApplier()
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        )
    }
}

// MARK: - Shared UIView / UIColor helpers
// Relocated from Excercises/BreathingTechniqueType1.swift when the UIKit exercise
// screens were removed. Used app-wide (shadows, makeCircle, UIColor(hex:)).

extension UIView {
    
    func applyShadow(cornerRadius: CGFloat = 10.0, shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowRadius: CGFloat = 5.0) {
       // self.backgroundColor = .white
            self.layer.cornerRadius = cornerRadius
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            self.layer.masksToBounds = false
        }
    
    func makeCircle(with color: UIColor) {
          self.layer.cornerRadius = self.frame.size.width / 2
          self.backgroundColor = color
          self.layer.masksToBounds = true
      }
    
    func addShadowView() {
        //Remove previous shadow views
        superview?.viewWithTag(119900)?.removeFromSuperview()

        //Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false

        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true

        superview?.insertSubview(shadowView, belowSubview: self)
    }
    
    
    func applyShadowWithCornerRadius(cornerRadius: CGFloat,
                                         shadowColor: UIColor = .darkGray,
                                         shadowOffset: CGSize = .zero,
                                         shadowRadius: CGFloat = 20,
                                         shadowOpacity: Float = 1) {
            self.layer.cornerRadius = cornerRadius
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = shadowOpacity
            
            // Set shadow path for performance optimization
            let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
            self.layer.shadowPath = shadowPath.cgPath
        }
}

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
}

//MARK: - Extension Date & Calender

extension Date {
    
    func nextSevenDays() -> [Date] {
            let calendar = Calendar.current
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: self) }
        }
    
    func getTomorrowDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    func dateInMMDDYYYYFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier) //TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
    func dateToString(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier) //TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
        func getOlderDateWithDaysDifference(minusDays: Int) -> Date {
                return Calendar.current.date(byAdding: .day, value: minusDays, to: self) ?? self
            }

    func getFromDateAndToDate(minusDays:Int) -> (fromDate:String, toDate:String) {
        var fromDate:Date
        var toDate:Date
        
        if minusDays <= 0 {
            fromDate = getOlderDateWithDaysDifference(minusDays: minusDays)
            toDate = self
        } else {
            fromDate = self
            toDate = getOlderDateWithDaysDifference(minusDays: minusDays)
        }
        return (fromDate.dateToString(format: "MM/dd/yyyy"), toDate.dateToString(format: "MM/dd/yyyy"))
    }
    
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)
    }
}

//MARK: - Extension String

public enum DayTimeValue:String, Comparable, Equatable {
    public static func < (lhs: DayTimeValue, rhs: DayTimeValue) -> Bool {
        return lhs.getOrder() < rhs.getOrder()
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.getOrder() == rhs.getOrder()
    }

    case Morning = "Morning"
    case Afternoon = "Afternoon"
    case Evening = "Evening"
    
    func getIconImage() -> UIImage? {
        switch self {
        case .Morning: return UIImage(named: "Isolation_Mode")
        case .Afternoon:  return UIImage(named: "afternoonSun")
        case .Evening: return UIImage(named: "moon")
        }
    }
    
    private func getOrder() -> Int {
        switch self {
        case .Morning: return 1
        case .Afternoon:  return 2
        case .Evening: return 3
        }
    }
}

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Resolves an *asset-catalogue name* that is localised through `Localizable.strings`
    /// (e.g. `"ToggleSwitch_Yes"` → `"ToggleSwitch_Si"` in Spanish).
    ///
    /// Some languages translate the key into real words — Japanese maps it to `"はい"` —
    /// and no imageset exists under that name, so `Image(_:)` renders nothing and the
    /// control visually disappears. Falling back to the untranslated key keeps the
    /// artwork on screen, while still preferring a localised imageset when one is
    /// actually bundled.
    var localizedImageName: String {
        let name = self.localized
        return UIImage(named: name) != nil ? name : self
    }

    func toFormattedDateString(inputFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String = "MM/dd/yyyy") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = outputFormat
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    //Format "YYYY-MM-DD"
    
    func createDateFromTimeString(with formatter: String = "HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = Calendar.current.timeZone
        guard let timeDate = dateFormatter.date(from: self) else {
            return Date()
        }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second, .timeZone], from: timeDate)
        
        let today = Date()
        var todayComponents = calendar.dateComponents([.year, .month, .day, .timeZone], from: today)
        
        todayComponents.hour = timeComponents.hour
        todayComponents.minute = timeComponents.minute
        todayComponents.second = timeComponents.second
        
        return calendar.date(from: todayComponents) ?? Date()
    }

    func getDate(formatString:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func isDayTimeAM(formatter:String = "HH:mm:ss") -> Bool { //yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 0..<12:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    func isDayTimePM(formatter:String = "HH:mm:ss") -> Bool { //yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 12..<18:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    func isDayTimeEvening(formatter: String = "HH:mm:ss") -> Bool { //yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 18..<24:
                return true
            default:
                return false
            }
        }
        return false
    }

    func getDayTimeFromDate(formatter: String = "yyyy-MM-dd HH:mm:ss", includeTimeZone: Bool = false) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
//        dateFormatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)

            switch hour {
            case 0..<12:
                if includeTimeZone {
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = "AM".localized //a. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Morning.rawValue
                }
            case 12..<18:
                if includeTimeZone {
                    if hour > 12 {
                        hour = hour % 12
                    }
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = "PM".localized //p. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Afternoon.rawValue
                }
            default:
                if includeTimeZone {
                    if hour > 12 {
                        hour = hour % 12
                    }
                    let formattedHour = String(format: "%02d", hour)
                    let formattedMinute = String(format: "%02d", minute)
                    let ampm = "PM".localized //p. m.
                    return "\(formattedHour):\(formattedMinute) \(ampm)"
                } else {
                    return DayTimeValue.Evening.rawValue
                }
            }
        } else {
            return nil
        }
    }

    func toDate(format: String, timeZone: TimeZone = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
    
}


// MARK: - AVPlayer remaining-time observer
// Relocated from the removed UIKit VideoController.swift; used by the SwiftUI
// breathing/video player view models (MindfulBreathing, Diaphragmatic, BreathingTechniqueType1,
// Progressive, MindfulWalking, BasicKnowledgeVideo).
extension AVPlayer {
    func observeRemainingTime(threshold: Double = 10,
                              queue: DispatchQueue = .main,
                              callback: @escaping (Bool) -> Void) -> Any? {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        return addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] currentTime in
            guard let self = self,
                  let duration = self.currentItem?.duration.seconds,
                  duration.isFinite else {
                return
            }

            let remaining = duration - currentTime.seconds
            callback(remaining <= threshold)
        }
    }
}
