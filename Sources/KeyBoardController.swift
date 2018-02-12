//
//  KeyBoardManager.swift
//  PopBaseView
//
//  Created by ty on 15/9/23.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import UIKit
import Foundation

protocol KeyBoardDelegate: NSObjectProtocol {
  func keyboardWillChange(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool)
}

class KeyBoardController: NSObject {
  
  weak var delegate: KeyBoardDelegate?
  var isShow: Bool = false
  fileprivate var textFieldList: [UITextField] = []
  fileprivate var scrollView: UIScrollView?
  fileprivate var originContentOffset: CGPoint?
  
  init(scrollView: UIScrollView, textFieldList: [UITextField]) {
    
    self.scrollView = scrollView
    self.textFieldList = textFieldList
    super.init()
    
    addTapForScrollView(self.scrollView!)
  }
  
  init(delegate: KeyBoardDelegate) {
    self.delegate = delegate
    super.init()
  }
  
  deinit{
    
    NotificationCenter.default.removeObserver(self)
    
  }
  
  func addObserverForKeyBoard() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillAppearNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidAppearNotification(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidHideNotification(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
  }
  
  
  @objc func handleKeyboardWillAppearNotification(_ notification: Notification) {
    
    isShow = true
    keyBoardWillChange(notification)
  }
  
  @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
    
    if isShow {
      isShow = false
      keyBoardWillChange(notification)
    }
    
  }
  
  @objc func handleKeyboardDidAppearNotification(_ notification: Notification) {
  }
  
  @objc func handleKeyboardDidHideNotification(_ notification: Notification) {
  }
  
  func keyBoardWillChange(_ notification: Notification) {
    
    if let keyBoradInfoDic = notification.userInfo {
      let keyBoardFrame = (keyBoradInfoDic[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
      let duration = keyBoradInfoDic[UIKeyboardAnimationDurationUserInfoKey] as! Double
      let curve = keyBoradInfoDic[UIKeyboardAnimationCurveUserInfoKey] as! Int
      
      let animationOptions = UIViewAnimationOptions(rawValue: UInt(curve << 16))
      
      delegate?.keyboardWillChange(keyBoardFrame, animationDuration: duration, animationOptions: animationOptions, isShow: notification.name == NSNotification.Name.UIKeyboardWillShow)
      adjustScrollViewContentOffsetWith(keyBoardFrame, animationDuration: duration, animationOptions: curve, isShow: notification.name == NSNotification.Name.UIKeyboardWillShow)
    }
  }
  
  /******************************************************************************
   *  adjust scrollView with textfield
   ******************************************************************************/
  //MARK: - adjust scrollView with textfield
  
  fileprivate func addTapForScrollView(_ scrollView: UIScrollView) {
    
    let tap = scrollView.pop_addTapGestureTarget(self, action: #selector(KeyBoardController.onTouchScrollView))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1
    
  }
  
  @objc func onTouchScrollView() {
    
    scrollView?.endEditing(true)
    
  }
  
  func registerScrollView(_ scrollView: UIScrollView) {
    self.scrollView = scrollView
    addTapForScrollView(self.scrollView!)
    
  }
  
  func addObserverToTextField(_ textFieldList: [UITextField]) {
    self.textFieldList = textFieldList
  }
  
  fileprivate func adjustScrollViewContentOffsetWith(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: Int, isShow: Bool) {
    
    guard let _scrollView = scrollView else { return }
    guard !textFieldList.isEmpty else { return }
    
    if isShow {
      
      //保存原始contentOffset，因为弹出键盘的时候contentOffset不一定为0
      if originContentOffset == nil {
        originContentOffset = _scrollView.contentOffset
      }
      
      for textField in textFieldList {
        
        if !textField.isEditing {
          continue
        }
        
        let textFieldFrameInScreen = textField.superview!.convert(textField.frame, to: nil)
        
        //如果点击了一个不需要改变contentoffset的textfield，则把contentoffset还原，目测在ios8木有用，打开键盘的时候不会在发一次通知
        guard keyboardFrame.minY < textFieldFrameInScreen.maxY else {
          
          _scrollView.setContentOffset(originContentOffset!, animated: true)
          return
        }
        
        _scrollView.setContentOffset(CGPoint(x: 0, y: textFieldFrameInScreen.maxY - keyboardFrame.minY + originContentOffset!.y), animated: true)
        
      }
      
    } else {
      
      guard let _originContentOffset = originContentOffset else { return }
      _scrollView.setContentOffset(_originContentOffset, animated: true)
      originContentOffset = nil
      
    }
  }
}

extension UIView {
    func pop_addTapGestureTarget(_ target: AnyObject?, action: Selector) -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
        return tapGesture
    }
}
