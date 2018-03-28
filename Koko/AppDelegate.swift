//
//  AppDelegate.swift
//  Koko
//
//  Created by 青木佑弥 on 2017/10/30.
//  Copyright © 2017年 青木佑弥. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //TOPViewControllerのメソッドも呼び出せるようにする
    //var viewController: ViewController!
    //UserDefaultを作成
    let userDefault = UserDefaults.standard
    
    var firstLaunchFlag: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //フォアグラウンドでも通知をする
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        
        // "firstLaunch"に紐づく値がtrueなら(=初回起動)、値をfalseに更新して処理を行う
        if userDefault.object(forKey: "firstLaunchFlag") != nil {
            userDefault.set(true, forKey: "firstLaunchFlag")
            firstLaunchFlag = true
        }
        
        
        userDefault.synchronize()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        userDefault.synchronize()
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        userDefault.synchronize()
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.viewController.sendVisitData()
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        userDefault.synchronize()
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // アプリ起動中でもアラート&音で通知
        print("通知を受けとりました")
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

