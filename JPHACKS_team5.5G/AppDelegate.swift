//
//  AppDelegate.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/10/17.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ① プッシュ通知の利用許可のリクエスト送信
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }

            DispatchQueue.main.async {
                // ② プッシュ通知利用の登録
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        sleep(2)//add

        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {

    // ③ プッシュ通知の利用登録が成功した場合
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("Device token: \(token)")
        
        guard let url = URL(string: "https://www.55g-jphacks2019.tk/users") else {return}
         var request = URLRequest(url: url)
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         // POSTを指定
         request.httpMethod = "POST"
         
         let params: [String: String] = [
            "name":"akada",
            "deviceToken": token
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

    // ④ プッシュ通知の利用登録が失敗した場合
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register to APNs: \(error)")
    }
}
