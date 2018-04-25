//
//  SettingViewController.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/11/28.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
    
class SettingViewController: UIViewController {
    
    var tf: UITextField?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "IMG_1790"))
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.saveImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "关闭"), for: .normal)
        button.addTarget(self, action: #selector(SettingViewController.closeBtnAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapCopyInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "tap cell to copy info"
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var switchBtn: UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.isOn = UserDefaults.standard.bool(forKey: "tapCopy")
        switchBtn.addTarget(self, action: #selector(switchValueChange(_:)), for: .valueChanged)
        return switchBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        view.addSubview(closeBtn)
        view.addSubview(imageView)
        view.addSubview(tapCopyInfoLabel)
        view.addSubview(switchBtn)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        view.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tapCopyInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["closeBtn": closeBtn, "imageView": imageView, "infoLabel": tapCopyInfoLabel, "switchBtn": switchBtn] as [String : Any]
        
        let closeBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:[closeBtn]-25-|", options: [], metrics: nil, views: views)
        var closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[closeBtn]", options: [], metrics: nil, views: views)
        
        if #available(iOS 11.0, *) {
            let metrics = ["topAnchor": view.safeAreaInsets.top + 20 , "bottomAnchor": view.safeAreaInsets.bottom] as [String : Any]
            closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topAnchor-[closeBtn]", options: [], metrics: metrics, views: views)
        }
        
        let imageViewHCenter = NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let imageViewVCenter = NSLayoutConstraint.init(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -100)
        
        let labelHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[infoLabel]-50-|", options: [], metrics: nil, views: views)
        let labelVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]-40-[infoLabel]", options: [], metrics: nil, views: views)
        
        let switchHC = NSLayoutConstraint.init(item: switchBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let switchVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[infoLabel]-10-[switchBtn]", options: [], metrics: nil, views: views)
        
        view.addConstraints(closeBtnHC)
        view.addConstraints(closeBtnVC)
        
        view.addConstraint(imageViewHCenter)
        view.addConstraint(imageViewVCenter)
        
        view.addConstraints(labelHC)
        view.addConstraints(labelVC)
        
        view.addConstraint(switchHC)
        view.addConstraints(switchVC)
    }
    
    deinit {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func switchValueChange(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "tapCopy")
        } else {
            UserDefaults.standard.set(false, forKey: "tapCopy")
        }
    }
    
    @objc func closeBtnAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveImage() {
        let activityVC = UIActivityViewController(activityItems: [#imageLiteral(resourceName: "IMG_1790")], applicationActivities: nil)
        present(activityVC, animated: true) {
        }
    }
    
    @objc func longPressAction() {
        let alertC = UIAlertController(title: "自定义链接地址", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "Sure", style: .default) { (action) in
            let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
            userDefaults?.set(alertC.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "url")
        }
        
        alertC.addTextField { (tf) in
            let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
            if userDefaults?.value(forKey: "url") != nil {
                tf.text = userDefaults?.value(forKey: "url") as? String
            }
        }
        alertC.addAction(cancelAction)
        alertC.addAction(sureAction)
        
        present(alertC, animated: true, completion: nil)
    }
    
    private func enableUserInteraction() {
        closeBtn.isEnabled = true
        view.isUserInteractionEnabled = true
    }
    
}

