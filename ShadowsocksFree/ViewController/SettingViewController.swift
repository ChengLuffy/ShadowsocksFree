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
    
    private lazy var customBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "自定义数据"), for: .normal)
        button.addTarget(self, action: #selector(SettingViewController.customAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapCopyInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "首页点击 cell 是否复制相关信息"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 0
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
//        view.addSubview(imageView)
        view.addSubview(closeBtn)
        view.addSubview(customBtn)
        view.addSubview(tapCopyInfoLabel)
        view.addSubview(switchBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        customBtn.translatesAutoresizingMaskIntoConstraints = false
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        tapCopyInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["closeBtn": closeBtn,
//                     "imageView": imageView,
                     "infoLabel": tapCopyInfoLabel,
                     "switchBtn": switchBtn,
                     "customBtn": customBtn] as [String : Any]
        
        let closeBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:[closeBtn]-25-|", options: [], metrics: nil, views: views)
        var closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[closeBtn]", options: [], metrics: nil, views: views)
        
        if #available(iOS 11.0, *) {
            let metrics = ["topAnchor": view.safeAreaInsets.top + 20 , "bottomAnchor": view.safeAreaInsets.bottom] as [String : Any]
            closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topAnchor-[closeBtn]", options: [], metrics: metrics, views: views)
        }
        
        let customBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-25-[customBtn]", options: [], metrics: nil, views: views)
        var customBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[customBtn]", options: [], metrics: nil, views: views)
        
        if #available(iOS 11.0, *) {
            let metrics = ["topAnchor": view.safeAreaInsets.top + 20 , "bottomAnchor": view.safeAreaInsets.bottom] as [String : Any]
            customBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topAnchor-[customBtn]", options: [], metrics: metrics, views: views)
        }
        
//        let imageViewHCenter = NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
//        let imageViewVCenter = NSLayoutConstraint.init(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -100)
        
        let labelHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[infoLabel]-50-|", options: [], metrics: nil, views: views)
