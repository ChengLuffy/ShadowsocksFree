//
//  ViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/5/3.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class ViewController: UIViewController {
    var titles = [String]()
    var refreshControl: UIRefreshControl?
    @IBOutlet weak var tableView: UITableView!
    lazy var dataSource: [String] = {
        return [String]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ViewController.getData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        
//        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.refreshControl?.beginRefreshing()
        let request = NSURLRequest.init(URL: NSURL.init(string: "http://www.ishadowsocks.net/")!)
        
        Alamofire.request(request).responseData { (respose: Response) in
            if respose.result.error == nil {
                let str = String.init(data: respose.result.value!, encoding: NSUTF8StringEncoding)
                let arr = str?.componentsSeparatedByString("<h3>免费shadowsocks帐号</h3>")
                let str1 = arr![1] as String
                let arr1 = str1.componentsSeparatedByString("</section>")
                let str2 = arr1[0] as String
                var subArr = str2.componentsSeparatedByString("<h4>")
                subArr.removeAtIndex(0)
                
                for (index, value) in subArr.enumerate() {
                    var subStr1 = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if index+1 % 6 != 0 {
                        let range = subStr1.rangeOfString("</h4>")
                        subStr1.removeRange(range!)
                    }
                    let tempStr: String
                    if (index + 1) % 6 == 5 {
                        tempStr = "状态:" + subStr1.componentsSeparatedByString(":")[1].componentsSeparatedByString("\">")[1].componentsSeparatedByString("<")[0]
                        self.dataSource.append(tempStr)
                    } else if (index + 1) % 6 == 0 {
                    } else if (index + 1) % 6 == 1 {
                        let temp = subStr1.componentsSeparatedByString(":")[1].substringToIndex(subStr1.startIndex.advancedBy(2))
                        self.titles.append(temp.uppercaseString)
                        self.dataSource.append(subStr1)
                    } else {
                        self.dataSource.append(subStr1)
                    }
                }
                self.tableView.reloadData()
//                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.refreshControl!.endRefreshing()
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if dataSource.count > 0 {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = dataSource[indexPath.section * 5 + indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let pboard = UIPasteboard.generalPasteboard()
            pboard.string = dataSource[indexPath.section * 5 + indexPath.row].componentsSeparatedByString(":")[1]
            let alertVC = UIAlertController.init(title: dataSource[indexPath.section * 5 + indexPath.row].componentsSeparatedByString(":")[0] + "已成功复制", message: "", preferredStyle: .Alert)
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