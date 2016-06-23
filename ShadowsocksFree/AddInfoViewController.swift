//
//  AddInfoViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit


class AddInfoViewController:  UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var titleArr = ["服务器地址", "端口", "密码", "加密方式", "备注"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib.init(nibName: "AddInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        NSNotificationCenter.defaultCenter().addObserverForName("done", object: nil, queue: nil) { (notification) in
            
            let model = Model()
            model.adress =  "服务器地址:" + (self.view.viewWithTag(10) as! UITextField).text!
            model.port = "端口:" + (self.view.viewWithTag(11) as! UITextField).text!
            model.passWord = "密码:" + (self.view.viewWithTag(12) as! UITextField).text!
            model.encryption = "加密方式:" + (self.view.viewWithTag(13) as! UITextField).text!
            model.name = (self.view.viewWithTag(14) as! UITextField).text!.characters.count > 0 ? (self.view.viewWithTag(14) as! UITextField).text : "custom"
            model.isNet = false
            
            try! realm.sharedInstance.write({ 
                realm.sharedInstance.add(model)
            })
            print(realm.sharedInstance.objects(Model).endIndex)
            self.view.endEditing(false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)  as! AddInfoTableViewCell
        cell.titleLabel.text = titleArr[indexPath.row]
        cell.textField.tag = indexPath.row + 10
        weak var weakView = view
        cell.view = weakView
        if indexPath.row == 4 {
            cell.textField.placeholder = "选填"
            cell.textField.returnKeyType = .Done
            cell.textField.keyboardType = .Default
        } else {
            cell.textField.placeholder = "必填"
            cell.textField.keyboardType = .ASCIICapable
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.view.endEditing(true)
    }
}
