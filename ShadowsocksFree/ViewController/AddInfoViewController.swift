//
//  AddInfoViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

class AddInfoViewController:  UIViewController {
    
    var refreshHandle: (() -> ())?
    var popUpTextView: PopUpViewTextView?
    var currentEditingY: CGFloat?
    lazy var titleArr = ["服务器地址", "端口", "密码", "加密方式", "备注"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName("TFTag", object: nil, queue: nil) { (notification) in
            let tf = notification.object as! UITextField
            self.currentEditingY = tf.convertRect(tf.frame,toView: self.view).maxY
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (_) in
            self.popUpTextView?.center = self.view.center
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddInfoViewController.keyBoardShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        popUpTextView = PopUpViewTextView.init(frame: CGRect(x: 0, y: 0, width: 330, height: 400))
        popUpTextView?.center = self.view.center
        popUpTextView!.layer.cornerRadius = 10
        popUpTextView!.layer.shadowColor = UIColor.blackColor().CGColor
        popUpTextView!.layer.shadowOffset = CGSizeMake(2, 2)
        popUpTextView!.layer.shadowRadius = 10
        popUpTextView!.layer.shadowOpacity = 10
        self.view.addSubview(popUpTextView!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyBoardShow(notification: NSNotification) {
        let point = notification.userInfo!["UIKeyboardCenterEndUserInfoKey"]?.CGPointValue()
        if currentEditingY! + 20 > point?.y {
            self.popUpTextView?.center.y -= self.currentEditingY! + 80 - point!.y
        }
    }

    @IBAction func DoneBtnClicked(sender: AnyObject) {
        
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
            self.dismissViewControllerAnimated(true, completion: {
                weakSelf?.refreshHandle!()
            })
        }
        
    }
    
    func alertMSG(msg: String, tag: Int) {
        let alertVC = UIAlertController.init(title: "错误提示", message: msg, preferredStyle: .Alert)
        let sureAction = UIAlertAction.init(title: "确定", style: .Cancel) { (_) in
            let tf = self.popUpTextView?.viewWithTag(tag) as! UITextField
            tf.becomeFirstResponder()
        }
        alertVC.addAction(sureAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
