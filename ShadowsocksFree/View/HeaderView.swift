//
//  HeaderView.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/11/27.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var label = UILabel()
    var btn = UIButton.init(type: .system)
    var block :((Int) -> ())?
    var row: Int?
    var isConnected: Bool = false {
        didSet {
            if isConnected {
                label.textColor = UIColor.systemRed
            } else {
                label.textColor = UIColor.systemTeal
            }
        }
    }
    
    var title: String?
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    convenience init(frame: CGRect, shareAction: ((Int) -> ())?) {
        self.init(frame: frame)
        self.block = shareAction
        
        isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemGroupedBackground
        } else {
            // Fallback on earlier versions
            backgroundColor = UIColor.groupTableViewBackground
        }
        
        btn.setImage(#imageLiteral(resourceName: "connect").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(HeaderView.shareAction), for: .touchUpInside)
        
        addSubview(label)
        addSubview(btn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = title
        
        let views = ["label": label,
                     "btn": btn] as [String : Any]
        
        let labelHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]", options: [], metrics: nil, views: views)
        let labelVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views)
        
        let btnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:[btn]-15-|", options: [], metrics: nil, views: views)
        let btnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|[btn]|", options: [], metrics: nil, views: views)
        
        addConstraints(labelHC)
        addConstraints(labelVC)
        addConstraints(btnHC)
        addConstraints(btnVC)
    }
    
    @objc func shareAction() {
        block!(row!)
    }
    
}
