//
//  QRScanViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/23.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import AVFoundation
import IBAnimatable
import RealmSwift

class QRScanViewController: UIViewController {

    var refreshHandle: (() -> ())?
    var session: AVCaptureSession?
    lazy var imagePickerVC: UIImagePickerController = {
        let imagePickerVC = UIImagePickerController.init()
        imagePickerVC.sourceType = .SavedPhotosAlbum
        imagePickerVC.delegate = self
        return imagePickerVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imagePickerBtn = UIButton.init(type: .System)
        imagePickerBtn.setTitle("从相册读取", forState: .Normal)
        imagePickerBtn.backgroundColor = UIColor(white: 1, alpha: 0.6)
        imagePickerBtn.layer.cornerRadius = 15
        let size = UIScreen.mainScreen().bounds.size
        imagePickerBtn.frame = CGRect(x: size.width / 2 - 50, y: size.height - 150, width: 100, height: 30)
        imagePickerBtn.addTarget(self, action: #selector(QRScanViewController.imagePickerBtnDidClicker(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(imagePickerBtn)
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput.init(device: device) as AVCaptureDeviceInput
            let output = AVCaptureMetadataOutput.init()
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            output.rectOfInterest = self.view.bounds
            
            session = AVCaptureSession.init()
            session?.canSetSessionPreset(AVCaptureSessionPresetHigh)
            session?.addInput(input)
            session?.addOutput(output)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
            
            let layer = AVCaptureVideoPreviewLayer.init(session: session)
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.frame = self.view.bounds
            self.view.layer.insertSublayer(layer, atIndex: 0)
            
            session?.startRunning()
            
        } catch let error as NSError {
            print(error)
            return
        }

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func imagePickerBtnDidClicker(sender: AnyObject) {
        session?.stopRunning()
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
    }

}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            session?.stopRunning()
            let metadataObject = metadataObjects[0]
            let str = metadataObject.stringValue as String
            print(str)
            if str.hasPrefix("ss://") {
                let dataStr = str.componentsSeparatedByString("://")[1]
                let data = NSData(base64EncodedString: dataStr, options: .IgnoreUnknownCharacters)
                let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let adress = str!.componentsSeparatedByString("@")[1].componentsSeparatedByString(":")[0]
                let port = str!.componentsSeparatedByString(":")[2]
                let method = str!.componentsSeparatedByString("@")[0].componentsSeparatedByString(":")[0]
                let password = str!.componentsSeparatedByString(":")[1].componentsSeparatedByString("@")[0]
                let alertVC = UIAlertController.init(title: "信息预览", message: "服务器地址:\(adress)\n端口:\(port)\n加密方式:\(method)\n密码:\(password)", preferredStyle: .Alert)
                weak var weakSelf = self
                let cancelAction = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (_) in
                    print("cancel")
                    weakSelf!.session?.startRunning()
                })
                let addAction = UIAlertAction.init(title: "添加", style: .Default, handler: { (_) in
                    let model = Model()
                    model.adress = "服务器地址:" + adress
                    model.port = "端口:" + port
                    model.encryption = "加密方式:" + method
                    model.passWord = "密码:" + password
                    model.isNet = false
                    let realm = try! Realm()
                    try! realm.write({
                        realm.add(model, update: true)
                    })
                    
                    weakSelf?.dismissViewControllerAnimated(true, completion: {
                        weakSelf?.refreshHandle!()
                    })
                })
                alertVC.addAction(cancelAction)
                alertVC.addAction(addAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
            } else {
                let alertVC = UIAlertController.init(title: "信息提示", message: "错误的ShadowSocks配置信息\n\(str)", preferredStyle: .Alert)
                weak var weakSelf = self
                let cancelAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: { (_) in
                    print("cancel")
                    weakSelf!.session?.startRunning()
                })
                alertVC.addAction(cancelAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let ciimage = CIImage.init(image: image)
        picker.dismissViewControllerAnimated(true) {
            let features = detector.featuresInImage(ciimage!)
            if features.count > 0 {
                let feature = features[0] as! CIQRCodeFeature
                let str = feature.messageString
                print(str)
                if str.hasPrefix("ss://") {
                    let dataStr = str.componentsSeparatedByString("://")[1]
                    let data = NSData(base64EncodedString: dataStr, options: .IgnoreUnknownCharacters)
                    let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    let adress = str!.componentsSeparatedByString("@")[1].componentsSeparatedByString(":")[0]
                    let port = str!.componentsSeparatedByString(":")[2]
                    let method = str!.componentsSeparatedByString("@")[0].componentsSeparatedByString(":")[0]
                    let password = str!.componentsSeparatedByString(":")[1].componentsSeparatedByString("@")[0]
                    let alertVC = UIAlertController.init(title: "信息预览", message: "服务器地址:\(adress)\n端口:\(port)\n加密方式:\(method)\n密码:\(password)", preferredStyle: .Alert)
                    weak var weakSelf = self
                    let cancelAction = UIAlertAction.init(title: "取消", style: .Cancel, handler: { (_) in
                        print("cancel")
                        weakSelf!.session?.startRunning()
                    })
                    let addAction = UIAlertAction.init(title: "添加", style: .Default, handler: { (_) in
                        let model = Model()
                        model.adress = "服务器地址:" + adress
                        model.port = "端口:" + port
                        model.encryption = "加密方式:" + method
                        model.passWord = "密码:" + password
                        model.isNet = false
                        let realm = try! Realm()
                        try! realm.write({
                            realm.add(model, update: true)
                        })
                        
                        weakSelf?.dismissViewControllerAnimated(true, completion: { 
                            weakSelf?.refreshHandle!()
                        })
                    })
                    alertVC.addAction(cancelAction)
                    alertVC.addAction(addAction)
                    self.presentViewController(alertVC, animated: true, completion: nil)
                } else {
                    let alertVC = UIAlertController.init(title: "信息提示", message: "错误的ShadowSocks配置信息\n\(str)", preferredStyle: .Alert)
                    weak var weakSelf = self
                    let cancelAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: { (_) in
                        print("cancel")
                        weakSelf!.session?.startRunning()
                    })
                    alertVC.addAction(cancelAction)
                    self.presentViewController(alertVC, animated: true, completion: nil)
                }
            } else {
                self.session?.startRunning()
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { 
            self.session?.startRunning()
        }
    }
}
