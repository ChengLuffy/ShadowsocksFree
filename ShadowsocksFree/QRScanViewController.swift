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

class QRScanViewController: AnimatableViewController {

    var session: AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
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
                    try! realm.sharedInstance.write({
                        realm.sharedInstance.add(model, update: true)
                    })
                    
                    weakSelf?.dismissViewControllerAnimated(true, completion: nil)
                })
                alertVC.addAction(cancelAction)
                alertVC.addAction(addAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
            }
        }
    }
}
