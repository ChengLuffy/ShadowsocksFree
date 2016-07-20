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
import IBAnimatable
import MJRefresh

class ViewController: UIViewController {
    var titles = [String]()
//    var refreshControl: UIRefreshControl?
    var popoverView: Popover?
    var isDelete: Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        /*
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ViewController.getData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
         */
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(ViewController.getData))
        /*
        self.tableView.mj_footer = MJRefreshAutoStateFooter.init(refreshingBlock: {
            print("footer")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { 
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            })
        })
         */
        
        self.title = "ShadowsocksFree"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.mj_header.beginRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        tableView.updateFocusIfNeeded()
        let URLStr = "http://www.ishadowsocks.net/"
        
        Alamofire.request(.GET, URLStr).responseData { (respose) in
            
            if respose.result.error == nil {
                print(respose.data?.length)
                
                let html = NSString.init(data: respose.data!, encoding: NSUTF8StringEncoding)
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
                                model.isNet = true
                            }
                            let realm = try! Realm()
                            try! realm.write({
                                realm.add(model, update: true)
                            })
                        }
                        self.tableView.reloadData()
                        self.tableView.mj_header.endRefreshing()
                    } else {
                        print("nil")
                    }
                    
                } catch let error  {
                    print(error)
                }
            } else {
                print(respose.result.error)
                self.tableView.mj_header.endRefreshing()
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

    @IBAction func QRItemDidClicked(sender: AnyObject) {
        let point = CGPoint(x: UIScreen.mainScreen().bounds.size.width - 23, y: 50)
        let options = [.AnimationIn(0.25), .AnimationOut(0.25), .ArrowSize(CGSize(width: 15, height: 20)), PopoverOption.CornerRadius(10), .Type(PopoverType.Down)] as [PopoverOption]
        popoverView = Popover.init(options: options, showHandler: {
            print("show")
        }) {
            print("dismiss")
        }
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        subView.backgroundColor = UIColor.blueColor()
        
        let scanBtn = UIButton.init(type: .System)
        scanBtn.setTitle("扫描", forState: .Normal)
        scanBtn.addTarget(self, action: #selector(ViewController.scanBtnDidClicked(_:)), forControlEvents: .TouchUpInside)
        scanBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        subView.addSubview(scanBtn)
        
        let watchBtn = UIButton.init(type: .System)
        watchBtn.setTitle("查看", forState: .Normal)
        watchBtn.addTarget(self, action: #selector(ViewController.watchBtnDidClicked(_:)), forControlEvents: .TouchUpInside)
        watchBtn.frame = CGRect(x: 0, y: 40, width: 100, height: 40)
        subView.addSubview(watchBtn)
        
        popoverView!.show(subView, point: point)
    }
    
    @IBAction func addItemDidClicked(sender: AnyObject) {
        
        let point = CGPoint(x: 25, y: 50)
        let options = [.AnimationIn(0.25), .AnimationOut(0.25), .ArrowSize(CGSize(width: 15, height: 20)), PopoverOption.CornerRadius(10), .Type(PopoverType.Down)] as [PopoverOption]
        popoverView = Popover.init(options: options, showHandler: {
            print("show")
        }) {
            print("dismiss")
        }
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        subView.backgroundColor = UIColor.blueColor()
        
        let addButon = UIButton.init(type: .System)
        addButon.setTitle("添加", forState: .Normal)
        addButon.addTarget(self, action: #selector(ViewController.addBtnClicked(_:)), forControlEvents: .TouchUpInside)
        addButon.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        subView.addSubview(addButon)
        
        let deleteButton = UIButton.init(type: .System)
        if isDelete == true {
            deleteButton.setTitle("完成", forState: .Normal)
        } else {
            deleteButton.setTitle("删除", forState: .Normal)
        }
        deleteButton.addTarget(self, action: #selector(ViewController.deleteBtnDidClicked(_:)), forControlEvents: .TouchUpInside)
        deleteButton.frame = CGRect(x: 0, y: 40, width: 100, height: 40)
        deleteButton.tag = 10
        subView.addSubview(deleteButton)

        popoverView!.show(subView, point: point)
        
    }
    
    func deleteBtnDidClicked(sender: AnyObject) {
        popoverView!.dismiss()
        
        if isDelete == false {
            isDelete = true
            tableView.setEditing(true, animated: true)
        } else {
            isDelete = false
            tableView.setEditing(false, animated: true)
        }
        
        tableView.reloadData()
    }
    
    func addBtnClicked(sender: AnyObject) {
        popoverView!.dismiss()
        let addInfoVC = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("add")
        addInfoVC.transitioningDelegate = PresenterManager.sharedManager().retrievePresenter(.Fold(fromDirection: .Right, params: [""]), transitionDuration: 0.5, interactiveGestureType: .Pan(fromDirection: .Left))
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.presentViewController(addInfoVC, animated: true, completion: nil)
        })
    }
    
    func scanBtnDidClicked(sender: AnyObject) {
        popoverView!.dismiss()
        let QRVC = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("scan")
        QRVC.transitioningDelegate = PresenterManager.sharedManager().retrievePresenter(.Portal(direction: .Forward, params: [""]), transitionDuration: 0.5, interactiveGestureType: .Pinch(direction: .Close))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.presentViewController(QRVC, animated: true, completion: nil)
        })
    }
    
    func watchBtnDidClicked(sender: AnyObject) {
        popoverView!.dismiss()
        let QRVC = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("watch")
        QRVC.transitioningDelegate = PresenterManager.sharedManager().retrievePresenter(.Explode(params: [""]), transitionDuration: 0.5, interactiveGestureType: .Pan(fromDirection: .Left))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.presentViewController(QRVC, animated: true, completion: nil)
        })
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if isDelete == true {
            return 1
        } else {
            let realm = try! Realm()
            return realm.objects(Model).count
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDelete == false {
            return 4
        } else {
            let realm = try! Realm()
            return realm.objects(Model).filter("isNet = false").count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isDelete == false {
            let realm = try! Realm()
            return realm.objects(Model)[section].name
        } else {
            return "自定义节点信息列表"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let str = self.getValueForNum(indexPath.row + 1)
        let realm = try! Realm()
        var model = Model()
        if isDelete == false {
            model = realm.objects(Model)[indexPath.section]
            cell.textLabel?.text = model.valueForKey(str) as? String
        } else {
            model = realm.objects(Model).filter("isNet = false")[indexPath.row]
            cell.textLabel?.text = model.adress
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let pboard = UIPasteboard.generalPasteboard()
            let realm = try! Realm()
            let str = getValueForNum(indexPath.row + 1)
            let temp = realm.objects(Model)[indexPath.section].valueForKey(str)!.componentsSeparatedByString(":")
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            print("delete")
            let realm = try! Realm()
            let model = realm.objects(Model).filter("isNet = false")[indexPath.row]
            try! realm.write({
                realm.delete(model)
            })
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return isDelete
    }
    
}