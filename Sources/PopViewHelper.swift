//
//  PopViewHelper.swift
//  PopViewHelper
//
//  Created by ty on 2017/11/27.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit

@objc protocol PopViewHelperDelegate: NSObjectProtocol {
    
    @objc optional func popViewHelper(_ popViewHelper: PopViewHelper, willShowPoppingView targetView: UIView)
    @objc optional func popViewHelper(_ popViewHelper: PopViewHelper, willHidePoppingView targetView: UIView)
    @objc optional func popViewHelper(_ popViewHelper: PopViewHelper, didShowPoppingView targetView: UIView)
    @objc optional func popViewHelper(_ popViewHelper: PopViewHelper, didHidePoppingView targetView: UIView)
    @objc optional func showAnimationBlock(animatedTargetView: UIView)
    @objc optional func hideAnimationBlock(animatedTargetView: UIView)
    @objc optional func popViewHelper(_ popViewHelper: PopViewHelper, didClickMask mask: UIControl)
    
}

//弹出方向
enum ViewPopDirection{
    case none
    case above
    case below
    case belowToCenter
    case center
    case onlyShowFullScreen
    case fade
    case belowWithPadding
}

//动画表现
enum AnimationStyle{
    case normal
    case spring
}

enum MaskStatus {
    case hidden //不存在
    case transparent //不可见可点击
    case transparentAndDisable //不可见不可点击
    case normal //可见可点击
    case clickDisable // 可见不可点击
}

// 解决问题：调用了隐藏，但是，如果还在显示动画中，不会起效果；或者调用了显示，但是还在隐藏的动画中，该方法调用会失败
enum AnimationTarget {
    case unset // 默认
    case show // 最终要显示
    case hide // 最终要隐藏
}

class PopViewHelper: NSObject {
    
    private(set) var isAnimating = false //是否正在动画中
    private(set) var animationTarget: AnimationTarget = .unset
    private(set) var mask : UIControl?
    private(set) var isShow = false //是否正在显示
    private var spring: CGFloat = 1 //动画弹性
    private var initVelocity: CGFloat = 0 //动画初始速度
    private var keyBoardController: KeyBoardController!
    fileprivate var currentFrame: CGRect!
    private var targetViewShadowOpacity: Float = 0
    private var delayHideTime: TimeInterval?
    
    weak var delegate: PopViewHelperDelegate?
    
    //可定制参数
    weak var targetView: UIView!
    var strongTargetView: UIView!
    var superView: UIView
    var viewPopDirection: ViewPopDirection
    var showAnimateDuration: TimeInterval = 0.25 //动画持续时间
    var hideAnimateDuration: TimeInterval = 0.25 //动画持续时间
    var alpha:[CGFloat] = [1,1,1]
    var beginOrigin: CGPoint = CGPoint.zero //开始位置
    var showOrigin: CGPoint = CGPoint.zero //弹出后位置
    var endOrigin: CGPoint = CGPoint.zero //收回
    var maskStatus: MaskStatus //是否显示遮罩
    var maskAlpha: CGFloat = 0.3
    var canForceHide = true
    var priority: Int?
    var isLockTargetView = false {
        didSet{
            if isLockTargetView {
                strongTargetView = targetView
            } else {
                strongTargetView = nil
            }
        }
    }
    
    var isAnimatedForShadow = false { //是否存在阴影
        didSet{
            targetViewShadowOpacity = targetView.layer.shadowOpacity
            targetView.layer.shadowOpacity = 0
        }
    }
    
    var adjustWithKeyboard = false {
        didSet{
            if adjustWithKeyboard {
                keyBoardController = KeyBoardController(delegate: self)
                keyBoardController.addObserverForKeyBoard()
            }
        }
    }
    
    var animationStyle: AnimationStyle = .normal{
        didSet{
            switch self.animationStyle {
            case .normal:
                spring = 1
                initVelocity = 0
                showAnimateDuration = 0.5
                hideAnimateDuration = 0.5
            case .spring:
                spring = 0.7
                initVelocity = 0
                showAnimateDuration = 0.5
                hideAnimateDuration = 0.5
            }
        }
    }
    
    init(superView: UIView? = nil, targetView : UIView, viewPopDirection: ViewPopDirection = .none, maskStatus : MaskStatus = .normal){
        self.targetView = targetView
        self.maskStatus = maskStatus
        self.superView = superView ?? UIApplication.shared.keyWindow!
        self.viewPopDirection = viewPopDirection
        
        super.init()
        
        initMask(maskStatus)
        
        self.targetView.isHidden = true
        
        if superView == nil {
            PopViewManager.shared.add(popViewHelper: self)
        }
    }
    
