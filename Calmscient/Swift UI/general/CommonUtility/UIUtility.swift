//
//  UIUtility.swift
//  MentalHealth
//
//  Created by KA on 16/02/24.
//

import Foundation
import ObjectiveC
import UIKit
import Toast_Swift

private var needToTalkButtonStoredHeightKey: UInt8 = 0

open class customUITextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.textColor = UIColor(named: "MainTextColor")
        self.font = UIFont(name: Fonts().lexendLight, size: 16.0)
    }

    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UIColor {
    public convenience init?(hex1: String) {
        let r, g, b, a: CGFloat

        if hex1.hasPrefix("#") {
            let start = hex1.index(hex1.startIndex, offsetBy: 1)
            let hexColor = String(hex1[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIView {

    func applyNeedToTalkButtonVisibility() {
        let shouldShow = PatientLanguagePreference.shouldShowNeedToTalkButton()
        isHidden = !shouldShow
        isUserInteractionEnabled = shouldShow

        guard let heightConstraint = constraints.first(where: {
            $0.firstAttribute == .height && ($0.firstItem as? UIView) === self
        }) else { return }

        if shouldShow {
            if let stored = objc_getAssociatedObject(self, &needToTalkButtonStoredHeightKey) as? CGFloat, stored > 0 {
                heightConstraint.constant = stored
            }
        } else {
            if objc_getAssociatedObject(self, &needToTalkButtonStoredHeightKey) == nil {
                objc_setAssociatedObject(
                    self,
                    &needToTalkButtonStoredHeightKey,
                    heightConstraint.constant,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
            heightConstraint.constant = 0
        }
    }

    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }


    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
//    shadowView.dropShadow(color: .red, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


extension UITextField {
  func addPaddingAndIcon(_ image: UIImage, padding: CGFloat,isLeftView: Bool) {
    let frame = CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height)
    
    let outerView = UIView(frame: frame)
    let iconView  = UIImageView(frame: frame)
    iconView.image = image
    iconView.contentMode = .center
    outerView.addSubview(iconView)
    
    if isLeftView {
      leftViewMode = .always
      leftView = outerView
    } else {
      rightViewMode = .always
      rightView = outerView
    }
    
  }
}



@IBDesignable
class CustomTextView: UITextView {

    // Border width
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    // Border color
    @IBInspectable var borderColor: UIColor = UIColor.gray {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    // Corner radius
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    // Padding for text
    @IBInspectable var textPadding: CGFloat = 10 {
        didSet {
            self.textContainerInset = UIEdgeInsets(top: textPadding, left: textPadding, bottom: textPadding, right: textPadding)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.textContainerInset = UIEdgeInsets(top: textPadding, left: textPadding, bottom: textPadding, right: textPadding)
        self.textContainer.lineFragmentPadding = 0  // Ensure padding consistency
    }
}



// MARK: - Toast presentation
//
// Moved verbatim from `Features/Login/LoginVC.swift` when the legacy UIKit login
// chain was retired. Used app-wide (60+ files), so it must live in a shared file.

extension UIView {
    public func updateToastStyleWithAppDefaults() {
        var toastStyle = ToastManager.shared.style
        toastStyle.backgroundColor = UIColor(named: "toastBackgroundColor")!
        toastStyle.titleColor = .white
        toastStyle.messageColor = .white
        toastStyle.messageAlignment = .center
        toastStyle.messageNumberOfLines = 0
        toastStyle.messageFont = UIFont(name: Fonts().lexendLight, size: 14) ?? .systemFont(ofSize: 14)
        toastStyle.titleFont = UIFont(name: Fonts().lexendLight, size: 16) ?? .systemFont(ofSize: 16)
        toastStyle.titleAlignment = .center
        toastStyle.activityBackgroundColor = UIColor(named: "toastBackgroundColor")!
        toastStyle.activityIndicatorColor = .white
        ToastManager.shared.style = toastStyle
    }

    /// Where a toast may actually be added.
    ///
    /// SwiftUI owns the subviews of a `UIHostingController`'s root view, so adding a
    /// UIKit toast there logs "Adding 'UIView' as a subview of UIHostingController.view
    /// is not supported and may result in a broken view hierarchy" — and the toast can be
    /// torn down by the next SwiftUI update. Since the Home tab became a native
    /// `NavigationStack`, `hostViewController` resolves to the hosting controller SwiftUI
    /// creates per destination, so every `hostViewController?.view.showToast…` call hit
    /// exactly that path.
    ///
    /// Falling back to the key window keeps the toast identical — same style, same place
    /// on screen, same `Toast` behaviour already used by SwiftUI screens with no host —
    /// while leaving SwiftUI's view tree untouched. Legacy UIKit views are not
    /// SwiftUI-managed, so they still anchor on themselves exactly as before.
    var toastAnchorView: UIView {
        guard isSwiftUIHostingControllerRootView else { return self }
        return Toast.anchor ?? self
    }

    /// True only when `self` *is* a hosting controller's root view — the one place UIKit
    /// refuses subviews. Views a representable owns further down the tree are untouched,
    /// so they keep anchoring on themselves exactly as before.
    private var isSwiftUIHostingControllerRootView: Bool {
        guard let owner = next as? UIViewController, owner.view === self else { return false }
        return UIView.isSwiftUIHostingControllerClass(type(of: owner))
    }

    /// `UIHostingController` is generic (and SwiftUI subclasses it privately for
    /// `NavigationStack`), so the class hierarchy is walked by name rather than compared
    /// against a concrete type.
    private static func isSwiftUIHostingControllerClass(_ type: AnyClass) -> Bool {
        var current: AnyClass? = type
        while let cls = current {
            if NSStringFromClass(cls).contains("UIHostingController") { return true }
            current = class_getSuperclass(cls)
        }
        return false
    }

    public func showToast(message: String, title: String? = nil, point: CGPoint? = nil) {
        DispatchQueue.main.async {
            let anchor = self.toastAnchorView
            anchor.hideAllToasts(includeActivity: true)
            anchor.updateToastStyleWithAppDefaults()

            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }

            let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
            let tabBarHeight = self.findViewController()?.tabBarController?.tabBar.frame.height ?? 49
            let bottomPadding: CGFloat = 16
            let adjustedY = anchor.frame.height - (tabBarHeight + safeAreaBottom + bottomPadding)
            let defaultPoint = CGPoint(x: anchor.frame.width / 2, y: adjustedY)
            // An explicit point is in the caller's coordinate space; keep it on screen
            // where the caller meant it even when the anchor changed.
            let resolvedPoint: CGPoint
            if let point {
                resolvedPoint = anchor === self ? point : self.convert(point, to: anchor)
            } else {
                resolvedPoint = defaultPoint
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                anchor.makeToast(message, duration: 2, point: resolvedPoint, title: title, image: nil) { _ in
                    anchor.hideToastActivity()
                }
            }
        }
    }

    /// Views that currently have an activity indicator on them.
    ///
    /// `showToastActivity()` and `hideToastActivity()` are routinely called on *different*
    /// views. View models anchor to `hostViewController?.view`, and that host is resolved
    /// asynchronously — it can be nil (falling back to the key window) when the request
    /// starts and resolved by the time the response lands, or point at a different
    /// controller after a `NavigationStack` push. Hiding then misses the view the spinner
    /// is actually on, so it turns forever and — because showing also sets
    /// `isUserInteractionEnabled = false` — leaves that view permanently untappable.
    ///
    /// Tracking the anchors makes the pair symmetric no matter which view each side is
    /// called on. Weak, so a torn-down screen drops out on its own.
    private static let toastActivityAnchors = NSHashTable<UIView>.weakObjects()

    public func showToastActivity() {
        let anchor = self.toastAnchorView
        anchor.isUserInteractionEnabled = false
        anchor.updateToastStyleWithAppDefaults()
        anchor.makeToastActivity(.center)
        UIView.toastActivityAnchors.add(anchor)
    }

    public func hideToastActivity() {
        DispatchQueue.main.async { [weak self] in
            var targets = UIView.toastActivityAnchors.allObjects
            UIView.toastActivityAnchors.removeAllObjects()
            if let self {
                let anchor = self.toastAnchorView
                if !targets.contains(where: { $0 === anchor }) {
                    targets.append(anchor)
                }
            }
            for view in targets {
                view.isUserInteractionEnabled = true
                view.hideAllToasts(includeActivity: true)
            }
        }
    }
}

// MARK: - Responder-chain lookup
//
// Moved verbatim from `Viv Screens/General Class/NewCalender.swift` when the
// legacy FSCalendar view was retired. `showToast(message:title:point:)` above
// depends on it, so it must live in a shared file.
// (Note: `ViewController.findViewController()` is a separate method on that
// class — this is the `UIView` one.)

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

// MARK: - Window-anchored toasts
//
// The toast API above is a `UIView` extension, so every caller needs a view —
// which is why view models hold a `hostViewController` just to reach `.view`.
// `Toast` resolves the key window itself, so SwiftUI screens that have no host
// can still show the same toast.
//
// Behaviour is identical: these forward to the exact same `UIView` methods, just
// on the key window instead of a caller-supplied view.

enum Toast {

    /// Key window of the foreground-active scene, falling back to any key window.
    static var anchor: UIView? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: { $0.isKeyWindow })
            ?? scenes.flatMap(\.windows).first(where: { $0.isKeyWindow })
    }

    /// Resolves an explicit anchor, falling back to the key window when it is nil.
    /// Lets a call site keep passing `hostViewController?.view` while still working
    /// once that host is gone.
    static func resolvedAnchor(_ anchorView: UIView?) -> UIView? {
        anchorView ?? anchor
    }

    static func show(message: String, title: String? = nil, point: CGPoint? = nil) {
        anchor?.showToast(message: message, title: title, point: point)
    }

    static func showActivity() {
        anchor?.showToastActivity()
    }

    static func hideActivity() {
        anchor?.hideToastActivity()
    }
}
