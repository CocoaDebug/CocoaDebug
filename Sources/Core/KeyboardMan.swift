//
//  KeyboardMan.swift
//  Messages
//
//  Created by NIX on 15/7/25.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit

final public class KeyboardMan {

    var keyboardObserver: NotificationCenter? {
        didSet {
            oldValue?.removeObserver(self)
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
            keyboardObserver?.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
            keyboardObserver?.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
        }
    }

    public var keyboardObserveEnabled = false {
        willSet {
            if newValue != keyboardObserveEnabled {
                keyboardObserver = newValue ? .default : nil
            }
        }
    }

    deinit {
        // willSet and didSet are not called when deinit, so...
        NotificationCenter.default.removeObserver(self)
    }

    public init() {
        
    }

    public struct KeyboardInfo {
        public let animationDuration: TimeInterval
        public let animationCurve: UInt
        public let frameBegin: CGRect
        public let frameEnd: CGRect
        public var height: CGFloat {
            return frameEnd.height
        }
        public let heightIncrement: CGFloat
        public enum Action {
            case show
            case hide
        }
        public let action: Action
        let isSameAction: Bool
    }

    public private(set) var appearPostIndex = 0

    public private(set) var keyboardInfo: KeyboardInfo? {
        didSet {
            guard UIApplication.isNotInBackground else { return }
            guard let info = keyboardInfo else { return }
            if !info.isSameAction || info.heightIncrement != 0 {
                // do convenient animation
                let duration = info.animationDuration
                let curve = info.animationCurve
                let options = UIViewAnimationOptions(rawValue: curve << 16 | UIViewAnimationOptions.beginFromCurrentState.rawValue)
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    switch info.action {
                    case .show:
                        strongSelf.animateWhenKeyboardAppear?(strongSelf.appearPostIndex, info.height, info.heightIncrement)
                        strongSelf.appearPostIndex += 1
                    case .hide:
                        strongSelf.animateWhenKeyboardDisappear?(info.height)
                        strongSelf.appearPostIndex = 0
                    }
                }, completion: nil)
                // post full info
                postKeyboardInfo?(self, info)
            }
        }
    }

    public var animateWhenKeyboardAppear: ((_ appearPostIndex: Int, _ keyboardHeight: CGFloat, _ keyboardHeightIncrement: CGFloat) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    public var animateWhenKeyboardDisappear: ((_ keyboardHeight: CGFloat) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    public var postKeyboardInfo: ((_ keyboardMan: KeyboardMan, _ keyboardInfo: KeyboardInfo) -> Void)? {
        didSet {
            keyboardObserveEnabled = true
        }
    }

    // MARK: - Actions

    private func handleKeyboard(_ notification: Notification, _ action: KeyboardInfo.Action) {
        guard let userInfo = notification.userInfo else { return }
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue
        let frameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let currentHeight = frameEnd.height
        let previousHeight = keyboardInfo?.height ?? 0
        let heightIncrement = currentHeight - previousHeight
        let isSameAction: Bool
        if let previousAction = keyboardInfo?.action {
            isSameAction = (action == previousAction)
        } else {
            isSameAction = false
        }
        keyboardInfo = KeyboardInfo(
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            frameBegin: frameBegin,
            frameEnd: frameEnd,
            heightIncrement: heightIncrement,
            action: action,
            isSameAction: isSameAction
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard UIApplication.isNotInBackground else { return }
        handleKeyboard(notification, .show)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard UIApplication.isNotInBackground else { return }
        if let keyboardInfo = keyboardInfo, keyboardInfo.action == .show {
            handleKeyboard(notification, .show)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard UIApplication.isNotInBackground else { return }
        handleKeyboard(notification, .hide)
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        guard UIApplication.isNotInBackground else { return }
        keyboardInfo = nil
    }
}

extension UIApplication {
    // Return UIApplication.shared in an app target, `nil` in an app extension target.
    private static let sharedOrNil: UIApplication? = {
        let selector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: selector) else { return nil }
        let application = UIApplication.perform(selector).takeUnretainedValue() as? UIApplication
        // The appDelegate is nil, normally it is in app extension context.  
        guard let _ = application?.delegate else { return nil }
        return application
    }()

    static var isNotInBackground: Bool {
        return sharedOrNil?.applicationState != .background
    }
}
