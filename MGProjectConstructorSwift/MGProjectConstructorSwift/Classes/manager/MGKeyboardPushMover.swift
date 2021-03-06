//
//  MGKeyboardPushMover.swift
//
//  Created by Magical Water on 2018/3/2.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

/*
 當鍵盤出現時, 整個 vc 往上推
 推動的方式是更改對應vc的下方contraint
 因此需要帶入下方約束
 */
public class MGKeyboardPushMover: NSObject {

    private weak var vc: UIViewController?
    private weak var bc: NSLayoutConstraint?

    public override init() {}

    //註冊 會因為 keyboard 而推動螢幕的vc
    public func registerVC(_ vc: UIViewController, _ bottomConstraint: NSLayoutConstraint) {
        unregisterVC()
        self.vc = vc
        self.bc = bottomConstraint
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    public func unregisterVC() {
        if let v = vc { NotificationCenter.default.removeObserver(v) }
    }

    @objc private func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bc?.constant = 0.0
            } else {
                self.bc?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.vc?.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    private func findFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews {
            if subView.isFirstResponder { return subView }
            if let recursiveSubView = self.findFirstResponder(inView: subView) {
                return recursiveSubView
            }
        }
        return nil
    }


    deinit {
        unregisterVC()
    }

}



