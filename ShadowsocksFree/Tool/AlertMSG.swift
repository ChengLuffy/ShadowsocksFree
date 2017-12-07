//
//  AlertMSG.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/12/6.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit

class AlertMSG {
    class func alert(title: String, msg: String, actions: [UIAlertAction]) {
        let alertVC = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        for action in actions {
            alertVC.addAction(action)
        }
        let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        let vc = AlertMSG.getCurrentVCFrom(viewcontroller: rootVC!)
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    class func alert(title: String, msg: String, delay: Double) {
        let alertVC = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        let vc = AlertMSG.getCurrentVCFrom(viewcontroller: rootVC!)
        weak var weadSelf = vc
        vc.present(alertVC, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                weadSelf!.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    class func alert(title: String, msg: String, completion: (() -> Swift.Void)? = nil) {
        let alertVC = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        let vc = AlertMSG.getCurrentVCFrom(viewcontroller: rootVC!)
        vc.present(alertVC, animated: true, completion: completion)
    }
    
    private class func getCurrentVCFrom(viewcontroller: UIViewController) -> UIViewController {
        var currentVC: UIViewController
        if viewcontroller.presentedViewController != nil  {
            currentVC = (viewcontroller.presentedViewController)!
        }
        
        if (viewcontroller.isKind(of: UITabBarController.self)) {
            currentVC = AlertMSG.getCurrentVCFrom(viewcontroller: (viewcontroller as! UITabBarController).selectedViewController!)
            
        } else if (viewcontroller.isKind(of: UINavigationController.self)) {
            currentVC = AlertMSG.getCurrentVCFrom(viewcontroller: (viewcontroller as! UINavigationController).visibleViewController!)
        } else {
            currentVC = viewcontroller
        }
        return currentVC
    }
}
