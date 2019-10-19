//
//  FirstViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var sensorData: [String: Any]? = [:] //追加
    
    @IBOutlet weak var timestamp: UITextField!
    
    @IBOutlet weak var tableBag: UIImageView!
    
    @IBOutlet weak var dangerLevel: UILabel!
    @IBOutlet weak var border: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // create the url-request
        //getSensorStatus()
        //
        border.layer.borderColor = UIColor.black.cgColor
        //ボーダー色（白）
        border.layer.borderWidth = 2.0;
        border.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)


        // 再生するイメージの配列を設定する
        tableBag.animationImages = tableBagImages()
         // 無限ループ再生に設定する
        tableBag.animationRepeatCount = 0
        // 再生にかかる秒数を設定する
        tableBag.animationDuration = TimeInterval(1)
        //アニメーションスタート
        tableBag.startAnimating()
        let queue = OperationQueue()

        queue.addOperation() {
            // do something in the background
            var count = 0
            while(count < 10) {
                self.getSensorStatus()
                OperationQueue.main.addOperation() {
                    // when done, update your UI and/or model on the main queue
                    print(self.sensorData!)
                    let timestamp = (self.sensorData!["timestamp"] as! NSString).doubleValue
                    self.timestamp.text = self.timeStampToDate(timestamp: timestamp)
                    self.drawGraph(_height: count)
                }
                count += 1
            }
        }
    }
    
    // コマ送りのイメージの配列を作る
    func tableBagImages () -> Array<UIImage> {
        var theArray = Array<UIImage>()
        for num in 1...2 {
            // jogboy_1〜jogboy_10のイメージを作る
            let imageName = "table_bag" + String(num)
            let image = UIImage(named: imageName)
            // 配列に追加する
            theArray.append(image!)
        }
        return theArray
    }
    
    
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
}

