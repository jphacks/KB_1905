//
//  SensorDetailViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/24.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit
import Charts

//var dangerData: [[String: Any]] = [[:]] //危険を検知した時のセンサーデータ
var times: [String]! = [] //グラフのｘ軸


class SensorDetailViewController: UIViewController {

    @IBOutlet weak var timeBackView: UIView!
    @IBOutlet weak var timeLavelView: UILabel!
    @IBOutlet weak var dangerLavelView: UILabel!
    @IBOutlet weak var dangerBackView: UIView!
    @IBOutlet weak var sensorLavelView: UILabel!
    @IBOutlet weak var sensorBackView: UIView!
    @IBOutlet weak var dangerSocondsView: UILabel!
    @IBOutlet weak var dangerTextLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moveLavel: UILabel!
    @IBOutlet weak var yLavel: UILabel!
    
    //折れ線グラフ
    var chart: CombinedChartView!
    var lineDataSet: LineChartDataSet!
    var bubbleDataSet: BubbleChartDataSet!
    
    //円グラフ
    private let chartView:ChartView = ChartView()
    
    var dangerTime:String = ""    //  追加
    var dangerTimestamp:String = ""    //  追加
    var dangerMove:Int = 0    //  追加
    var dangerData: [[String: Any]] = [[:]] //危険を検知した時のセンサーデータ
    var dangerSeconds: Int = 0 //揺れ検知時刻を格納
    var maxDangerLevel: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sensorData = SensorViewController()
        timeLabel.text = dangerTime

         print("###############sensordata:\(sensorData.dist)")
        // Do any additional setup after loading the view.
        //センサー履歴をget
        getDangerStatus()
        
        //背景の設定
        backgroundView(backView: timeBackView, lavelView: timeLavelView)
        backgroundView(backView: dangerBackView, lavelView: dangerLavelView)
        backgroundView(backView: sensorBackView, lavelView: sensorLavelView)

        //ここからグラフ描画
        
        //折れ線グラフ
        yLavel.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        //combinedDataを結合グラフに設定する
        
        let combinedData = CombinedChartData()

        //結合グラフに線グラフのデータ読み出し
        combinedData.lineData = generateLineData()

        //グラフのサイズ設定、座標設定
        chart = CombinedChartView(frame: CGRect(x: 30, y: self.view.frame.height - 380, width: self.view.frame.width - 50 , height: 250))

        //chartのデータにcombinedDataを挿入する
        chart.data = combinedData
             
        //危険ライン
        let ll1 = ChartLimitLine(limit: 80, label: "大きな揺れ")
        ll1.lineWidth = 4
        ll1.lineDashLengths = [5, 5]
        ll1.labelPosition = .topRight
        ll1.valueFont = .systemFont(ofSize: 10)
        let ll2 = ChartLimitLine(limit: 40, label: "小さな揺れ")
        ll2.lineWidth = 4
        ll2.lineDashLengths = [5, 5]
        ll2.labelPosition = .topRight
        ll2.lineColor = .orange
        ll2.valueFont = .systemFont(ofSize: 10)

