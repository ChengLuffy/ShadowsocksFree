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
        CollectionView.register(UINib.init(nibName: "QRCollectionReusableHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
        let model = realm.objects(Model.self).filter("isNet = true")[num]
        print(model.address!)
        let method: NSString = model.encryption! as NSString
        
        let passWord: NSString?
        if model.passWord?.count > 5 {
            passWord = model.passWord as NSString?
        } else {
            passWord = ""
        }
        
        let adress: NSString = model.address! as NSString
        
        let port: NSString = model.port! as NSString
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
        return realm.objects(Model.self).filter("isNet = true").count
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! QRCollectionReusableHeaderView
        view.textLabel.text = realm.objects(Model.self).filter("isNet = true")[(indexPath as NSIndexPath).section].name
        return view
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cancleAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
        }
        let sureAction = UIAlertAction.init(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            UIImageWriteToSavedPhotosAlbum((collectionView.cellForItem(at: indexPath) as! QRCollectionViewCell).mainImageView.image!, self, #selector(QRViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        AlertMSG.alert(title: NSLocalizedString("saveImage", comment: ""), msg: "", actions: [cancleAction, sureAction])
    }
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        let str: String?
        if didFinishSavingWithError != nil {
            print("错误")
            str = NSLocalizedString("error", comment: "")
        } else {
            str = NSLocalizedString("saveSuccess", comment: "")
        }
        AlertMSG.alert(title: str!, msg: (didFinishSavingWithError?.localizedDescription) ?? "", delay: 1.5)
    }
    
}
