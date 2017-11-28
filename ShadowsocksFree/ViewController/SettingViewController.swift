//
//  SettingViewController.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/11/28.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import StoreKit

class SettingViewController: UIViewController {
    
    private var buyBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("请作者喝杯🍵", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor.blue
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.addTarget(self, action: #selector(SettingViewController.buyBtnAction), for: .touchUpInside)
        return button
    }()
    
    private var closeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.addTarget(self, action: #selector(SettingViewController.closeBtnAction), for: .touchUpInside)
        return button
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        // #2179FD
        label.textColor = UIColor.init(hexString: "#2179FD")
        label.text =
        """
        1. 本软件不保证可以一直正常使用，如有异常可以等待更新；
        \n
        2. 且用且珍惜；
        \n
        3. 赞助后并没有特殊功能，仅供作者喝杯🍵。
        """
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        view.addSubview(buyBtn)
        view.addSubview(closeBtn)
        view.addSubview(infoLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        buyBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["buyBtn": buyBtn, "closeBtn": closeBtn, "infoLabel": infoLabel] as [String : Any]
        
        let buyBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:[buyBtn(150)]", options: [], metrics: nil, views: views)
        let buyBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-150-[buyBtn(40)]", options: [], metrics: nil, views: views)
        let buyBtnHCenter = NSLayoutConstraint.init(item: buyBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let closeBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[closeBtn]", options: [], metrics: nil, views: views)
        let closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[closeBtn]", options: [], metrics: nil, views: views)
        
        let infoLabelVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[buyBtn]-25-[infoLabel]", options: [], metrics: nil, views: views)
        let infoLabelHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10)-[infoLabel]-(>=10)-|", options: [], metrics: nil, views: views)
        let infoLabelHCenter = NSLayoutConstraint.init(item: infoLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        view.addConstraints(infoLabelVC)
        view.addConstraints(infoLabelHC)
        view.addConstraint(infoLabelHCenter)
        
        view.addConstraints(closeBtnHC)
        view.addConstraints(closeBtnVC)
        
        view.addConstraint(buyBtnHCenter)
        view.addConstraints(buyBtnHC)
        view.addConstraints(buyBtnVC)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func buyBtnAction() {
        view.isUserInteractionEnabled = false
        closeBtn.isEnabled = false
        buyBtn.isEnabled = false
        buyBtn.setTitle("正在处理😆", for: .normal)
        let productionID = ["tech.chengluffy.shadowsocksfree.tee"]
        let teeRequest = SKProductsRequest.init(productIdentifiers: Set(productionID))
        teeRequest.delegate = self
        teeRequest.start()
    }
    
    @objc func closeBtnAction() {
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let tee = response.products.first
        let payment = SKPayment.init(product: tee!)
        SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(self)
    }
}

extension SettingViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let transaction = transactions.first
        if transaction?.transactionState == SKPaymentTransactionState.purchased {
            SKPaymentQueue.default().finishTransaction(transaction!)
            closeBtn.isEnabled = true
            buyBtn.isEnabled = true
            buyBtn.setTitle("请作者喝杯🍵", for: .normal)
            view.isUserInteractionEnabled = true
        } else if transaction?.transactionState == SKPaymentTransactionState.failed {
            let alertVC = UIAlertController.init(title: "Error", message: transaction!.error?.localizedDescription, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true) {
            }
            closeBtn.isEnabled = true
            buyBtn.isEnabled = true
            buyBtn.setTitle("请作者喝杯🍵", for: .normal)
            view.isUserInteractionEnabled = true
        }
    }
}
