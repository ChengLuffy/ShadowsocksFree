//
//  QRViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/6.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    @IBOutlet weak var CollectionView: UICollectionView!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width - 20, height: UIScreen.mainScreen().bounds.size.width - 20))
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CollectionView.registerNib(UINib.init(nibName: "QRCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        CollectionView.registerNib(UINib.init(nibName: "QRCollectionReusableHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        let layout = CollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSSQRStr(num: Int) -> String! {
        let model = realm.sharedInstance.objects(Model)[num]
        print(model.adress)
        let method: NSString = (model.encryption?.componentsSeparatedByString(":")[1])!
        
        let passWord: NSString?
        if model.passWord?.characters.count > 5 {
            passWord = model.passWord?.componentsSeparatedByString(":")[1]
        } else {
            passWord = ""
        }
        
        let adress: NSString = (model.adress?.componentsSeparatedByString(":")[1])!
        
        let port: NSString = (model.port?.componentsSeparatedByString(":")[1])!
        let temp: NSString = NSString.init(format: "\(method):\(passWord!)@\(adress):\(port)")
        let temp1 = temp.base64EncodedString()
        let retStr = "ss://" + temp1
        
        return retStr
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

extension QRViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! QRCollectionViewCell
        
        let SSStr = getSSQRStr(indexPath.section)
        cell.mainImageView.image = UIImage.mdQRCodeForString(SSStr, size: 100)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.mainScreen().bounds.size.width - 20, height: UIScreen.mainScreen().bounds.size.width - 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 0, height: 30)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! QRCollectionReusableHeaderView
        view.textLabel.text = realm.sharedInstance.objects(Model)[indexPath.section].name
        return view
        
    }
    
}
