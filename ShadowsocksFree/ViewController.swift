//
//  ViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/5/3.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import Alamofire
import Fuzi
import RealmSwift

class ViewController: UIViewController {
    var titles = [String]()
    var refreshControl: UIRefreshControl?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ViewController.getData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.title = "ShadowsocksFree"
        self.getData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        self.refreshControl?.beginRefreshing()
        let URLStr = "http://www.ishadowsocks.net/"
        
        Alamofire.request(.GET, URLStr).responseData { (respose) in
            
            if respose.result.error == nil {
                let html = NSString.init(data: respose.data!, encoding: NSUTF8StringEncoding)
                try! realm.sharedInstance.write({
                    realm.sharedInstance.deleteAll()
                })
                do {
                    let doc = try HTMLDocument(string: html as! String, encoding: NSUTF8StringEncoding)
                    if var free = doc.xpath("//section")[2]?.children(tag: "div")[0].children(tag: "div") {
                        free.removeFirst()
                        for node in free[0].children(tag: "div") {
                            let model = Model()
                            
                            for (index, sub) in node.children(tag: "h4").enumerate() {
                                
                                switch index {
                                case 0: model.adress = sub.stringValue
                                case 1: model.port = sub.stringValue
                                case 2: model.passWord = sub.stringValue
                                case 3: model.encryption = sub.stringValue
                                case 4: model.stutas = sub.stringValue
                                default :
                                    break
                                }
                                
                            }
                            
                            try! realm.sharedInstance.write({
                                realm.sharedInstance.add(model)
                            })
                        }
                        self.tableView.reloadData()
                        self.refreshControl!.endRefreshing()
                    } else {
                        print("nil")
                    }
                    
                } catch let error  {
                    print(error)
                }
                
                
            }
        }

    }
    
    func getValueForNum(num: Int) -> String {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(Model.self, &count)
        let str = String.fromCString(property_getName(properties[num]))!
        free(properties)
        return str
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return realm.sharedInstance.objects(Model).count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return realm.sharedInstance.objects(Model)[section].name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let str = self.getValueForNum(indexPath.row + 1)
        let model = realm.sharedInstance.objects(Model)[indexPath.section]
        cell.textLabel?.text = model.valueForKey(str) as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let pboard = UIPasteboard.generalPasteboard()
            let str = getValueForNum(indexPath.row + 1)
            let temp = realm.sharedInstance.objects(Model)[indexPath.section].valueForKey(str)!.componentsSeparatedByString(":")
            pboard.string = temp[1]
            let alertVC = UIAlertController.init(title: temp[0] + "已成功复制", message: "", preferredStyle: .Alert)
            weak var weakSelf = self
            self.presentViewController(alertVC, animated: true) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    weakSelf!.dismissViewControllerAnimated(true, completion: {
                        weakSelf!.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    })
                })
            }
        }
    }
    
}