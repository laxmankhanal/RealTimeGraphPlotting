
import UIKit
import AudioKit
import AudioKitUI

class GraphVC: UIViewController {
  
  var path: UIBezierPath!
  var stepHeight: CGFloat = 0.0
  var stepArray: [Int] = [6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3, 6, 5, 4, 5, 7, 3]
  
  @IBOutlet weak var movableView: UIView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var frequencyRefView: UIView!
  @IBOutlet weak var demoView: DemoView!
  
  var fileTracker: AKFrequencyTracker!
  var player: AKAudioPlayer!
  let mic = AKMicrophone()
  var micTracker: AKFrequencyTracker!
  var startPoint: CGPoint = CGPoint.zero
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stepHeight = CGFloat(self.view.frame.height / 8)
//    UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
//      self.movableView.center.y = 400
//    }) { (isCompleted) in
//      print("ANimation completed")
//    }
    
    guard let subViews = self.stackView.subviews as? [UILabel] else { return }
    if #available(iOS 10.0, *) {
      var previousEndPoint = CGPoint.zero      
      for (index, item) in stepArray.enumerated() {
        var startPoint = CGPoint.zero
        var endPoint = CGPoint.zero
        let yPos = subViews[item].center.y
        if index == 0 {
          startPoint = CGPoint(x: 0, y: yPos)
          previousEndPoint = startPoint
        } else {
          startPoint = previousEndPoint
        }
        startPoint.y = yPos
        endPoint = CGPoint(x: startPoint.x + 20, y: yPos)
        self.demoView.createPath(from: startPoint, to: endPoint, previousEndPoint: previousEndPoint)
        previousEndPoint = endPoint
      }
      
      Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
        let xPosition = self.demoView.contentOffset.x + 0.5
        self.demoView.contentOffset.x = xPosition
      })
    } else {
      // Fallback on earlier versions
    }
    
    do {
      if let inputs = AudioKit.inputDevices {
        try AudioKit.setInputDevice(inputs[0])
        try mic.setDevice(inputs[0])
      }
    } catch {
      print("No input device found")
    }
    
    micTracker = AKFrequencyTracker(mic, hopSize: 200, peakCount: 2_000)
    let silence = AKBooster(micTracker, gain: 0)
    
    //: The frequency tracker passes its input to the output,
    //: so we can insert into the signal chain at the bottom
    AudioKit.output = silence
    AudioKit.start()
    mic.start()
    AKPlaygroundLoop(every: 0.1) {
      print("Frequency: \(self.micTracker.frequency)")
      self.movableView.center.y = CGFloat(self.micTracker.frequency)
      let x = self.demoView.contentOffset.x + self.movableView.center.x + 75
      let y = self.movableView.center.y
      let endPoint = CGPoint(x: x, y: y)
      self.demoView.createPath(from: self.startPoint, to: endPoint)
      self.startPoint = endPoint
//      self.demoView.createPath(from: self.startPoint, to: self.movableView.center, previousEndPoint: self.startPoint)
//      let frame = self.movableView.superview?.superview?.convert(self.movableView.frame, to: nil)
//      print("previous point: \(self.startPoint) start point: \(self.startPoint), endPoint: \(self.movableView.center)")
//      print("frame: \(frame)")
//      self.startPoint = self.movableView.center
    }
  }    
  
}
