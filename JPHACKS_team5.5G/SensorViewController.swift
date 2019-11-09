//
//  FirstViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit

class SensorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var dangerTimes:[String] = []   //揺れ検知時刻
    var dangerMove:[Int] = []   //揺れ度合い
    var sensorData: [String: Any]? = [:] //getしてきたセンサーデータ
    var dangerData: [[String: Any]] = [[:]] //危険を検知した時のセンサーデータ
    //var dangerData: [[String: Any]] = [["timestamp": "1571549693", "move": "70"]] //危険を検知した時のセンサーデータ
    var move:Int = 0    //センサーの揺れ度
    var dist:Double = 0   //Bluetoothの電波強度
    var runAnimation: Timer?    //背景のアニメーションタイマー　泥棒が移動
    var selectedTime:String?    //詳細画面に送るデータを格納
    var selectedMove:Int?    //詳細画面に送るデータを格納
    var selectedTimestamp:String?
    var dangerFlag = 0
    
    @IBOutlet weak var timestamp: UITextField!
    @IBOutlet weak var bag: UIImageView!
    @IBOutlet weak var husinsha: UIImageView!
    @IBOutlet weak var dangerLevel: UILabel!
    @IBOutlet weak var border: UILabel!
    @IBOutlet weak var sence: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        border.layer.borderColor = UIColor.black.cgColor
        //ボーダー色（白）
        border.layer.borderWidth = 2.0;
        timestamp.layer.borderWidth = 0.5;
        timestamp.layer.borderColor = UIColor.darkGray.cgColor;

        border.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        resetButton.isEnabled = false // 安全ボタン無効
        resetButton.setTitleColor(.lightGray, for: .normal)
        
        let queue = OperationQueue()
 
        queue.addOperation() {
            // do something in the background
            var count = 0
            while(count < 10000) {
                self.getDangerStatus()
                self.getSensorStatus()
                sleep(2)
                OperationQueue.main.addOperation() {
                    // when done, update your UI and/or model on the main queue
                    //揺れ度グラフのぎ描画
                    self.drawGraph(_height: self.move)
                    //検知モード設定
                    if self.dist <= -2.0{
                        //ラベル　検知モードオフ -> 検知中・・・
                        if self.sence.text != "検知中・・・" {
                            self.sence.text = "検知中・・・"
                            self.sence.backgroundColor = UIColor.orange
                            self.sence.textColor = UIColor.white
                        }
                        //table view に揺れ検知時刻一覧を表示
                        if self.dangerData.count >= 0 && self.dangerData.count != self.dangerTimes.count {
                            self.dangerTimes = []
                            self.dangerMove = []
                            for danger in self.dangerData {
                                let timestamp = (danger["timestamp"] as! NSString).doubleValue
                                let move = Int((danger["move"] as! NSString).intValue)
                                self.dangerTimes.append(self.timeStampToDate(timestamp: timestamp, type: 1))
                                self.dangerMove.append(move)
                            }
                            //self.tableView.reloadData()
                        }
                        
                        //アニメーション　泥棒表示と　安全です -> 危険です タブバーにバッジ
                        if self.move >= 40 && self.dangerFlag == 0{
                            self.timestamp.text = "危険です"
                            self.timestamp.backgroundColor = UIColor.red
                            self.timestamp.textColor = UIColor.black
                            self.husinsha.image = UIImage(named: "husinsha")
                            self.husinsha.isHidden = false
                            self.timer()
                            self.dangerFlag = 1
                            self.resetButton.isEnabled = true // ボタン有効
                            self.resetButton.setTitleColor(.systemBlue, for: .normal)
                            //タブバーにバッジをセット
                            if let tabItem = self.tabBarController?.tabBar.items?[0] {
                                tabItem.badgeValue = "!"
                            }
                        }

                    } else {
                        self.sence.text = "検知モードオフ"
                        self.sence.backgroundColor = UIColor.systemGroupedBackground
                        self.sence.textColor = UIColor.darkGray
                    }
                    self.tableView.reloadData()
                }
                count += 1
            }
        }
    }
    
    //http get request
    func getSensorStatus() {
        let url: URL = URL(string: "https://www.55g-jphacks2019.tk/sensors")!
        let task: URLSessionTask  = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                self.sensorData = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                print(self.sensorData!)

                //Int型へキャスト
                if self.sensorData!["move"] != nil && self.sensorData!["dist"] != nil{
                    self.move = Int((self.sensorData!["move"] as! NSString).intValue)
                    self.dist = (self.sensorData!["dist"] as! NSString).doubleValue
                } else {
                    print("key：move = nil or key:dist = nil")
                }
            }
            catch {
                print(error)
            }
        })
        task.resume()
    }
    
    //http get request
    func getDangerStatus() {
        guard let url: URL = URL(string: "https://www.55g-jphacks2019.tk/push/move") else {return}
        let task: URLSessionTask  = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
                let articles = json.map { (article) -> [String: Any] in
                    return article as! [String: Any]
                }
                self.dangerData = articles
                print(self.dangerData)
            }
            catch {
                print(error)
            }
        })
        task.resume()
    }
    
    //タイムスタンプを日時文字列に変換
    func timeStampToDate(timestamp: Double, type: Int) -> String {
        // UNIX時間 "dateUnix" をNSDate型 "date" に変換
        let dateUnix: TimeInterval = timestamp
        let date = NSDate(timeIntervalSince1970: dateUnix)

        // NSDate型を日時文字列に変換するためのNSDateFormatterを生成
        let formatter = DateFormatter()
        if type == 1 {
            formatter.dateFormat = "yyyy年M月d日 HH:mm:ss"
        } else if type == 2 {
            formatter.dateFormat = "HH:mm:ss"
        }

        // NSDateFormatterを使ってNSDate型 "date" を日時文字列 "dateStr" に変換
        let dateStr: String = formatter.string(from: date as Date)
        return dateStr
    }
    
    //危険度グラフ
    func drawGraph(_height: Int) {
        let heightValue = Int(_height * 380 / 100)
        dangerLevel.frame = CGRect(x: 70, y: 424 - heightValue, width: 46, height: heightValue)
        
        let height = _height
        switch height {
        case 0 ..< 25:
            dangerLevel.backgroundColor = UIColor.green
        case 25 ..< 50:
            dangerLevel.backgroundColor = UIColor.yellow
        case 50 ..< 75:
            dangerLevel.backgroundColor = UIColor.orange
        case 75 ... 100:
            dangerLevel.backgroundColor = UIColor.red
        default:
            dangerLevel.backgroundColor = UIColor.white
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dangerTimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        // Tag番号 1 で UIImageView インスタンスの生成
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        // Tag番号 ２ で UILabel インスタンスの生成
        let label1 = cell.viewWithTag(2) as! UILabel
        label1.text = dangerTimes[indexPath.row]
        //label1.text = (dangerData[]["timestamp"] as! String)

        //performSegue(withIdentifier: "detail", sender: nil)
        // Tag番号 3 で UILabel インスタンスの生成
        let label2 = cell.viewWithTag(3) as! UILabel
        print(dangerMove[indexPath.row])
        
        if dangerMove[indexPath.row] > 80 {
            label2.text = "大きな揺れ"
            label2.textColor = UIColor.red
            imageView.image = UIImage(named: "danger1")
        } else {
            label2.text = "小さな揺れ"
            label2.textColor = UIColor.orange
            imageView.image = UIImage(named: "danger2")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップされたセルの行番号を出力
        print("\(indexPath.row)番目の行が選択されました。")
        selectedTime = dangerTimes[indexPath.row]
        selectedTimestamp = String(dangerData[indexPath.row]["timestamp"] as! NSString)
        selectedMove = dangerMove[indexPath.row]
        print(selectedTime as Any)
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        //segueを使用して画面遷移
        performSegue(withIdentifier: "detail", sender: nil)
        
    }
    /// セグエ実行前処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let nextVC = segue.destination as! SensorDetailViewController
            nextVC.dangerTime = selectedTime!
            nextVC.dangerMove = selectedMove!
            nextVC.dangerTimestamp = selectedTimestamp!
        }
    }
    
    func timer(){
        // タイマーを作る
        runAnimation = Timer.scheduledTimer(
            timeInterval: 0.1, // 繰り返す間隔（秒）
            target: self,
            selector: #selector(self.step), // 実行するメソッド
            userInfo: nil,
            repeats: true // リピート再生する
        )
        //タブバーのスクロール中にアニメーションが止まるので別スレッドで泥棒のアニメーションを行う
        RunLoop.current.add(runAnimation!, forMode: RunLoop.Mode.common)
    }
    // タイマーから定期的に呼び出されるメソッド
    @objc func step() {
        // 水平方向へ移動
        bag.center.x += 10
        husinsha.center.x += 10

        let husinshaWidth = husinsha.bounds.width
        if husinsha.center.x>(view.bounds.width + husinshaWidth/2) {
            // 左辺の手前に戻す
            bag.center.x = CGFloat(107)
            // y 座標はランダムな高さに変更
            bag.center.y = CGFloat(371)
            // 左辺の手前に戻す
            husinsha.center.x = CGFloat(52)
            // y 座標はランダムな高さに変更
            husinsha.center.y = CGFloat(327)
        }
    }
    
    //揺れ検知履歴のリセットボタン
    //ボタンを押すとアラートを表示　-> 削除 -> 揺れ検知履歴がリセット -> 安全状態に戻る
    @IBAction func resetTime(_ sender: Any) {
        // アラートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "リセット"
        alert.message = "安全状態に戻します。荷物の安全を確認後、リセットボタンを押してください。"
        // 赤色のボタン
        alert.addAction(
            UIAlertAction(
                title: "リセット",
                style: .destructive,
                handler: {(action) -> Void in
                    self.resetTableView(action.title!)
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
    func resetTableView(_ msg:String) {
        print(msg)
        resetButton.isEnabled = false // ボタン無効
        resetButton.setTitleColor(.lightGray, for: .normal)
        move = 10
        dist = 0
        dangerFlag = 0
        //self.dangerTimes = []
        //self.tableView.reloadData()
        self.timestamp.text = "安全です"
        self.timestamp.backgroundColor = UIColor.systemTeal
        self.timestamp.textColor = UIColor.white
        runAnimation?.invalidate()  //アニメーションストップ
        // 不審者を元の位置に戻す
        husinsha.center.x = CGFloat(52)
        husinsha.center.y = CGFloat(327)
        self.husinsha.isHidden = true   //不審者を非表示
        // カバンを元の位置に戻す
        bag.center.x = CGFloat(107)
        bag.center.y = CGFloat(371)
    }
}

