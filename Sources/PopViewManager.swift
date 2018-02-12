//
//  PopViewManager.swift
//  PopBaseView
//
//  Created by ty on 2017/6/29.
//  Copyright © 2017年 tangyi.ml. All rights reserved.
//

import Foundation

class PopViewManager {
  
  static let shared = PopViewManager()
  
  private(set) var popViewHelperContainers: [PopViewHelperContainer] = []
  private(set) var popViewHelperQueue: [PopViewHelper] = []
  private weak var showingPoppingViewHelper: PopViewHelper?
  
  func add(popViewHelper: PopViewHelper) {
    
    clearReleased()
    
    popViewHelperContainers.append(PopViewHelperContainer(popViewHelper: popViewHelper))
  }
  
  func hideAll(for targetType: PopBaseView.Type) {
    popViewHelperContainers.forEach { (container) in
      guard let helper = container.popViewHelper else { return }
      guard type(of: helper.targetView as AnyObject) === targetType, helper.canForceHide else { return }
      helper.hidePoppingView()
    }
    clearReleased()
  }

  func hideAll() {
    
    popViewHelperContainers.forEach { popViewHelperContainer in
      
      guard let popViewHelper = popViewHelperContainer.popViewHelper else { return }
      guard popViewHelper.canForceHide else { return }
      popViewHelper.hidePoppingView()
    }
    
    clearReleased()
  }
  
  func enQueue(_ popViewHelper: PopViewHelper) {
    
    if showingPoppingViewHelper == nil {
      popViewHelper.showPoppingView()
      showingPoppingViewHelper = popViewHelper
    } else {
      popViewHelper.isLockTargetView = true
    }
    
    popViewHelperQueue.append(popViewHelper)
  }
  
  func deQueue(_ popViewHelper: PopViewHelper) {
    
    if let index = popViewHelperQueue.index(where: { $0 == popViewHelper }) {
      popViewHelper.isLockTargetView = false
      popViewHelperQueue.remove(at: index)
      showingPoppingViewHelper = nil
      showInQueue()
    }
  }
  
  private func showInQueue() {
    
    showingPoppingViewHelper = popViewHelperQueue.max{ (popViewHelper1, popViewHelper2) -> Bool in
      
      guard let priority1 = popViewHelper1.priority else { return false }
      guard let priority2 = popViewHelper2.priority else { return false }
      
      return priority1 < priority2
    }
    
    showingPoppingViewHelper?.showPoppingView()
    showingPoppingViewHelper?.hidePoppingViewDelayIfNeeded()
    
  }
  
  private func clearReleased() {
    
    for (index, element) in popViewHelperContainers.enumerated().reversed() {
      if element.popViewHelper == nil {
        popViewHelperContainers.remove(at: index)
      }
    }
  }
}

class PopViewHelperContainer {
  weak var popViewHelper: PopViewHelper?
  
  init(popViewHelper: PopViewHelper) {
    self.popViewHelper = popViewHelper
  }
}