//        let labelVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]-30-[infoLabel]", options: [], metrics: nil, views: views)
        let labelVC = NSLayoutConstraint.init(item: tapCopyInfoLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        let switchHC = NSLayoutConstraint.init(item: switchBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let switchVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[infoLabel]-10-[switchBtn]", options: [], metrics: nil, views: views)
        
        view.addConstraints(closeBtnHC)
        view.addConstraints(closeBtnVC)
        
        view.addConstraints(customBtnHC)
        view.addConstraints(customBtnVC)
        
//        view.addConstraint(imageViewHCenter)
//        view.addConstraint(imageViewVCenter)
        
        view.addConstraints(labelHC)
        view.addConstraint(labelVC)
        
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
    
    @objc func customAction() {
        let sheet = UIAlertController(title: "请选择", message: "您可以更新自定义的 源数据 地址\n或者输入一个 备用 节点", preferredStyle: .actionSheet)
        let sourceAction = UIAlertAction(title: "更新源数据地址", style: .default) { (_) in
            self.updateSourceAddress()
        }
        let inputMineAction = UIAlertAction(title: "输入备用节点", style: .default) { (_) in
            
            let sheet = UIAlertController(title: "请选择", message: nil, preferredStyle: .actionSheet)
            let ssAction = UIAlertAction(title: "Shadowsocks", style: .default, handler: { (_) in
                self.inputMineAction()
            })
            let httpAction = UIAlertAction(title: "Http", style: .default, handler: { (_) in
                self.inputHttpOrSocksProxy(type: 0)
            })
            let socksAction = UIAlertAction(title: "Socks 5", style: .default, handler: { (_) in
                self.inputHttpOrSocksProxy(type: 1)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            }
            sheet.addAction(ssAction)
            sheet.addAction(httpAction)
            sheet.addAction(socksAction)
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true) {
            }
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
        }
        
        sheet.addAction(sourceAction)
        sheet.addAction(inputMineAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true) {
        }
    }
    
    func updateSourceAddress() {
        let alertC = UIAlertController(title: "自定义源数据链接地址", message: "https://us.ishadowx.net 经常更换二级域名，您可以将上述链接输入到浏览器查看最终定向的链接地址，并将完全的地址(包括https://)填写到输入框内", preferredStyle: .alert)
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
    
    func inputHttpOrSocksProxy(type: Int) {
        let temp = (type == 0 ? "Http" : "Socks 5")
        let alertC = UIAlertController(title: "Proxy info", message: "您可以内置一个备用  \(temp)  节点", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "Sure", style: .default) { (action) in
            guard let ip = alertC.textFields?.first?.text else {
                return
            }
            
            guard let prot = alertC.textFields?.last?.text else {
                return
            }
            
            try! realm.write({
                realm.delete(realm.objects(Model.self).filter("server = 'mine'"))
            })
            
            let model = Model()
            model.encryption = type == 0 ? "http" : "socks"
            model.port = prot
            model.passWord = ""
            model.address = ip
            model.isNet = false
            model.server = "mine"
            try! realm.write({
                realm.add(model, update: true)
            })
            AlertMSG.alert(title: "Success", msg: "您可以在首页最下面进行链接，如果失败，请检查输入是否正确，当然也有可能是软件不完善", delay: 1.25)
            
        }
        
        alertC.addTextField { (tf) in
            tf.placeholder = "Adress"
        }
        alertC.addTextField { (tf) in
            tf.placeholder = "Prot"
        }
        alertC.addAction(cancelAction)
        alertC.addAction(sureAction)
        
        present(alertC, animated: true, completion: nil)
    }
    
    func inputMineAction() {
        let alertC = UIAlertController(title: "ss link", message: "您可以内置一个备用ss节点", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "Sure", style: .default) { (action) in
            guard let sslink = alertC.textFields?.first?.text else {
                return
            }
            
            let ssInfo = ParseSSURL(URL.init(string: sslink))
            
            guard ssInfo!["msg"] == nil else {
                AlertMSG.alert(title: "无法识别您输入的 ss 链接", msg: "请确认你的链接格式是否正确,\n当然也有可能是软件不完善.", delay: 2.50)
                return
            }
            
            try! realm.write({
                realm.delete(realm.objects(Model.self).filter("server = 'mine'"))
            })
            
            let model = Model()
            model.encryption = ssInfo?["Method"] as? String
            model.port = "\(String(describing: ssInfo?["ServerPort"] as! Int))"
            model.passWord = ssInfo?["Password"] as? String
            model.address = ssInfo?["ServerHost"] as? String
            model.isNet = false
            model.server = "mine"
            try! realm.write({
                realm.add(model, update: true)
            })
            AlertMSG.alert(title: "Success", msg: "您可以在首页最下面进行链接，如果失败，请检查链接是否正确，当然也有可能是软件不完善", delay: 1.25)
            
            /*
            if sslink.components(separatedBy: "//").count > 1 {
                var base64Str: String = ""
                let temp = sslink.components(separatedBy: "//").last
                if (temp?.components(separatedBy: "#").count)! > 1 {
                    base64Str = (temp?.components(separatedBy: "#").first)!
                } else {
                    base64Str = temp!
                }
                guard let str = (base64Str as NSString).base64Decoded() else {
                    AlertMSG.alert(title: "无法识别您输入的 ss 链接", msg: "请确认你的链接格式是否正确", delay: 1.25)
                    return
                }
                
                try! realm.write({
                    realm.delete(realm.objects(Model.self).filter("server = 'mine'"))
                })
                
                let model = Model()
                let arr = str.components(separatedBy: ":")
                model.encryption = arr.first
                model.port = arr.last
                model.passWord = arr[1].components(separatedBy: "@").first
                model.address = arr[1].components(separatedBy: "@").last
                model.isNet = false
                model.server = "mine"
                try! realm.write({
                    realm.add(model, update: true)
                })
                AlertMSG.alert(title: "Success", msg: "您可以在首页最下面进行链接，如果失败，请检查链接是否正确，当然也有可能是软件不完善", delay: 1.25)
            } else {
                AlertMSG.alert(title: "无法识别您输入的 ss 链接", msg: "请确认你的链接格式是否正确", delay: 1.25)
            }
            */
            
        }
        
        alertC.addTextField { (tf) in
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

