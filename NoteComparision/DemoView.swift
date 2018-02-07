
import UIKit

class DemoView: UIScrollView {
  
  var path: UIBezierPath = UIBezierPath()
  var graph: UIBezierPath = UIBezierPath()
  
  override func awakeFromNib() {
    super.awakeFromNib()
//    self.backgroundColor = UIColor.darkGray
//    simpleShapeLayer()
//    createPath(from: CGPoint(x: 50, y: 100), to: CGPoint(x: 100, y: 200))
  }
  
//  override func draw(_ rect: CGRect) {
////    createRectangle()
//    createTriangle()
//    // Specify the fill color and apply it to the path.
//    UIColor.orange.setFill()
//    path.fill()
//
//    // Specify a border (stroke) color.
//    UIColor.purple.setStroke()
//    path.stroke()
//  }
//
  func simpleShapeLayer() {
    self.createRectangle()
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = self.path.cgPath
    
    self.layer.addSublayer(shapeLayer)
  }
  
  func createPath(from startingPoint: CGPoint, to endPoint: CGPoint, previousEndPoint: CGPoint) {
    path.move(to: previousEndPoint)
    path.addLine(to: startingPoint)
    path.addLine(to: endPoint)
    
//    print("previous point: \(previousEndPoint) start point: \(startingPoint), endPoint: \(endPoint)")
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.lineWidth = 2
    shapeLayer.strokeColor = UIColor.red.cgColor
    shapeLayer.fillColor = UIColor.white.cgColor
    shapeLayer.path = self.path.cgPath
    self.layer.addSublayer(shapeLayer)
  }
  
  func createPath(from startingPoint: CGPoint, to endPoint: CGPoint) {
    graph.move(to: startingPoint)
    graph.addLine(to: endPoint)
    
    //    print("previous point: \(previousEndPoint) start point: \(startingPoint), endPoint: \(endPoint)")
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.lineWidth = 2
    shapeLayer.strokeColor = UIColor.black.cgColor
    shapeLayer.fillColor = UIColor.white.cgColor
    shapeLayer.path = self.graph.cgPath
    self.layer.addSublayer(shapeLayer)
  }

  func createTriangle() {
    path = UIBezierPath()
    path.move(to: CGPoint(x: self.frame.width/2, y: 0.0))
    path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
    path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
    path.close()
  }
  
  func createRectangle() {
    // Initialize the path.
    path = UIBezierPath()
    
    // Specify the point that the path should start get drawn.
    path.move(to: CGPoint(x: 0.0, y: 0.0))
    
    // Create a line between the starting point and the bottom-left side of the view.
    path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
    
    // Create the bottom line (bottom-left to bottom-right).
    path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
    
    // Create the vertical line from the bottom-right to the top-right side.
    path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
    
    // Close the path. This will create the last line automatically.
    path.close()
  }

}
