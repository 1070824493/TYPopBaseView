//
//  PopBaseView.swift
//  PopBaseView
//
//  Created by ty on 2017/11/27.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit

open class PopBaseView: UIView {
    
    public var popViewHelper: PopViewHelper!
    
    init(size: CGSize? = nil, viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        super.init(frame: CGRect.zero)
        initPopViewHelper(with: size, withViewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func initPopViewHelper(with size: CGSize? = nil, withViewPopDirection viewPopDirection: ViewPopDirection, maskStatus: MaskStatus) {
        
        frame = CGRect(origin: CGPoint.zero, size: size ?? CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        popViewHelper = PopViewHelper(superView: nil, targetView: self, viewPopDirection: viewPopDirection, maskStatus: maskStatus)
        
    }
    
    open func show() {
        popViewHelper.showPoppingView()
    }
    
    @objc open func hide() {
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

public protocol NibLoadable: class {
    
}

extension NibLoadable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibLoadable where Self: UIView {
    public static func loadFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
    public static func loadFromNib(with OwnerOrNil: Any?) -> Self {
        return nib.instantiate(withOwner: OwnerOrNil, options: nil).first as! Self
    }
}

extension NibLoadable where Self: UIViewController {
    public var nib: UINib {
        return UINib(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    public func loadFromNib() {
        nib.instantiate(withOwner: self, options: nil)
    }
}
