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
import MJRefresh
import IBAnimatable

class ViewController: UIViewController {
    var titles = [String]()
//    var refreshControl: UIRefreshControl?
    var popoverView: Popover?
    var isDelete: Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        self.tableView.mj_header.beginRefreshing()
        self.title = "ShadowsocksFree"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.tableView.mj_header.beginRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getData() {
        tableView.updateFocusIfNeeded()
        let URLStr = "http://ss.ishadowx.com"
        
        var isNeedRequest: Bool?
        
        if self.tableView.mj_header.lastUpdatedTime != nil {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyyMMdd"
            
            let dateFormaterH = DateFormatter()
            dateFormaterH.dateFormat = "HH"
            
            let date = self.tableView.mj_header.lastUpdatedTime
            let lastDateStr = dateFormater.string(from: date!)
            let lastDateHStr = dateFormaterH.string(from: date!)
            
            let dateNow = Date()
            let dateNowStr = dateFormater.string(from: dateNow)
            let dateNowHStr = dateFormaterH.string(from: dateNow)
            print(lastDateStr, dateNowStr)
            print(lastDateHStr, dateNowHStr)
            
            isNeedRequest = Int(lastDateStr)! < Int(dateNowStr)! || Int(dateNowHStr)! / 6 > Int(lastDateHStr)! / 6
        } else {
            isNeedRequest = true
        }
        
        
        if isNeedRequest == true {
        
            Alamofire.request(URLStr).responseData { (respose) in
                
                if respose.result.error == nil {
                    print(respose.data?.count ?? "nil")
                    
                    let html = NSString.init(data: respose.data!, encoding: String.Encoding.utf8.rawValue)
                    do {
                        
                        try! realm.write({ 
                            realm.delete(realm.objects(Model.self).filter("server = 'ishadowsocks'"))
                        })
                        
                        let doc = try HTMLDocument(string: html! as String, encoding: String.Encoding.utf8)
                        let free = doc.xpath("//body")[0].children(tag: "div")[2].children(tag: "div")[1].children(tag: "div")[1].children(tag: "div")[0].children(tag: "div")
                        if free.count > 0 {
                            for node in free {
                                let model = Model()
                                
                                for (index, sub) in node.children(tag: "div")[0].children(tag: "div")[0].children(tag: "div")[0].children(tag: "h4").enumerated() {
                                    
                                    switch index {
                                    case 0: model.adress = "服务器地址:" + (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                    case 1: model.port = "端口地址:" + sub.stringValue.components(separatedBy: "：").last!
                                    case 2: model.passWord = "密码:" + (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                    case 3: model.encryption = "加密方式:" + sub.stringValue.components(separatedBy: ":").last!
//                                    case 4: model.name = sub.children[0].attr("title")
                                    default :
                                        break
                                    }
                                    model.isNet = true
                                    model.server = "ishadowsocks"
                                }
                                
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
                    print(respose.result.error ?? "nil")
                    self.tableView.mj_header.endRefreshing()
                }
            }
        } else {
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    func getValueForNum(_ num: Int) -> String {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(Model.self, &count)
        let str = String(cString: property_getName((properties?[num])!))
        free(properties)
        return str
    }

    @IBAction func QRItemDidClicked(_ sender: AnyObject) {
        let point = CGPoint(x: UIScreen.main.bounds.size.width - 23, y: 50)
        let options = [.animationIn(0.25), .animationOut(0.25), .arrowSize(CGSize(width: 15, height: 20)), PopoverOption.cornerRadius(10), .type(PopoverType.down)] as [PopoverOption]
        popoverView = Popover.init(options: options, showHandler: {
            print("show")
        }) {
            print("dismiss")
        }
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        subView.backgroundColor = UIColor.blue
        
        let scanBtn = UIButton.init(type: .system)
        scanBtn.setTitle("扫描", for: UIControlState())
        scanBtn.addTarget(self, action: #selector(ViewController.scanBtnDidClicked(_:)), for: .touchUpInside)
        scanBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        subView.addSubview(scanBtn)
        
        let watchBtn = UIButton.init(type: .system)
        watchBtn.setTitle("查看", for: UIControlState())
        watchBtn.addTarget(self, action: #selector(ViewController.watchBtnDidClicked(_:)), for: .touchUpInside)
        watchBtn.frame = CGRect(x: 0, y: 40, width: 100, height: 40)
        subView.addSubview(watchBtn)
        
        popoverView!.show(subView, point: point)
    }
    
    @IBAction func addItemDidClicked(_ sender: AnyObject) {
        
        let point = CGPoint(x: 25, y: 50)
        let options = [.animationIn(0.25), .animationOut(0.25), .arrowSize(CGSize(width: 15, height: 20)), PopoverOption.cornerRadius(10), .type(PopoverType.down)] as [PopoverOption]
        popoverView = Popover.init(options: options, showHandler: {
            print("show")
        }) {
            print("dismiss")
        }
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        subView.backgroundColor = UIColor.blue
        
        let addButon = UIButton.init(type: .system)
        addButon.setTitle("添加", for: UIControlState())
        addButon.addTarget(self, action: #selector(ViewController.addBtnClicked(_:)), for: .touchUpInside)
        addButon.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        subView.addSubview(addButon)
        
        let deleteButton = UIButton.init(type: .system)
        if isDelete == true {
            deleteButton.setTitle("完成", for: UIControlState())
        } else {
            deleteButton.setTitle("删除", for: UIControlState())
        }
        deleteButton.addTarget(self, action: #selector(ViewController.deleteBtnDidClicked(_:)), for: .touchUpInside)
        deleteButton.frame = CGRect(x: 0, y: 40, width: 100, height: 40)
        deleteButton.tag = 10
        subView.addSubview(deleteButton)

        popoverView!.show(subView, point: point)
        
    }
    
    @objc func deleteBtnDidClicked(_ sender: AnyObject) {
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
    
    @objc func addBtnClicked(_ sender: AnyObject) {
        popoverView!.dismiss()
        let addInfoVCNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "add") as! UINavigationController
        let addInfoVC = addInfoVCNav.viewControllers.first as! AddInfoViewController
        weak var weakSelf = self
        addInfoVC.refreshHandle = {
            weakSelf?.tableView.mj_header.beginRefreshing()
        }
        addInfoVCNav.transitioningDelegate = TransitionPresenterManager.shared.retrievePresenter(transitionAnimationType: .fold(from: .right, folds: 3), transitionDuration: 0.5, interactiveGestureType: .pan(from: .left))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.present(addInfoVCNav, animated: true, completion: nil)
        })
    }
    
    @objc func scanBtnDidClicked(_ sender: AnyObject) {
        popoverView!.dismiss()
        let QRVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "scan") as! QRScanViewController
        weak var weakSelf = self
        QRVC.refreshHandle = {
            weakSelf?.tableView.mj_header.beginRefreshing()
        }
        QRVC.transitioningDelegate = TransitionPresenterManager.shared.retrievePresenter(transitionAnimationType: .portal(direction: .forward, zoomScale: 0.618), transitionDuration: 0.5, interactiveGestureType: .pinch(direction: .close))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.present(QRVC, animated: true, completion: nil)
        })
    }
    
    @objc func watchBtnDidClicked(_ sender: AnyObject) {
        popoverView!.dismiss()
        let QRVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "watch")
        QRVC.transitioningDelegate = TransitionPresenterManager.shared.retrievePresenter(transitionAnimationType: .cards(direction: .backward), transitionDuration: 1, interactiveGestureType: .pan(from: .left))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.present(QRVC, animated: true, completion: nil)
        })
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isDelete == true {
            return 1
        } else {
            
            return realm.objects(Model.self).count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDelete == false {
            return 4
        } else {
            
            return realm.objects(Model.self).filter("isNet = false").count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isDelete == false {
            return realm.objects(Model.self)[section].name
        } else {
            return "自定义节点信息列表"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        var model = Model()
        if isDelete == false {
            let str = self.getValueForNum((indexPath as NSIndexPath).row + 1)
            model = realm.objects(Model.self)[(indexPath as NSIndexPath).section]
            cell.textLabel?.text = model.value(forKey: str) as? String
        } else {
            model = realm.objects(Model.self).filter("isNet = false")[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = model.adress
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 4 {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let pboard = UIPasteboard.general
            
            let str = getValueForNum((indexPath as NSIndexPath).row + 1)
            let temp = (realm.objects(Model.self)[(indexPath as NSIndexPath).section].value(forKey: str)! as AnyObject).components(separatedBy: ":")
            pboard.string = temp[1]
            let alertVC = UIAlertController.init(title: temp[0] + "已成功复制", message: "", preferredStyle: .alert)
            weak var weakSelf = self
            self.present(alertVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    weakSelf!.dismiss(animated: true, completion: {
                        weakSelf!.tableView.deselectRow(at: indexPath, animated: true)
                    })
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            
            let model = realm.objects(Model.self).filter("isNet = false")[(indexPath as NSIndexPath).row]
            try! realm.write({
                realm.delete(model)
            })
            print(model.isInvalidated)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isDelete
    }
    
}
