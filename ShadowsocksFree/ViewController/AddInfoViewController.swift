//
//  AddInfoViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AddInfoViewController:  UIViewController {
    
    var refreshHandle: (() -> ())?
    var popUpTextView: PopUpViewTextView?
    var currentEditingY: CGFloat?
    lazy var titleArr = ["服务器地址", "端口", "密码", "加密方式", "备注"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "TFTag"), object: nil, queue: nil) { (notification) in
            let tf = notification.object as! UITextField
            self.currentEditingY = tf.convert(tf.frame,to: self.view).maxY
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (_) in
            self.popUpTextView?.center = self.view.center
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddInfoViewController.keyBoardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        popUpTextView = PopUpViewTextView.init(frame: CGRect(x: 0, y: 0, width: 330, height: 400))
        popUpTextView?.center = self.view.center
        popUpTextView!.layer.cornerRadius = 10
        popUpTextView!.layer.shadowColor = UIColor.black.cgColor
        popUpTextView!.layer.shadowOffset = CGSize(width: 2, height: 2)
        popUpTextView!.layer.shadowRadius = 10
        popUpTextView!.layer.shadowOpacity = 10
        self.view.addSubview(popUpTextView!)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyBoardShow(_ notification: Notification) {
//        let point = ((notification as NSNotification).userInfo!["UIKeyboardCenterEndUserInfoKey"] as AnyObject).cgPointValue
//        let keys = notification.userInfo?.keys
//        print(keys)
        let pointV = notification.userInfo!["UIKeyboardCenterEndUserInfoKey"] as! NSValue
        let point = pointV.cgPointValue
        if currentEditingY! + 20 > point.y {
            self.popUpTextView?.center.y = (self.popUpTextView?.center.y)! - self.currentEditingY! + 80 - point.y
        }
    }

    @IBAction func dimisisVC(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func DoneBtnClicked(_ sender: AnyObject) {
        
        let model = Model()
        let adress = (self.popUpTextView!.viewWithTag(1) as! UITextField).text!.characters.count > 0 ? (self.popUpTextView!.viewWithTag(1) as! UITextField).text! : "nil"
        model.adress =  "服务器地址:" + adress
        model.port = "端口:" + (self.popUpTextView!.viewWithTag(2) as! UITextField).text!
        model.passWord = "密码:" + (self.popUpTextView!.viewWithTag(3) as! UITextField).text!
        model.encryption = "加密方式:" + (self.popUpTextView!.viewWithTag(4) as! UITextField).text!
        model.name = (self.popUpTextView!.viewWithTag(5) as! UITextField).text!.characters.count > 0 ? (self.popUpTextView!.viewWithTag(5) as! UITextField).text : "custom"
        model.isNet = false
        
        if model.adress?.characters.count < 10 {
            self.alertMSG("服务器地址输入有误", tag: 1)
        } else if model.port?.characters.count < 6 {
            self.alertMSG("端口输入有误", tag: 2)
        } else if model.encryption?.characters.count < 8 {
            self.alertMSG("加密方式输入有误", tag: 4)
        } else {
            let realm = try! Realm()
            try! realm.write({
                realm.add(model, update: true)
            })
            self.view.endEditing(false)
            weak var weakSelf = self
            self.dismiss(animated: true, completion: {
                weakSelf?.refreshHandle!()
            })
        }
        
    }
    
    func alertMSG(_ msg: String, tag: Int) {
        let alertVC = UIAlertController.init(title: "错误提示", message: msg, preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "确定", style: .cancel) { (_) in
            let tf = self.popUpTextView?.viewWithTag(tag) as! UITextField
            tf.becomeFirstResponder()
        }
        alertVC.addAction(sureAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
