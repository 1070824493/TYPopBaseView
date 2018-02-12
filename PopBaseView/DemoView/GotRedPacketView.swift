//
//  GotRedPacketView.swift
//  PopBaseView
//  获得红包时的弹窗界面 eg: GotRedPacketView.loadFromNib().show()
//  Created by ty on 2017/10/10.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit


class GotRedPacketView: PopBaseView, NibLoadable {
  
  override func awakeFromNib() {
    
    super.awakeFromNib()
    initPopViewHelper(with: CGSize(width: UIScreen.main.bounds.size.width - 60, height: 360), withViewPopDirection: .belowToCenter, maskStatus: .clickDisable)

  }
  
  
  @IBAction func closeButtonClick(_ sender: Any) {
    super.hide()
  }
  
  @IBAction func pushToBagClick(_ sender: Any) {
    super.hide()
  }
  
}