        //左軸
        let yAxis = chart.leftAxis
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size:12)!
        yAxis.setLabelCount(6, force: false)
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 110
        yAxis.drawAxisLineEnabled = true
        yAxis.gridLineDashLengths = [5, 5]
        yAxis.axisLineWidth = 2
        yAxis.addLimitLine(ll1)
        yAxis.addLimitLine(ll2)
        //右軸
        chart.rightAxis.enabled = false
        
        //ｘ軸
        let xAxis = chart.xAxis
        xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size:18)!
        xAxis.setLabelCount(3, force: true)
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = .black
        xAxis.drawAxisLineEnabled = true
        xAxis.axisLineWidth = 2
        xAxis.drawGridLinesEnabled = false
        xAxis.valueFormatter = BarChartFormatter()

        
        //
        dangerSocondsView.text = "\(dangerSeconds)秒間揺れを検知"
        //アニメーション
        chart.animate(yAxisDuration: 2.5)
        //chart.animate(xAxisDuration: 2, yAxisDuration: 2)
        
        //chartを出力
        self.view.addSubview(chart)
    }
    
    func generateLineData() -> LineChartData
    {
        //リストを作り、グラフのデータを追加する方法（GitHubにあったCombinedChartViewとかMPAndroidChartのwikiを参考にしている
        //データを入れていく、多重配列ではないため別々にデータは追加していく
        //let values: [Double] = [10, 15, 41, 82, 100, 100, 100, 95, 80, 86,
                               // 45, 60, 30, 25, 15, 10]
        //let date : [Double] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

        //DataSetを行うために必要なEntryの変数を作る　データによって入れるデータが違うため複数のentriesが必要になる？
        var entries: [ChartDataEntry] = Array()
        var moveHistries: [Double] = []
        for (i, dangerData) in dangerData.enumerated(){
            let moveHistry = Double((dangerData["move"] as! NSString).doubleValue)
            moveHistries.insert(moveHistry, at: 0)
            //moveHistries.append(moveHistry)
            if moveHistry >= 20 {
                dangerSeconds += 1
            }
            maxDangerLevel = max(maxDangerLevel, Int(moveHistry))
            //ｘ軸のセット
            let time = SensorViewController()
            let timeStamp = (dangerData["timestamp"] as! NSString).doubleValue
            times.insert(time.timeStampToDate(timestamp: timeStamp, type: 2), at: 0)
        }
        
        for (i, moveHistry) in moveHistries.enumerated(){

            entries.append(ChartDataEntry(x: Double(i), y: moveHistry, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }

        //データを送るためのDataSet変数をリストで作る
        var linedata:  [LineChartDataSet] = Array()

        //リストにデータを入れるためにデータを成形している
        //データの数値と名前を決める
        lineDataSet = LineChartDataSet(entries: entries, label: "荷物の揺れ度合い")
        lineDataSet.drawIconsEnabled = false
        //グラフの直線を滑らかに
        //lineDataSet.mode = .cubicBezier
        //線の太さ
        lineDataSet.lineWidth = 3
        //データ点の丸の大きさ
        lineDataSet.circleRadius = 0
        //データ点の描画
        lineDataSet.circleRadius = 5.0
        lineDataSet.circleHoleRadius = 2.5
        lineDataSet.setCircleColor(.red)
        //グラフの線の色とマルの色を変えている
        lineDataSet.colors = [.red]
        //グラフのデータ非表示
        lineDataSet.drawValuesEnabled = false
        
        //グラフの塗り潰し
        lineDataSet.fillAlpha = 0.5
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillColor = UIColor(red: 244/255, green: 177/255, blue: 177/255, alpha: 0.5)
        //上で作ったデータをリストにappendで入れる
        linedata.append(lineDataSet)

        moveLavel.text = "\(maxDangerLevel)%"
        if maxDangerLevel >= 80 {
            dangerTextLabel.text = "非常に危険です"
        } else if maxDangerLevel >= 40 {
            dangerTextLabel.text = "危険です"
        }
        
        //円グラフ
        self.view.addSubview(chartView)
        let rate = Double(maxDangerLevel)
        chartView.drawChart(rate: rate)

        //データを返す。
        return LineChartData(dataSets: linedata)
    }
    
    //背景のUI設定
    func backgroundView(backView: UIView!, lavelView: UILabel!) {
        //画面の見た目
        backView.layer.cornerRadius = 8
        lavelView.layer.cornerRadius = 8
        lavelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        lavelView.clipsToBounds = true
        // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        backView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        // 影の色
        backView.layer.shadowColor = UIColor.black.cgColor
        // 影の濃さ
        backView.layer.shadowOpacity = 0.3
        // 影をぼかし
        backView.layer.shadowRadius = 4
    }
    
    //http get request
    func getDangerStatus() {
        //http通信処理　同期処理
        let myUrl:URL = URL(string: "https://www.55g-jphacks2019.tk/sensors/move/history?timestamp=\(dangerTimestamp)")!
        let req = NSMutableURLRequest(url: myUrl)
        //let postText = "key1=value1&key2=value2"
        //let postData = postText.data(using: String.Encoding.utf8)
        req.httpMethod = "GET"
        //req.httpBody = postData
        let myHttpSession = HttpClientImpl()
        let (data, _, _) = myHttpSession.execute(request: req as URLRequest)
        if data != nil {
            // 受け取ったデータに対する処理
            //print(data as Any)
            do {
                 let json = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
                 let articles = json.map { (article) -> [String: Any] in
                     return article as! [String: Any]
                 }
                 dangerData = articles
                 print(dangerData)
             }
             catch {
                 print(error)
             }
        }

    }
    
    //delete histry post request
    func postDeleteHistry() {
        guard let url = URL(string: "https://www.55g-jphacks2019.tk/sensors/move/delete") else {return}
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // POSTを指定
        request.httpMethod = "POST"
          
        let params: [String: String] = [
            "timestamp": dangerTimestamp
        ]
          // POSTするデータをBodyとして設定
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {return}
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                // HTTPヘッダの取得
                print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                // HTTPステータスコード
                print("statusCode: \(response.statusCode)")
                print(String(data: data, encoding: .utf8) ?? "")
            }
        }.resume()
    }
    
    //揺れ検知履歴の削除
    //ボタンを押すとアラートを表示　-> 削除 -> 揺れ検知履歴をリストから削除
    @IBAction func deleteHistry(_ sender: Any) {
        // アラートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "履歴の削除"
        alert.message = "揺れ検知履歴を削除します。荷物の安全を確認後、削除ボタンを押してください。"
        // 赤色のボタン
        alert.addAction(
            UIAlertAction(
                title: "削除",
                style: .destructive,
                handler: {(action) -> Void in
                    self.deleteHistryTab(action.title!)
            })
        )
        
        // キャンセル（追加順にかかわらず最後に表示される）
        alert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: .cancel,
                handler: nil)
        )
        
        // アラートを表示する
        self.present(
            alert,
            animated: true,
            completion: {
                // 表示完了後に実行
                print("アラートが表示された")
        }
        )
    }
    
    // 揺れ検知時刻削除，削除ボタンを無効化
    func deleteHistryTab(_ msg:String) {
        print(msg)
        postDeleteHistry()
        self.navigationController?.popViewController(animated: true)
    }
}

//同期通信処理
public class HttpClientImpl {
    private let session: URLSession
    public init(config: URLSessionConfiguration? = nil) {
        self.session = config.map { URLSession(configuration: $0) } ?? URLSession.shared
    }
    public func execute(request: URLRequest) -> (NSData?, URLResponse?, NSError?) {
        var d: NSData? = nil
        var r: URLResponse? = nil
        var e: NSError? = nil
        let semaphore = DispatchSemaphore(value: 0)
        session
            .dataTask(with: request) { (data, response, error) -> Void in
                d = data as NSData?
                r = response
                e = error as NSError?
                semaphore.signal()
            }
            .resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return (d, r, e)
    }
}

//x軸のラベルを設定する処理。
public class BarChartFormatter: NSObject, IAxisValueFormatter{
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return times[Int(value)]
    }
}
