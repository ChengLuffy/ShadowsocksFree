//
//  QRScanViewController.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/23.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class QRScanViewController: UIViewController {

    var refreshHandle: (() -> ())?
    var session: AVCaptureSession?
    lazy var imagePickerVC: UIImagePickerController = {
        let imagePickerVC = UIImagePickerController.init()
        imagePickerVC.sourceType = .savedPhotosAlbum
        imagePickerVC.delegate = self
        return imagePickerVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imagePickerBtn = UIButton.init(type: .system)
        imagePickerBtn.setTitle("从相册读取", for: UIControlState())
        imagePickerBtn.backgroundColor = UIColor(white: 1, alpha: 0.6)
        imagePickerBtn.layer.cornerRadius = 15
        let size = UIScreen.main.bounds.size
        imagePickerBtn.frame = CGRect(x: size.width / 2 - 50, y: size.height - 150, width: 100, height: 30)
        imagePickerBtn.addTarget(self, action: #selector(QRScanViewController.imagePickerBtnDidClicker(_:)), for: .touchUpInside)
        self.view.addSubview(imagePickerBtn)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput.init(device: device) as AVCaptureDeviceInput
            let output = AVCaptureMetadataOutput.init()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.rectOfInterest = self.view.bounds
            
            session = AVCaptureSession.init()
            session?.canSetSessionPreset(AVCaptureSessionPresetHigh)
            session?.addInput(input)
            session?.addOutput(output)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
            
            let layer = AVCaptureVideoPreviewLayer.init(session: session)
            layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer?.frame = self.view.bounds
            self.view.layer.insertSublayer(layer!, at: 0)
            
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
    
    func imagePickerBtnDidClicker(_ sender: AnyObject) {
        session?.stopRunning()
        self.present(imagePickerVC, animated: true, completion: nil)
    }

}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            session?.stopRunning()
            let metadataObject = metadataObjects[0]
            let str = (metadataObject as AnyObject).stringValue as String
            print(str)
            if str.hasPrefix("ss://") {
                let dataStr = str.components(separatedBy: "://")[1]
                let data = Data(base64Encoded: dataStr, options: .ignoreUnknownCharacters)
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let adress = str!.components(separatedBy: "@")[1].components(separatedBy: ":")[0]
                let port = str!.components(separatedBy: ":")[2]
                let method = str!.components(separatedBy: "@")[0].components(separatedBy: ":")[0]
                let password = str!.components(separatedBy: ":")[1].components(separatedBy: "@")[0]
                let alertVC = UIAlertController.init(title: "信息预览", message: "服务器地址:\(adress)\n端口:\(port)\n加密方式:\(method)\n密码:\(password)", preferredStyle: .alert)
                weak var weakSelf = self
                let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in
                    print("cancel")
                    weakSelf!.session?.startRunning()
                })
                let addAction = UIAlertAction.init(title: "添加", style: .default, handler: { (_) in
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
                    
                    weakSelf?.dismiss(animated: true, completion: {
                        weakSelf?.refreshHandle!()
                    })
                })
                alertVC.addAction(cancelAction)
                alertVC.addAction(addAction)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                let alertVC = UIAlertController.init(title: "信息提示", message: "错误的ShadowSocks配置信息\n\(str)", preferredStyle: .alert)
                weak var weakSelf = self
                let cancelAction = UIAlertAction.init(title: "确定", style: .cancel, handler: { (_) in
                    print("cancel")
                    weakSelf!.session?.startRunning()
                })
                alertVC.addAction(cancelAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let ciimage = CIImage.init(image: image)
        picker.dismiss(animated: true) {
            let features = detector?.features(in: ciimage!)
            if (features?.count)! > 0 {
                let feature = features?[0] as! CIQRCodeFeature
                let str = feature.messageString
//                print(str)
                if (str?.hasPrefix("ss://"))! {
                    let dataStr = str?.components(separatedBy: "://")[1]
                    let data = Data(base64Encoded: dataStr!, options: .ignoreUnknownCharacters)
                    let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    let adress = str!.components(separatedBy: "@")[1].components(separatedBy: ":")[0]
                    let port = str!.components(separatedBy: ":")[2]
                    let method = str!.components(separatedBy: "@")[0].components(separatedBy: ":")[0]
                    let password = str!.components(separatedBy: ":")[1].components(separatedBy: "@")[0]
                    let alertVC = UIAlertController.init(title: "信息预览", message: "服务器地址:\(adress)\n端口:\(port)\n加密方式:\(method)\n密码:\(password)", preferredStyle: .alert)
                    weak var weakSelf = self
                    let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in
                        print("cancel")
                        weakSelf!.session?.startRunning()
                    })
                    let addAction = UIAlertAction.init(title: "添加", style: .default, handler: { (_) in
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
                        
                        weakSelf?.dismiss(animated: true, completion: { 
                            weakSelf?.refreshHandle!()
                        })
                    })
                    alertVC.addAction(cancelAction)
                    alertVC.addAction(addAction)
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    let alertVC = UIAlertController.init(title: "信息提示", message: "错误的ShadowSocks配置信息\n\(str)", preferredStyle: .alert)
                    weak var weakSelf = self
                    let cancelAction = UIAlertAction.init(title: "确定", style: .cancel, handler: { (_) in
                        print("cancel")
                        weakSelf!.session?.startRunning()
                    })
                    alertVC.addAction(cancelAction)
                    self.present(alertVC, animated: true, completion: nil)
                }
            } else {
                self.session?.startRunning()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { 
            self.session?.startRunning()
        }
    }
}