    private func setPopViewDirection() {
        
        switch viewPopDirection{
            
        case .above:
            
            beginOrigin.x = 0
            //隐藏在上面
            beginOrigin.y = -targetView.frame.height
            
            showOrigin.x = 0
            showOrigin.y = 0
            
            if #available(iOS 11.0, *) {
                showOrigin.y += superView.safeAreaInsets.top
            }
            
            endOrigin = beginOrigin
            
        case .below:
            
            beginOrigin.x = 0
            //隐藏在下面
            beginOrigin.y = superView.frame.maxY
            
            showOrigin.x = 0
            
            showOrigin.y = superView.frame.height - targetView.frame.height
            
            if #available(iOS 11.0, *) {
                showOrigin.y -= superView.safeAreaInsets.bottom
            }
            
            endOrigin = beginOrigin
            
        case .belowToCenter:
            
            beginOrigin.x = superView.frame.width/2 - targetView.frame.width/2
            //隐藏在下面
            beginOrigin.y = superView.frame.maxY
            
            showOrigin.x = superView.frame.width/2 - targetView.frame.width/2
            showOrigin.y = superView.frame.height/2 - targetView.frame.height/2
            
            endOrigin = beginOrigin
            
        case .center:
            
            beginOrigin.x = superView.frame.maxX
            beginOrigin.y = superView.frame.height/2 - targetView.frame.height/2
            
            showOrigin.x = superView.frame.width/2 - targetView.frame.width/2
            showOrigin.y = superView.frame.height/2 - targetView.frame.height/2
            
            endOrigin.x = -superView.frame.width
            endOrigin.y = superView.frame.height/2 - targetView.frame.height/2
            
        case .onlyShowFullScreen:
            
            beginOrigin = CGPoint(x: 0, y: 0)
            showOrigin = beginOrigin
            endOrigin = beginOrigin
            
        case .fade:
            
            alpha = [0,1,0]
            beginOrigin.x = superView.frame.width/2 - targetView.frame.width/2
            beginOrigin.y = superView.frame.height/2 - targetView.frame.height/2
            showOrigin = beginOrigin
            endOrigin = beginOrigin
            
        case .belowWithPadding:
            
            beginOrigin.x = superView.frame.width/2 - targetView.frame.width/2
            beginOrigin.y = superView.frame.maxY
            
            showOrigin.x = beginOrigin.x
            showOrigin.y = superView.frame.height - targetView.frame.height - beginOrigin.x
            
