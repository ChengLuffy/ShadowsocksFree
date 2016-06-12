//
//  AddInfoTableViewCell.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class AddInfoTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    var view: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag != 14 {
            if textField.text?.characters.count > 0 {
                let tf = view?.viewWithTag(textField.tag + 1)
                tf?.becomeFirstResponder()
            } else {
                return false
            }
            
        } else if textField.tag == 14 {
            NSNotificationCenter.defaultCenter().postNotificationName("done", object: nil)
        }
        return true
    }
    
}
