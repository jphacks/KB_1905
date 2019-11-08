//
//  SecondViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SecondViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    //map
    @IBOutlet weak var myMap: MKMapView!
    //トラッキングボタン
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    
    //位置情報利用許可を得る処理
    var locationManager:  CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        //ボタンの設定
        backgroundButton.backgroundColor = .systemGroupedBackground
        backgroundButton.layer.cornerRadius = 25
        backgroundButton.layer.shadowOpacity = 0.3
        backgroundButton.layer.shadowRadius = 12
        backgroundButton.layer.shadowColor = UIColor.black.cgColor
        backgroundButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        // Do any additional setup after loading the view.
        setupLocationManager()
        //アプリ利用中の位置情報の利用許可を得る
        locationManager.requestWhenInUseAuthorization()
        
        //ボタンの初期画像設定
        trackingButton.setImage(UIImage.init(named: "trackingNone"), for: UIControl.State.normal)
        // ロケーションマネージャのデリゲートになる
        locationManager.delegate = self
        // myMapのデリゲートになる
        myMap.delegate = self
        // スケールを表示する
        myMap.showsScale = true
    }
    
    @IBAction func tapTrackingButton(_ sender: UIButton) {
        switch myMap.userTrackingMode {
        case .none:
            // noneからfollowへ
            myMap.setUserTrackingMode(.follow, animated: true)
            // トラッキングボタンを変更する
            trackingButton.setImage(UIImage.init(named: "trackingFollow"), for: UIControl.State.normal)
            //trackingButton.image = UIImage(named: "trackingFollow")
        case .follow:
            // followからfollowWithHeadingへ
            myMap.setUserTrackingMode(.followWithHeading, animated: true)
            // トラッキングボタンを変更する
            trackingButton.setImage(UIImage.init(named: "trackingHeading"), for: UIControl.State.normal)
            //trackingButton.image = UIImage(named: "trackingHeading")
        case .followWithHeading:
            // followWithHeadingからnoneへ
            myMap.setUserTrackingMode(.none, animated: true)
            // トラッキングボタンを変更する
            trackingButton.setImage(UIImage.init(named: "trackingNone"), for: UIControl.State.normal)
            //trackingButton.image = UIImage(named: "trackingNone")
        }
    }
    

    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()
    }
    
    // トラッキングが自動解除された
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        // トラッキングボタンを変更する
        trackingButton.setImage(UIImage.init(named: "trackingNone"), for: UIControl.State.normal)
    }
    
    // 位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            // ロケーションの更新を開始する
            locationManager.startUpdatingLocation()
            // トラッキングボタンを有効にする
            trackingButton.isEnabled = true
        default:
            // ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            // トラッキングモードをnoneにする
            myMap.setUserTrackingMode(.none, animated: true)
            //トラッキングボタンを変更する
            trackingButton.setImage(UIImage.init(named: "trackingNone"), for: UIControl.State.normal)
            // トラッキングボタンを無効にする
            trackingButton.isEnabled = false
        }
    }
    
    //位置情報取得に失敗したときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error akanda")
    }
}

