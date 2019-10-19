//
//  MyTabBarController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/19.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Thirdタブだったときバッジを消す
        if item.title == "センサー" {
            item.badgeValue = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3番目のタブにバッジ"New"を付ける
        let tabBartItem = tabBar.items?[0]
        tabBartItem?.badgeValue = "!"
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
