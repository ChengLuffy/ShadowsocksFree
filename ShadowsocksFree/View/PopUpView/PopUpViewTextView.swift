//
//  PopUpViewTextView.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/23.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class PopUpViewTextView: UIView {

    @IBOutlet var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainView = Bundle.main.loadNibNamed("PopUpViewTextView", owner: self, options: nil)?.first as! UIView
        mainView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        mainView.center = self.center
        self.addSubview(mainView)
        
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 350, height: 50))
        label.text = "请输入配置信息"
        label.textAlignment = .center
        label.textColor = UIColor(red: 29.0 / 255.0, green: 169.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
        label.center = CGPoint(x: self.center.x, y: 70)
        label.font = UIFont.boldSystemFont(ofSize: 30)
        self.addSubview(label)
        self.backgroundColor = UIColor.white

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}

extension PopUpViewTextView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.x")
        let progressLine = mainView.viewWithTag(textField.tag + 10)
        progressLine!.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        basicAnimation.duration = 0.3
        basicAnimation.repeatCount = 1
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.fromValue = NSNumber.init(value: 1 as Float)
        basicAnimation.toValue = NSNumber.init(value: 280 as Float)
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)
        progressLine!.layer.add(basicAnimation, forKey: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TFTag"), object: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.x")
            let progressLine = mainView.viewWithTag(textField.tag + 10)
            progressLine!.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            basicAnimation.duration = 0.3
            basicAnimation.repeatCount = 1
            basicAnimation.isRemovedOnCompletion = false
            basicAnimation.fromValue = NSNumber.init(value: Float(280) as Float)
            basicAnimation.toValue = NSNumber.init(value: 1 as Float)
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)
            progressLine!.layer.add(basicAnimation, forKey: nil)
        }
    }
    
}

