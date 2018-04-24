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
import SVProgressHUD

class ViewController: UIViewController {
    var titles = [String]()
    var isDelete: Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged), name: NSNotification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
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
        title = "1/4DSSA"
        
         NotificationCenter.default.addObserver(forName: NSNotification.Name.init("NEUpdate"), object: nil, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
             if UserDefaults.standard.object(forKey: "connectedDate") == nil {
                 self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "circle-cross")
             } else {
                 self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "circle-check")
             }
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
         })
        
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
        NetData.RefreshData(success: { (isSuccess) in
            let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
            let temp = userDefaults?.value(forKey: "address")
            if temp != nil {
                let address = temp as! String
                if realm.objects(Model.self).filter("address = '\(address)'").count == 0 && address == "" {
                    VPNManager.shared.disconnect()
                    AlertMSG.alert(title: "\("address 已取消")", msg: "，请选择新的服务器链接", delay: 1.5)
                } else if realm.objects(Model.self).filter("address = '\(address)'").count != 0 {
                    let model = realm.objects(Model.self).filter("address = '\(address)'").first!
                    if model.address == (userDefaults?.value(forKey: "address") as! String) && model.encryption == (userDefaults?.value(forKey: "encryption") as! String) && model.port == (userDefaults?.value(forKey: "port") as! String) && model.passWord == (userDefaults?.value(forKey: "passWord") as! String) {} else {
                        userDefaults?.set(model.address, forKey: "address")
                        userDefaults?.set(model.port, forKey: "port")
                        userDefaults?.set(model.encryption, forKey: "encryption")
                        userDefaults?.set(model.passWord, forKey: "passWord")
                        if VPNManager.shared.vpnStatus == .on {
                            SVProgressHUD.show()
                            VPNManager.shared.disconnect()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                VPNManager.shared.connect()
                            })
                        }
                    }
                    
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            if !isSuccess {
                AlertMSG.alert(title: "出现错误", msg: "数据处理错误", delay: 1.5)
            }
        }, failure: { (error) in
            var msg: String?
            if error != nil {
                msg = error?.localizedDescription
            } else {
                msg = "空数据"
            }
            self.tableView.mj_header.endRefreshing()
            AlertMSG.alert(title: "出现错误", msg: msg!, delay: 2.5)
            
        })
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
    
   @IBAction func SettingAction(_ sender: Any) {
    #if DEBUG
    AlertMSG.alert(title: "非发行版本不可用", msg: "", delay: 2.0)
    #else
       let settingVC = SettingViewController()
       settingVC.transitioningDelegate = TransitionPresenterManager.shared.retrievePresenter(transitionAnimationType: .cards(direction: .backward), transitionDuration: 1, interactiveGestureType: .pan(from: .top))
       self.present(settingVC, animated: true, completion: nil)
    #endif
    }
    
    @IBAction func statusAction(_ sender: UIBarButtonItem) {
        if VPNManager.shared.vpnStatus == .on {
            let connectedDate = UserDefaults.standard.object(forKey: "connectedDate")
            let df = DateFormatter()
            df.dateFormat = "MM-dd HH:mm:ss"
            let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
            let adr = userDefaults?.value(forKey: "address") as! String
            let msg = "服务器: " + adr + "\n" + "链接时间: " + df.string(from: connectedDate as! Date)
            let alertC = UIAlertController(title: "链接信息", message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            let disConnectAction = UIAlertAction(title: "disconnect", style: .destructive) { (_) in
                VPNManager.shared.disconnect()
            }
            alertC.addAction(disConnectAction)
            alertC.addAction(okAction)
            self.present(alertC, animated: true, completion: nil)
        } else {
            AlertMSG.alert(title: "没有链接", msg: "请选择服务器链接", delay: 1.5)
        }
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
            let sheet = UIAlertController(title: "Connect or Copy?", message: nil, preferredStyle: .actionSheet)
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
                let retStr = NetData.getSSQRStr(section)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                })
                let action = UIAlertAction(title: "Copy", style: .default, handler: { (_) in
                    let pboard = UIPasteboard.general
                    pboard.string = retStr
                })
                let open = UIAlertAction(title: "Open", style: .default, handler: { (_) in
                    UIApplication.shared.openURL(URL.init(string: retStr!)!)
                })
                AlertMSG.alert(title: realm.objects(Model.self)[section].name!, msg: retStr!, actions: [open ,action, cancel])
            })
            var title: String = "Connect"
            let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
            
            if VPNManager.shared.vpnStatus == .on && model.address == (userDefaults?.value(forKey: "address") as! String) && model.encryption == (userDefaults?.value(forKey: "encryption") as! String) && model.port == (userDefaults?.value(forKey: "port") as! String) && model.passWord == (userDefaults?.value(forKey: "passWord") as! String) {
                title = "Disconnect"
            } else {
                title = "Connect"
            }
            let connect = UIAlertAction(title: title, style: .destructive, handler: { (action) in
                if title == "Disconnect" {
                    VPNManager.shared.disconnect()
                } else {
                    let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
                    userDefaults?.set(model.address, forKey: "address")
                    userDefaults?.set(model.port, forKey: "port")
                    userDefaults?.set(model.encryption, forKey: "encryption")
                    userDefaults?.set(model.passWord, forKey: "passWord")
                    SVProgressHUD.show()
                    VPNManager.shared.connect()
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            })
            sheet.addAction(connect)
            sheet.addAction(surgeStringAction)
            sheet.addAction(shadowsocksProxyString)
            sheet.addAction(cancel)
            weakSelf?.present(sheet, animated: true, completion: nil)
        }
        headerView.row = section
        headerView.title = realm.objects(Model.self)[section].name
        let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
        let model = realm.objects(Model.self)[section]
        
        if VPNManager.shared.vpnStatus == .on && model.address == (userDefaults?.value(forKey: "address") as! String) && model.encryption == (userDefaults?.value(forKey: "encryption") as! String) && model.port == (userDefaults?.value(forKey: "port") as! String) && model.passWord == (userDefaults?.value(forKey: "passWord") as! String) {
            headerView.isConnected = true
        } else {
            headerView.isConnected = false
        }
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
