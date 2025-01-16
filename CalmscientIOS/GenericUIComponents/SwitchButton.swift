import UIKit
import CoreMotion

@IBDesignable
public class SwitchButton: UIButton {

    var changeResponseClosure:((Bool)->Void)?
    var status: Bool = false {
        didSet {
            self.update()
            changeResponseClosure?(status)
        }
    }
    @IBInspectable
    var onImage: UIImage? {
        didSet {
            self.update()
        }
    }
    
    @IBInspectable
    var offImage: UIImage? {
        didSet {
            self.update()
        }
    }
    
//    public var onImage: UIImage? = nil{
//        didSet{
//            self.update()
//        }
//    }
//
//    public var offImage: UIImage? = nil{
//        didSet{
//            self.update()
//        }
//    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setStatus(false)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func update() {
        UIView.transition(with: self, duration: 0.10, options: .transitionCrossDissolve, animations: {
            self.status ? self.setImage(self.onImage, for: .normal) : self.setImage(self.offImage, for: .normal)
        }, completion: nil)
    }
    func toggle() {
        self.status ? self.setStatus(false) : self.setStatus(true)
    }
    
    func setStatus(_ status: Bool) {
        self.status = status
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.sendHapticFeedback()
        self.toggle()
    }
    
    func sendHapticFeedback() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
}
