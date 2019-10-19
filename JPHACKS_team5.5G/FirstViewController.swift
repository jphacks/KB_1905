//
//  FirstViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //配列fruitsを設定
    var dangerTimes:[String] = []
      
    var sensorData: [String: Any]? = [:] //追加
    
    @IBOutlet weak var timestamp: UITextField!
    
//    @IBOutlet weak var tableBag: UIImageView!
    @IBOutlet weak var bag: UIImageView!
    @IBOutlet weak var husinsha: UIImageView!
    
    @IBOutlet weak var dangerLevel: UILabel!
    @IBOutlet weak var border: UILabel!
    
  
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // create the url-request
        //getSensorStatus()
        //
        tableView.dataSource = self
        tableView.delegate = self

        border.layer.borderColor = UIColor.black.cgColor
        //ボーダー色（白）
        border.layer.borderWidth = 2.0;
        border.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)

//        // 再生するイメージの配列を設定する
//        tableBag.animationImages = tableBagImages()
//         // 無限ループ再生に設定する
//        tableBag.animationRepeatCount = 0
//        // 再生にかかる秒数を設定する
//        tableBag.animationDuration = TimeInterval(1)
//        //アニメーションスタート
//        tableBag.startAnimating()
        let queue = OperationQueue()

        queue.addOperation() {
            // do something in the background
            var count = 0
            while(count < 10) {
                self.getSensorStatus()
                OperationQueue.main.addOperation() {
                    // when done, update your UI and/or model on the main queue
                    print(self.sensorData!)
                    self.drawGraph(_height: count)
                    //アニメーション
                    if count == 6 {
                        self.timer()
                        let timestamp = (self.sensorData!["timestamp"] as! NSString).doubleValue
                        self.timestamp.text = "危険な状態"
                        self.timestamp.backgroundColor = UIColor.red
                        self.timestamp.textColor = UIColor.black
                        self.husinsha.image = UIImage(named: "husinsha")
                        self.dangerTimes.append(self.timeStampToDate(timestamp: timestamp))
                        self.tableView.reloadData()
                    }else if count > 6 {
                        let timestamp = (self.sensorData!["timestamp"] as! NSString).doubleValue
                        self.dangerTimes.append(self.timeStampToDate(timestamp: timestamp))
                        self.tableView.reloadData()
                    }
                }
                count += 1
            }
        }
    }
    
//    // コマ送りのイメージの配列を作る
//    func tableBagImages () -> Array<UIImage> {
//        var theArray = Array<UIImage>()
//        for num in 1...2 {
//            // jogboy_1〜jogboy_10のイメージを作る
//            let imageName = "table_bag" + String(num)
//            let image = UIImage(named: imageName)
//            // 配列に追加する
//            theArray.append(image!)
//        }
//        return theArray
//    }
    
    
    //http get request
    func getSensorStatus() {
        let url: URL = URL(string: "https://www.55g-jphacks2019.tk/sensors")!
        let task: URLSessionTask  = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                self.sensorData = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                print(self.sensorData!)
                //print("count: \(self.sensorData!["gyro_X"]!)")
            }
            catch {
                print(error)
            }
        })
        task.resume()
        sleep(2)
    }
    
    //タイムスタンプを日時文字列に変換
    func timeStampToDate(timestamp: Double) -> String {
        // UNIX時間 "dateUnix" をNSDate型 "date" に変換
        let dateUnix: TimeInterval = timestamp
        let date = NSDate(timeIntervalSince1970: dateUnix)

        // NSDate型を日時文字列に変換するためのNSDateFormatterを生成
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // NSDateFormatterを使ってNSDate型 "date" を日時文字列 "dateStr" に変換
        let dateStr: String = formatter.string(from: date as Date)
        return dateStr
    }
    
    //危険度グラフ
    func drawGraph(_height: Int) {
        dangerLevel.frame = CGRect(x: 70, y: 480 - _height * 40, width: 40, height: _height * 40)
        
        let height = _height * 10
        switch height {
        case 0 ..< 25:
            dangerLevel.backgroundColor = UIColor.green
        case 0 ..< 50:
            dangerLevel.backgroundColor = UIColor.yellow
        case 0 ..< 75:
            dangerLevel.backgroundColor = UIColor.orange
        case 0 ... 100:
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
        imageView.image = UIImage(named: "danger1")
        
        // Tag番号 ２ で UILabel インスタンスの生成
         let label1 = cell.viewWithTag(2) as! UILabel
         label1.text = dangerTimes[indexPath.row]
        
        // Tag番号 3 で UILabel インスタンスの生成
         let label2 = cell.viewWithTag(3) as! UILabel
         label2.text = "大きな揺れ"
        
        return cell
    }
    
    
    func timer(){
        // タイマーを作る
        Timer.scheduledTimer(
            timeInterval: 0.1, // 繰り返す間隔（秒）
            target: self,
            selector: #selector(self.step), // 実行するメソッド
            userInfo: nil,
            repeats: true // リピート再生する
        )
    }
    // タイマーから定期的に呼び出されるメソッド
    @objc func step() {
        // 水平方向へ移動
        bag.center.x += 10
        husinsha.center.x += 10
        // 右辺から外へ出たら
        //let bagWidth = bag.bounds.width
//        if bag.center.x>(view.bounds.width + bagWidth/2) {
//
//        }
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
    
    
}

