//
//  TodayViewController.swift
//  SSFTodayWidget
//
//  Created by 成殿 on 2018/4/17.
//  Copyright © 2018年 成璐飞. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
        
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 60)/3, height: 40)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 16, height: 110), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        view.backgroundColor = UIColor.clear
        preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width-16, height: 110)
        view.addSubview(collectionView)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tech.chengluffy.shadowsocksfree")
        let realmURL = container!.appendingPathComponent("defualt.realm")
        
        Realm.Configuration.defaultConfiguration.fileURL = realmURL
        
        NetData.RefreshData(success: { (isSuccess) in
            self.collectionView.reloadData()
        }, failure: { (error) in
            print(error?.localizedDescription ?? "nil")
        })

    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
            collectionView.frame.size = maxSize
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 60)/3, height:maxSize.height/11*4)
            print(maxSize.height/11*4)
            layout.minimumLineSpacing = maxSize.height/11
        } else {
            var height: CGFloat?
            if (realm.objects(Model.self).count) > 3 {
                let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                let temp = layout.itemSize.height / 4
                print(temp)
                let lines: Int = (realm.objects(Model.self).count-1)/3
                height = CGFloat(temp*6 + (temp * 5 * CGFloat(lines)))
            } else {
                height = 110
            }
            height = maxSize.height > height! ? height! : maxSize.height
            print(height ?? "nil")
            collectionView.frame.size = CGSize(width: maxSize.width, height: height!)
            preferredContentSize = CGSize(width: maxSize.width, height: height!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realm.objects(Model.self).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let SSStr = NetData.getSSQRStr((indexPath as NSIndexPath).row)
        cell.prefs = SSStr
        cell.label.text = realm.objects(Model.self)[indexPath.row].address
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
//        print(cell.prefs!)
//        let action = "shadowrocket://add/\(cell.prefs!)"
//        print(action)
//        extensionContext?.open(URL.init(string: action)!, completionHandler: { (ret) in
//            print(ret)
//            if ret == false {
//                print(cell.prefs!)
//            }
//        })
        extensionContext?.open(URL.init(string: "shadowsocksfree://selected=\(indexPath.row)")!, completionHandler: { (ret) in
        })
    }
    
}