            if #available(iOS 11.0, *) {
                showOrigin.y -= superView.safeAreaInsets.bottom
            }
            
            endOrigin = beginOrigin
            
        case .none:
            break
        }
    }
    
    private func setupUI(){
        
        targetView.frame.origin = beginOrigin
        targetView.alpha = alpha[0]
    }
    
    //初始化遮罩
    private func initMask(_ maskStatus: MaskStatus){
        
        if maskStatus == .hidden {
            return
        }
        
        mask = UIControl(frame: superView.bounds)
        mask!.alpha = 0
        
        let isTransparent = maskStatus == .transparent || maskStatus == .transparentAndDisable
        mask!.backgroundColor = isTransparent ? UIColor.clear : UIColor.black
        mask!.addTarget(self, action: #selector(PopViewHelper.onClickMask), for: .touchUpInside)
        
        superView.addSubview(mask!)
        
    }
    
    func cancelDelayHideIfNeeded() {
        
        guard delayHideTime != nil else { return }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        delayHideTime = nil
    }
    
    @objc func onClickMask() {
        
        if let _mask = mask {
            delegate?.popViewHelper?(self, didClickMask: _mask)
        }
        
        let clickEnable = maskStatus != .clickDisable && maskStatus != .transparentAndDisable
        guard clickEnable else { return }
        
        hidePoppingView()
        
    }
    
    func showPoppingViewInQueue(priority: Int = 500) {
        self.priority = priority
        PopViewManager.shared.enQueue(self)
    }
    
    //MARK: - Show
    func showPoppingView(_ animated: Bool = true) {
        
        animationTarget = .show
        
        guard !isAnimating else { return }
        guard !isShow else { return }
        
        setPopViewDirection()
        
        setupUI()
        
        if let _mask = mask{
            superView.bringSubview(toFront: _mask)
        }
        
        superView.addSubview(targetView)
        superView.bringSubview(toFront: targetView)
        targetView.isHidden = false
        isShow = true
        isAnimating = true
        
        if self.isAnimatedForShadow {
            self.targetView.layer.shadowOpacity = self.targetViewShadowOpacity
        }
        
        delegate?.popViewHelper?(self, willShowPoppingView: targetView)
        
        if animated {
            
            UIView.animate(
                withDuration: showAnimateDuration,
                delay: TimeInterval(0),
                usingSpringWithDamping: spring,
                initialSpringVelocity: initVelocity,
                options: UIViewAnimationOptions(),
                animations: self.showAction,
                completion: self.showCompletionAction())
            
        } else {
            
            showAction()
            showCompletionAction()(true)
        }
    }
    
    private func showAction() {
        
        self.mask?.alpha = self.maskAlpha
        self.targetView.frame.origin = CGPoint(x: self.showOrigin.x, y: self.showOrigin.y)
        self.targetView.alpha = self.alpha[1]
        self.delegate?.showAnimationBlock?(animatedTargetView: self.targetView)
        
    }
    
    private func showCompletionAction() -> (_ finish: Bool) -> Void {
        
        return { _ in
            
            self.isAnimating = false
            self.delegate?.popViewHelper?(self, didShowPoppingView: self.targetView)
            
            if self.animationTarget == .hide {
                self.hidePoppingView()
            } else {
                self.animationTarget = .unset
            }
            
        }
    }
    
    //MARK: - Hide
    func hidePoppingView(after delayTime: TimeInterval) {
        
        delayHideTime = delayTime
        
        hidePoppingViewDelayIfNeeded()
        
    }
    
    @objc func hidePoppingViewWithAnimated() {
        
        hidePoppingView()
    }
    
    func hidePoppingViewWithCancelDelay(_ animated: Bool = true) {
        
        cancelDelayHideIfNeeded()
        hidePoppingView(animated)
        
    }
    
    func hidePoppingViewDelayIfNeeded() {
        
        if let delayHideTime = delayHideTime {
            guard isShow else { return }
            perform(#selector(PopViewHelper.hidePoppingViewWithAnimated), with: nil, afterDelay: delayHideTime)
        }
    }
    
    //隐藏弹出窗口
    func hidePoppingView(_ animated: Bool = true){
        
        animationTarget = .hide
        
        guard !isAnimating else { return }
        guard isShow else { return }
        
        isAnimating = true
        
        delegate?.popViewHelper?(self, willHidePoppingView: targetView)
        
        if  adjustWithKeyboard {
            targetView.endEditing(true)
        }
        
        if self.isAnimatedForShadow {
            self.targetView.layer.shadowOpacity = 0
        }
        
        if animated {
            
            UIView.animate(
                withDuration: hideAnimateDuration,
                delay: 0,
                usingSpringWithDamping: spring,
                initialSpringVelocity: initVelocity,
                options: UIViewAnimationOptions(),
                animations: self.hideAction,
                completion: self.hideCompletionAction())
            
        } else {
            
            hideAction()
            hideCompletionAction()(true)
        }
    }
    
    private func hideAction() {
        
        self.mask?.alpha = 0
        self.targetView.frame.origin = CGPoint(x: self.endOrigin.x, y: self.endOrigin.y)
        self.targetView.alpha = self.alpha[2]
        self.delegate?.hideAnimationBlock?(animatedTargetView: self.targetView)
        
    }
    
    private func hideCompletionAction() -> (_ finished: Bool) -> Void {
        
        return { _ in
            
            self.isAnimating = false
            self.isShow = false
            self.targetView.isHidden = true
            self.targetView.removeFromSuperview()
            self.delegate?.popViewHelper?(self, didHidePoppingView: self.targetView)
            if self.priority != nil {
                PopViewManager.shared.deQueue(self)
            }
            if self.animationTarget == .show {
                self.showPoppingView()
            } else {
                self.animationTarget = .unset
            }
            
        }
    }
    
    deinit{
        mask?.removeFromSuperview()
        targetView?.removeFromSuperview()
        print("popViewHelper deinit")
    }
}

extension PopViewHelper: KeyBoardDelegate {
    func keyboardWillChange(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool) {
        
        guard adjustWithKeyboard else { return }
        guard self.isShow else { return }
        
        let alertViewYWhenKeyboardShowing = (UIScreen.main.bounds.height - keyboardFrame.height - targetView.frame.height) / 2
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: { () -> Void in
            
            self.targetView.frame.origin.y = isShow ? alertViewYWhenKeyboardShowing : self.showOrigin.y
            
            
        }) { _ in
            
        }
    }
}

