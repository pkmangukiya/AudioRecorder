
import UIKit
import AVFoundation

class AudioRecordingVC: UIViewController {
    
    var recordButton : UIButton = UIButton(type: .custom)
    var counter = 0
    var timer = Timer()
    
    
    @IBOutlet var viewBackRecording: UIView!
    @IBOutlet var viewRecording: UIView!
    @IBOutlet var viewCancel: UIView!
    @IBOutlet var lblCancel: UILabel!
    @IBOutlet var lblRecordingTime: UILabel!
    @IBOutlet var imgMicrophonePic: UIImageView!
    
    @IBOutlet var conWidthViewCancel: NSLayoutConstraint!
    @IBOutlet var conWidthLblCancel: NSLayoutConstraint!
    @IBOutlet var conWidthRcordingTime: NSLayoutConstraint!
    @IBOutlet var conWidthMicrophonePic: NSLayoutConstraint!
    
    enum RecordViewState {
        case Recording
        case None
    }
    
    var state : RecordViewState = .None {
        didSet {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecordButton()
        viewCancel.layer.cornerRadius = 5
    }
    
    func setupRecordButton() {
        
        recordButton.backgroundColor = hexColor(hex: "#673DB7")
        recordButton.frame = CGRect(x: (viewRecording.frame.width) - 5, y: self.viewRecording.center.y, width: 35, height: 35)
        
        recordButton.center.y = self.viewRecording.center.y
        recordButton.layer.cornerRadius = recordButton.frame.height / 2
        viewRecording.addSubview(recordButton)
        
        self.recordButton.layer.borderWidth = 0
        let image = UIImage(named: "microphone")?.withRenderingMode(.alwaysTemplate)
        recordButton.setImage(image, for: .normal)
        recordButton.tintColor = UIColor.white
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userDidTapRecord(_:)))
        longPress.cancelsTouchesInView = false
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPress)
    }
    
    @objc func userDidTapRecord(_ gesture: UIGestureRecognizer) {
        
        let button = gesture.view as! UIButton
        let location = gesture.location(in: button)
        var startLocation = CGPoint.zero
        
        switch gesture.state {
        case .began:
            userDidBeginRecord(sender: button)
        case .changed:
            if state == .Recording {
                let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
                if !button.bounds.contains(translate) {
                    userDidTapRecordThenSwipe(sender: button)
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                
                self.recordButton.layer.borderWidth = 0
                self.conWidthViewCancel.constant = 0
                self.conWidthLblCancel.constant = 0
                self.conWidthRcordingTime.constant = 0
                self.conWidthMicrophonePic.constant = 0
                self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            print("Long Tap Out")
            if state == .None { return }
            
            userDidStopRecording(sender: button)
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            
            if !button.frame.contains(translate) {
                userDidStopRecording(sender: button)
            }
            
        case .failed, .possible ,.cancelled :
            if state == .Recording {
                userDidStopRecording(sender: button)
            }
            else {
                print(state)
                userDidTapRecordThenSwipe(sender: button)
            }
        }
    }
    
    func userDidTapRecordThenSwipe(sender: UIButton) {
        cancelRecord(sender: self, button: sender)
    }
    
    func userDidStopRecording(sender: UIButton) {
        StopRecord(sender: self, button: sender)
    }
    
    func userDidBeginRecord(sender : UIButton) {
        startRecording(sender: self, button: sender)
    }
    
    func cancelRecord(sender: AudioRecordingVC, button: UIView) {
        counter = 0
        timer.invalidate()
        sender.state = .None
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.recordButton.layer.borderWidth = 0
            self.conWidthLblCancel.constant = self.conWidthLblCancel.constant + 10
            self.recordButton.layer.borderWidth = 3
            self.recordButton.layer.borderColor = self.hexColor(hex: "#D2D2D2").cgColor
            self.recordButton.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        let frameImgMicrophonePic = self.imgMicrophonePic.superview?.convert(self.imgMicrophonePic.frame, to: nil)
        
        // Animation
        let imageName = "ic_microphone"
        let image = UIImage(named: imageName)
        print(frameImgMicrophonePic)
        let imgAnimation = UIImageView(image: image!)
        
        let imageDustbin = "ic_trash"
        let image2 = UIImage(named: imageDustbin)
        let imgDustbin = UIImageView(image: image2!)
        
        imgAnimation.frame.size = CGSize(width: 20, height: 20)
        self.view.addSubview(imgAnimation)
        imgAnimation.center = CGPoint(x: (frameImgMicrophonePic?.origin.x)! + (frameImgMicrophonePic?.width)! / 2, y: (frameImgMicrophonePic?.origin.y)!)
        
        self.imgMicrophonePic.isHidden = true
        
        imgDustbin.frame.size = CGSize(width: 20, height: 20)
        self.view.addSubview(imgDustbin)
        imgDustbin.center = CGPoint(x: (frameImgMicrophonePic?.origin.x)! + (frameImgMicrophonePic?.width)! / 2, y: (frameImgMicrophonePic?.origin.y)! + 15)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            
            imgAnimation.frame = CGRect(x: (frameImgMicrophonePic?.origin.x)! + (frameImgMicrophonePic?.width)! / 2, y: (frameImgMicrophonePic?.origin.y)! - 150, width: 20, height: 20)
            
        }) { finished in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                imgAnimation.transform = CGAffineTransform(scaleX: -1.0, y: -1.0)
            }, completion: nil)
            
        }
        view.addSubview(imgAnimation)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            imgAnimation.frame = CGRect(x: (frameImgMicrophonePic?.origin.x)! + (frameImgMicrophonePic?.width)! / 2 - 10, y: (frameImgMicrophonePic?.origin.y)!, width: 20, height: 20)
        }) { finished in
            imgAnimation.removeFromSuperview()
            imgDustbin.removeFromSuperview()
            // self.imgMicrophonePic.isHidden = false
        }
        /////
        print("Cancelled recording")
    }
    
    func startRecording(sender: AudioRecordingVC, button: UIView) {
        timer.invalidate()
        UIView.animate(withDuration: 0.0, delay: 0.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            
            self.imgMicrophonePic.isHidden = false
            sender.state = .Recording
            self.recordButton.tintColor = UIColor.white
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.recordButton.layer.borderWidth = 3
            self.recordButton.layer.borderColor = self.hexColor(hex: "#D2D2D2").cgColor
            self.conWidthViewCancel.constant = self.viewRecording.frame.width - 10
            self.conWidthLblCancel.constant = 150
            self.conWidthRcordingTime.constant = 50
            self.conWidthMicrophonePic.constant = 30
            
            self.recordButton.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        print("Start Recording")
        
        // Start Your Recording
    }
    
    func StopRecord(sender : AudioRecordingVC, button: UIView) {
        counter = 0
        timer.invalidate()
        recordButton.tintColor = UIColor.white
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.recordButton.layer.borderWidth = 0
            self.conWidthViewCancel.constant = 0
            self.conWidthLblCancel.constant = 0
            self.conWidthRcordingTime.constant = 0
            self.conWidthMicrophonePic.constant = 0
            self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        sender.state = .None
        print("Done Recording")
        
        // // Done Your Recording
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func timerAction() {
        counter += 1
        lblRecordingTime.text = "0.\(counter)"
    }
    
    func hexColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

