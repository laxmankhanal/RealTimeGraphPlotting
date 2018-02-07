
import AudioKit
import AudioKitUI
import Charts

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var combinedChartView: CombinedChartView!
  @IBOutlet weak var verticalLineChart: LineChartView!
  @IBOutlet weak var lineChartView: LineChartView!
  @IBOutlet weak var micButton: UIButton!
  @IBOutlet weak var micValueLabel: UILabel!
  @IBOutlet weak var fileValueLabel: UILabel!
  @IBOutlet weak var fileButton: UIButton!
  
  private let ITEM_COUNT = 12
  
  let mic = AKMicrophone()
  var micTracker: AKFrequencyTracker!
  var fileTracker: AKFrequencyTracker!
  var isMicStarted = false
  var isFileStarted = false
  var player: AKAudioPlayer!
  var dataEntries: [ChartDataEntry] = []
  var xAxisUnits = ["a"]
  var values = [2.0]
  let months = ["Jan", "Feb", "Mar",
                "Apr", "May", "Jun",
                "Jul", "Aug", "Sep",
                "Oct", "Nov", "Dec"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Combined Chart"
    
    combinedChartView.chartDescription?.enabled = false
//    combinedChartView.maxVisibleCount = 60
    combinedChartView.drawBarShadowEnabled = false
    combinedChartView.highlightFullBarEnabled = false
    combinedChartView.drawOrder = [
//                                  DrawOrder.bar.rawValue,
//                                   DrawOrder.bubble.rawValue,
                                    DrawOrder.line.rawValue,
                                    DrawOrder.candle.rawValue,
      
//                                   DrawOrder.scatter.rawValue
    ]
    let l = combinedChartView.legend
    l.wordWrapEnabled = true
    l.horizontalAlignment = .center
    l.verticalAlignment = .bottom
    l.orientation = .horizontal
    l.drawInside = false
    
    let rightAxis = combinedChartView.rightAxis
    rightAxis.axisMinimum = 0
    
    let leftAxis = combinedChartView.leftAxis
    leftAxis.axisMinimum = 0
    
    let xAxis = combinedChartView.xAxis
    xAxis.labelPosition = .bothSided
    xAxis.axisMinimum = 0
    xAxis.granularity = 1
//    xAxis.valueFormatter = self
    
    self.updateChartData()
    
//    if #available(iOS 10.0, *) {
//      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
//        self.dataEntries.removeAll()
//      }
//    } else {
//      // Fallback on earlier versions
//    }
//    timer = NSTimer.scheduledTimerWithTimeInterval(0.010, target:self, selector: #selector(ViewController.updateCounter), userInfo: nil, repeats: true)
    
    //: Set the microphone device if you need to
    do {
      let file = try AKAudioFile(readFileName: "440Hz.wav", baseDir: .resources)
      self.player = try AKAudioPlayer(file: file)
      self.fileTracker = AKFrequencyTracker(self.player)
      AudioKit.output = self.fileTracker
    } catch {
      print("Audio file not found")
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
  }
  
  func updateChartData() {
    self.setChartData()
  }
  
  func setChartData() {
    let data = CombinedChartData()
    data.lineData = generateLineData()
//    data.barData = generateBarData()
//    data.bubbleData = generateBubbleData()
//    data.scatterData = generateScatterData()
    data.candleData = generateCandleData()
    
    combinedChartView.xAxis.axisMaximum = data.xMax + 0.25
    
    combinedChartView.data = data
  }
  
  func generateLineData() -> LineChartData {
    let entries = (0..<ITEM_COUNT).map { (i) -> ChartDataEntry in
      return ChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
    }
    
    let set = LineChartDataSet(values: entries, label: "Line DataSet")
    set.setColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
    set.lineWidth = 2.5
    set.setCircleColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
    set.circleRadius = 5
    set.circleHoleRadius = 2.5
    set.fillColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
    set.mode = .stepped
    set.drawValuesEnabled = true
    set.valueFont = .systemFont(ofSize: 10)
    set.valueTextColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
    
    set.axisDependency = .left
    
    return LineChartData(dataSet: set)
  }
  
  func generateBarData() -> BarChartData {
    let entries1 = (0..<ITEM_COUNT).map { _ -> BarChartDataEntry in
      return BarChartDataEntry(x: 0, y: Double(arc4random_uniform(25) + 25))
    }
    let entries2 = (0..<ITEM_COUNT).map { _ -> BarChartDataEntry in
      return BarChartDataEntry(x: 0, yValues: [Double(arc4random_uniform(13) + 12), Double(arc4random_uniform(13) + 12)])
    }
    
    let set1 = BarChartDataSet(values: entries1, label: "Bar 1")
    set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
    set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
    set1.valueFont = .systemFont(ofSize: 10)
    set1.axisDependency = .left
    
    let set2 = BarChartDataSet(values: entries2, label: "")
    set2.stackLabels = ["Stack 1", "Stack 2"]
    set2.colors = [UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1),
                   UIColor(red: 23/255, green: 197/255, blue: 255/255, alpha: 1)
    ]
    set2.valueTextColor = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
    set2.valueFont = .systemFont(ofSize: 10)
    set2.axisDependency = .left
    
    let groupSpace = 0.06
    let barSpace = 0.02 // x2 dataset
    let barWidth = 0.45 // x2 dataset
    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
    
    let data = BarChartData(dataSets: [set1, set2])
    data.barWidth = barWidth
    
    // make this BarData object grouped
    data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
    
    return data
  }
  
  func generateScatterData() -> ScatterChartData {
    let entries = stride(from: 0.0, to: Double(ITEM_COUNT), by: 0.5).map { (i) -> ChartDataEntry in
      return ChartDataEntry(x: i+0.25, y: Double(arc4random_uniform(10) + 55))
    }
    
    let set = ScatterChartDataSet(values: entries, label: "Scatter DataSet")
    set.colors = ChartColorTemplates.material()
    set.scatterShapeSize = 4.5
    set.drawValuesEnabled = false
    set.valueFont = .systemFont(ofSize: 10)
    
    return ScatterChartData(dataSet: set)
  }
  
  func generateCandleData() -> CandleChartData {
    let entries = stride(from: 0, to: ITEM_COUNT, by: 2).map { (i) -> CandleChartDataEntry in
      return CandleChartDataEntry(x: Double(i+1), shadowH: Double(self.combinedChartView.frame.height), shadowL: 70, open: 85, close: 75)
    }
    
    let set = CandleChartDataSet(values: entries, label: "Candle DataSet")
    set.setColor(UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1))
    set.decreasingColor = UIColor(red: 142/255, green: 150/255, blue: 175/255, alpha: 1)
    set.shadowColor = .darkGray
    set.valueFont = .systemFont(ofSize: 10)
    set.drawValuesEnabled = false
    
    return CandleChartData(dataSet: set)
  }
  
  func generateBubbleData() -> BubbleChartData {
    let entries = (0..<ITEM_COUNT).map { (i) -> BubbleChartDataEntry in
      return BubbleChartDataEntry(x: Double(i) + 0.5,
                                  y: Double(arc4random_uniform(10) + 105),
                                  size: CGFloat(arc4random_uniform(50) + 105))
    }
    
    let set = BubbleChartDataSet(values: entries, label: "Bubble DataSet")
    set.setColors(ChartColorTemplates.vordiplom(), alpha: 1)
    set.valueTextColor = .white
    set.valueFont = .systemFont(ofSize: 10)
    set.drawValuesEnabled = true
    
    return BubbleChartData(dataSet: set)
  }

  @IBAction func micAction(_  sender: UIButton) {
    if isMicStarted {
      mic.stop()
      micButton.setTitle("Start", for: .normal)
    } else {
      AKPlaygroundLoop(every: 1) {
        self.micValueLabel.text = String(self.micTracker.frequency)
        self.updateChart(with: self.micTracker.frequency)
      }
      mic.start()
      micButton.setTitle("Stop", for: .normal)
    }
    
    isMicStarted = !isMicStarted
  }
  
  @IBAction func fileAction(_ sender: UIButton) {
    if isFileStarted {
      fileButton.setTitle("Play", for: .normal)
      self.player.stop()
    } else {
      fileButton.setTitle("Stop", for: .normal)
      AKPlaygroundLoop(every: 0.5) {
        self.fileValueLabel.text = String(self.fileTracker.frequency)
      }
      self.player.play()
    }
    isFileStarted = !isFileStarted
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func updateChart(with frequency: Double) {
    self.dataEntries.removeAll()
    for i in 0..<self.xAxisUnits.count {
      let dataEntry = ChartDataEntry(x: Double(i), y: self.values[i])
      self.dataEntries.append(dataEntry)
    }
    
    let chartDataSet = LineChartDataSet(values: self.dataEntries, label: "")
    chartDataSet.setCircleColor(UIColor.red)
    chartDataSet.setColor(UIColor.gray)
    chartDataSet.circleRadius = 2
    chartDataSet.drawFilledEnabled = true
    chartDataSet.lineWidth = 2
    chartDataSet.valueTextColor = UIColor.black
    
    
    let chartData = LineChartData(dataSet: chartDataSet)
//    self.lineChartView.xAxis.valueFormatter = self
    self.lineChartView.drawGridBackgroundEnabled = false
    self.lineChartView.xAxis.labelPosition = .bottom
    self.lineChartView.setVisibleXRange(minXRange: 1.0, maxXRange: 50)
    self.lineChartView.notifyDataSetChanged()
    self.lineChartView.moveViewToX(frequency)
    self.lineChartView.data = chartData
    
    if values.count > 5 {
      self.values.removeFirst()
      self.xAxisUnits.removeFirst()
    }
    self.xAxisUnits.append("")
    self.values.append(frequency)
  }
  
}
