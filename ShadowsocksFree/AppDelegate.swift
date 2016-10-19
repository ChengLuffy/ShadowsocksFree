//
//  AppDelegate.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/5/3.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if (UserDefaults.standard.value(forKey: "isFirstOpen") == nil) {
            print("is")
            
            let arr = ["namahoO8K", "namaho5FY", "namahoIKF"]
            
            var i = 0
            
            while i < 6 {
                let model = Model()
                if i < 3 {
                    model.adress = "\(i)服务器地址:jp01.namaho.com"
                    model.port = "端口:\(8497 + i)"
                    model.passWord = "密码:" + arr[i]
                    model.name = "namahoJP\(i)"
                } else {
                    model.adress = "\(i - 3)服务器地址:us02.namaho.com"
                    model.port = "端口:\(8497 + i - 3)"
                    model.passWord = "密码:" + arr[i - 3]
                    model.name = "namahoUS\(i - 3)"
                }
                model.encryption = "加密方式:aes-256-cfb"
                model.isNet = false
                i += 1
                try! realm.write({
                    realm.add(model, update: true)
                })
            }
            UserDefaults.standard.set(false, forKey: "isFirstOpen")
        }
        
       
        
        if launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] != nil {
             let shortcutItem = launchOptions![UIApplicationLaunchOptionsKey.shortcutItem] as! UIApplicationShortcutItem
            pushVCWith(shortcutItem.type)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        print(url.query)
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let itemType = shortcutItem.type
        pushVCWith(itemType)
        completionHandler(true)
    }

    func pushVCWith(_ type: String) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
        self.window?.rootViewController = nav
        switch type {
        case "home":
            break
        case "scan":
            let scanVC = storyboard.instantiateViewController(withIdentifier: "scan")
            nav.pushViewController(scanVC, animated: true)
            break
        default:
            let qrVC = storyboard.instantiateViewController(withIdentifier: "watch")
            nav.present(qrVC, animated: true, completion: nil)
        }
        
    }
    
}

