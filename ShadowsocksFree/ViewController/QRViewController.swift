//
//  QRViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/6.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class QRViewController: UIViewController {

    @IBOutlet weak var CollectionView: UICollectionView!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width - 20))
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CollectionView.register(UINib.init(nibName: "QRCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        CollectionView.register(UINib.init(nibName: "QRCollectionReusableHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        let layout = CollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("disappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSSQRStr(_ num: Int) -> String! {
        let model = realm.objects(Model.self)[num]
        print(model.adress!)
        let method: NSString = (model.encryption?.components(separatedBy: ":")[1])! as NSString
        
        let passWord: NSString?
        if model.passWord?.characters.count > 5 {
            passWord = model.passWord?.components(separatedBy: ":")[1] as NSString?
        } else {
            passWord = ""
        }
        
        let adress: NSString = (model.adress?.components(separatedBy: ":")[1])! as NSString
        
        let port: NSString = (model.port?.components(separatedBy: ":")[1])! as NSString
        let temp: NSString = NSString.init(format: "\(method):\(passWord!)@\(adress):\(port)" as NSString)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return realm.objects(Model.self).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QRCollectionViewCell
        
        let SSStr = getSSQRStr((indexPath as NSIndexPath).section)
        cell.mainImageView.image = UIImage.createQRImage(info: SSStr!, scale: UIScreen.main.bounds.size.width - 30)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 0, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! QRCollectionReusableHeaderView
        view.textLabel.text = realm.objects(Model.self)[(indexPath as NSIndexPath).section].name
        return view
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertVC = UIAlertController.init(title: "将二维码保存到相册？", message: "", preferredStyle: .alert)
        let cancleAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
            UIImageWriteToSavedPhotosAlbum((collectionView.cellForItem(at: indexPath) as! QRCollectionViewCell).mainImageView.image!, self, #selector(QRViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        alertVC.addAction(cancleAction)
        alertVC.addAction(sureAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        let str: String?
        if didFinishSavingWithError != nil {
            print("错误")
            str = "发生错误"
        } else {
            str = "保存成功"
        }
        
        let alertVC = UIAlertController.init(title: str, message: "", preferredStyle: .alert)
        weak var weadSelf = self
        self.present(alertVC, animated: true) { 
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { 
                weadSelf!.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
}
