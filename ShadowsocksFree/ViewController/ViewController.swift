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
    var isDelete: Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        /*
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ViewController.getData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
         */
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(ViewController.getData))
        /*
        self.tableView.mj_footer = MJRefreshAutoStateFooter.init(refreshingBlock: {
            print("footer")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { 
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            })
        })
         */
        title = "ShadowsocksFree"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.tableView.mj_header.beginRefreshing()
        
        if tableView.mj_header.lastUpdatedTime != nil {
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
            
            if (Int(lastDateStr)! < Int(dateNowStr)! || Int(dateNowHStr)! / 6 > Int(lastDateHStr)! / 6) {
                tableView.mj_header.beginRefreshing()
            }
        } else {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getData() {
        tableView.updateFocusIfNeeded()
        // "https://go.ishadowx.net"
        var data: Data
        do {
            data = try Data.init(contentsOf: URL.init(string: "https://chengluffy.tech/ssf-host/host")!)
        } catch let error {
            print(error.localizedDescription)
            data = "https://go.ishadowx.net".data(using: .utf8)!
        }
        let URLStr = String.init(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
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
                                case 0: model.address = (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                case 1: model.port = sub.stringValue.components(separatedBy: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
                                case 2: model.passWord = (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                case 3: model.encryption = sub.stringValue.components(separatedBy: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
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
    }
    
    func getValueForNum(_ num: Int) -> String {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(Model.self, &count)
        let str = String(cString: property_getName((properties?[num])!))
        free(properties)
        return str
    }
    
    @IBAction func watchBtnDidClicked(_ sender: AnyObject) {
        let QRVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "watch")
        QRVC.transitioningDelegate = TransitionPresenterManager.shared.retrievePresenter(transitionAnimationType: .cards(direction: .backward), transitionDuration: 1, interactiveGestureType: .pan(from: .top))
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
        self.present(QRVC, animated: true, completion: nil)
//        })
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        weak var weakSelf = self
        let headerView = HeaderView(frame: CGRect.zero) { (section) in
            let model = realm.objects(Model.self)[section]
            let name = model.name
            let address = model.address
            let port = model.port
            let encryption = model.encryption
            let password = model.passWord
            let sheet = UIAlertController(title: "Copy with?", message: nil, preferredStyle: .actionSheet)
            let surgeStringAction = UIAlertAction(title: "Surge Proxy String", style: .default, handler: { (action) in
                let str = name! + " = custom, " + address! + ", " + port! + ", " + encryption! + ", " + password! + ", https://github.com/ChengLuffy/ShadowsocksFree/blob/new/SSEncrypt.module"
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                })
                let action = UIAlertAction(title: "Copy", style: .default, handler: { (_) in
                    let pboard = UIPasteboard.general
                    pboard.string = str
                })
                AlertMSG.alert(title: realm.objects(Model.self)[section].name!, msg: str, actions: [cancel, action])
            })
            let shadowsocksProxyString = UIAlertAction(title: "Shadowsocks Proxy String", style: .default, handler: { (action) in
                let temp: NSString = NSString.init(format: "\(encryption!):\(password!)@\(address!):\(port!)" as NSString)
                let temp1 = temp.base64EncodedString()
                let retStr = "ss://" + (temp1 as String)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                })
                let action = UIAlertAction(title: "Copy", style: .default, handler: { (_) in
                    let pboard = UIPasteboard.general
                    pboard.string = retStr
                })
                let open = UIAlertAction(title: "Open", style: .default, handler: { (_) in
                    UIApplication.shared.openURL(URL.init(string: retStr)!)
                })
                AlertMSG.alert(title: realm.objects(Model.self)[section].name!, msg: retStr, actions: [open ,action, cancel])
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            })
            sheet.addAction(surgeStringAction)
            sheet.addAction(shadowsocksProxyString)
            sheet.addAction(cancel)
            weakSelf?.present(sheet, animated: true, completion: nil)
        }
        headerView.row = section
        headerView.title = realm.objects(Model.self)[section].name
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let title = ["Address:", "Port:", "Password:", "Encryption:"]
        
        var model = Model()
        if isDelete == false {
            if cell == nil {
                cell = UITableViewCell.init(style: .value2, reuseIdentifier: "cell")
            }
            let str = self.getValueForNum((indexPath as NSIndexPath).row + 1)
            model = realm.objects(Model.self)[(indexPath as NSIndexPath).section]
            cell!.detailTextLabel?.text = model.value(forKey: str) as? String
            cell!.textLabel?.text = title[indexPath.row]
        } else {
            model = realm.objects(Model.self).filter("isNet = false")[(indexPath as NSIndexPath).row]
            cell!.textLabel?.text = model.address
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 4 {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let pboard = UIPasteboard.general
            
            let str = getValueForNum((indexPath as NSIndexPath).row + 1)
            pboard.string = (realm.objects(Model.self)[indexPath.section].value(forKey: str)) as? String
            weak var weakSelf = self
            AlertMSG.alert(title: realm.objects(Model.self)[indexPath.section].name!, msg: str.capitalized + " Copied", completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    weakSelf!.dismiss(animated: true, completion: {
                        weakSelf!.tableView.deselectRow(at: indexPath, animated: true)
                    })
                })
            })
        }
    }
    
}
