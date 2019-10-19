//
//  SettingViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit

// テーブルビューに表示するデータ
let sectionTitle = ["状態", "センサー"]
let section0 = ["異常検知", "Bluetooth接続", "通知"]
let section1 = ["ID salkdfalc0021klir"]
//let section2 = [("ハンミョウ","ハンミョウ科"),("アオオサムシ","オサムシ科"),("チビクワガタ","クワガタムシ科")]
let tableData = [section0, section1]

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // テーブルビューを作る
        let myTableView:UITableView!
        myTableView = UITableView(frame: view.frame, style: .grouped)
        // テーブルビューのデリゲートを設定する
        myTableView.delegate = self
        // テーブルビューのデータソースを設定する
        myTableView.dataSource = self
        // テーブルビューを表示する
        view.addSubview(myTableView)
    }
    
    /*　UITableViewDataSourceプロトコル */
    // セクションの個数を決める
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
  
    // セクションごとの行数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = tableData[section]
        return sectionData.count
    }

    // セクションのタイトルを決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }

    // セルを作る
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let sectionData = tableData[(indexPath as NSIndexPath).section]
        let cellData = sectionData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = cellData
        //cell.detailTextLabel?.text = cellData.1

        // スイッチを追加
        if cell.accessoryView == nil && cellData != section1[0]{
            cell.accessoryView = UISwitch()    
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        }
        
        return cell
    }

    /* UITableViewDelegateデリゲートメソッド */
    // 行がタップされると実行される
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let title = sectionTitle[indexPath.section]
//        let sectionData = tableData[indexPath.section]
//        let cellData = sectionData[indexPath.row]
//        print("\(title)\(cellData.1)")
//        print("\(cellData.0)")
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
