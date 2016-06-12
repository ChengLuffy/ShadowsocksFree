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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("disappear")
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
        let retStr = "ss://" + (temp1 as String)
        
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
        return realm.sharedInstance.objects(Model).count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! QRCollectionViewCell
        
        let SSStr = getSSQRStr(indexPath.section)
        cell.mainImageView.image = UIImage.createQRImage(info: SSStr, scale: UIScreen.mainScreen().bounds.size.width - 30)
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let alertVC = UIAlertController.init(title: "将二维码保存到相册？", message: "", preferredStyle: .Alert)
        let cancleAction = UIAlertAction.init(title: "取消", style: .Cancel) { (action) in
            
        }
        let sureAction = UIAlertAction.init(title: "确定", style: .Default) { (action) in
            UIImageWriteToSavedPhotosAlbum((collectionView.cellForItemAtIndexPath(indexPath) as! QRCollectionViewCell).mainImageView.image!, self, #selector(QRViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        alertVC.addAction(cancleAction)
        alertVC.addAction(sureAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        let str: String?
        if didFinishSavingWithError != nil {
            print("错误")
            str = "发生错误"
        } else {
            str = "保存成功"
        }
        
        let alertVC = UIAlertController.init(title: str, message: "", preferredStyle: .Alert)
        weak var weadSelf = self
        self.presentViewController(alertVC, animated: true) { 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { 
                weadSelf!.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
    }
    
}
