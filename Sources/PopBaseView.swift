//
//  PopBaseView.swift
//  PopBaseView
//
//  Created by ty on 2017/11/27.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit

class PopBaseView: UIView {
    
    fileprivate(set) var popViewHelper: PopViewHelper!
    
    init(size: CGSize? = nil, viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        super.init(frame: CGRect.zero)
        initPopViewHelper(with: size, withViewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initPopViewHelper(with size: CGSize? = nil, withViewPopDirection viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        
        frame = CGRect(origin: CGPoint.zero, size: size ?? CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        popViewHelper = PopViewHelper(superView: nil, targetView: self, viewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    func show() {
        popViewHelper.showPoppingView()
    }
    
    @objc func hide() {
        popViewHelper.hidePoppingView()
    }
    
    func autoHidePopView(after delayTime: TimeInterval) {
        popViewHelper.hidePoppingView(after: delayTime)
    }
    
    func toggle() {
        
        if popViewHelper.isShow {
            popViewHelper.hidePoppingView()
        } else {
            popViewHelper.showPoppingView()
        }
    }
}

protocol NibLoadable: class {
    static var nib: UINib { get }
}

extension NibLoadable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
    static func loadFromNib(with OwnerOrNil: Any?) -> Self {
        return nib.instantiate(withOwner: OwnerOrNil, options: nil).first as! Self
    }
}

extension NibLoadable where Self: UIViewController {
    var nib: UINib {
        return UINib(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    func loadFromNib() {
        nib.instantiate(withOwner: self, options: nil)
    }
}
