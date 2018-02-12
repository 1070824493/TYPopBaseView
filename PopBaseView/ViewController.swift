//
//  ViewController.swift
//  PopBaseView
//
//  Created by ty on 2017/11/24.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func bottomNormalPop(_ sender: Any) {
        GotRedPacketView.loadFromNib().show()
    }
    
    @IBAction func needInputViewPop(_ sender: Any) {
        NeedInputView.loadFromNib().show()
    }
    
}

