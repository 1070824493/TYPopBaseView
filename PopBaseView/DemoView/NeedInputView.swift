//
//  NeedInputView.swift
//  PopBaseView
//
//  Created by ty on 2017/12/1.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit

class NeedInputView: PopBaseView,NibLoadable {

    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initPopViewHelper(with: CGSize(width: UIScreen.main.bounds.size.width - 60, height: 360), withViewPopDirection: .fade, maskStatus: .clickDisable)
        popViewHelper.adjustWithKeyboard = true
        popViewHelper.delegate = self
    }
    
    @IBAction func closeAction(_ sender: Any) {
        super.hide()
    }
    
}

extension NeedInputView: PopViewHelperDelegate{
    func popViewHelper(_ popViewHelper: PopViewHelper, didClickMask mask: UIControl) {
        inputTextField.resignFirstResponder()
    }
}
