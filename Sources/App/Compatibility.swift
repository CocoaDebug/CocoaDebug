//
//  Compatibility.swift
//  Example_Swift
//
//  Created by Damon on 2018/12/21.
//  Copyright © 2018 liman. All rights reserved.
//

import Foundation
import MapKit
import UserNotifications

#if swift(>=4.2)
    
    @available(iOS 10.0, *)
    extension UNNotificationSound {
        public static var defaultSound: UNNotificationSound {
            return .default
        }
    }
    
#else
    
    public struct CAMediaTimingFunctionName {
        public static var linear: String {
            return kCAMediaTimingFunctionLinear
        }
    }
    
    public struct CAShapeLayerLineCap {
        public static var round: String {
            return kCALineCapRound
        }
    }
    
    extension CGRect {
        public func inset(by insets: UIEdgeInsets) -> CGRect {
            return UIEdgeInsetsInsetRect(self, insets)
        }
    }
    
    extension MKCoordinateRegion {
        public init(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
            self = MKCoordinateRegionMakeWithDistance(center, latitudinalMeters, longitudinalMeters)
        }
    }
    
    extension NSCoder {
        public static func cgPoint(for string: String) -> CGPoint {
            return CGPointFromString(string)
        }
        
        public static func cgRect(for string: String) -> CGRect {
            return CGRectFromString(string)
        }
        
        public static func cgSize(for string: String) -> CGSize {
            return CGSizeFromString(string)
        }
        
        public static func string(for point: CGPoint) -> String {
            return NSStringFromCGPoint(point)
        }
        
        public static func string(for rect: CGRect) -> String {
            return NSStringFromCGRect(rect)
        }
        
        public static func string(for size: CGSize) -> String {
            return NSStringFromCGSize(size)
        }
    }
    
    extension NSLayoutConstraint {
        public typealias Attribute = NSLayoutAttribute
        public typealias Relation = NSLayoutRelation
    }
    
    extension NSUnderlineStyle {
        public static var none: NSUnderlineStyle {
            return .styleNone
        }
        
        public static var single: NSUnderlineStyle {
            return .styleSingle
        }
    }
    
    extension RunLoopMode {
        public static var tracking: RunLoopMode {
            return UITrackingRunLoopMode
        }
        
        public static var common: RunLoopMode {
            return .commonModes
        }
    }
    
    extension NSAttributedString {
        public typealias Key = NSAttributedStringKey
    }
    
    extension NSLayoutConstraint {
        public typealias Axis = UILayoutConstraintAxis
    }
    
    extension UIActivityIndicatorView {
        public convenience init(style: UIActivityIndicatorViewStyle) {
            self.init(activityIndicatorStyle: style)
        }
        
        public var style: UIActivityIndicatorViewStyle {
            get { return self.activityIndicatorViewStyle }
            set { self.activityIndicatorViewStyle = newValue }
        }
    }
    
    extension UIAlertAction {
        public typealias Style = UIAlertActionStyle
    }
    
    extension UIApplication {
        public static var backgroundFetchIntervalMinimum: TimeInterval {
            return UIApplicationBackgroundFetchIntervalMinimum
        }
        
        public static var backgroundFetchIntervalNever: TimeInterval {
            return UIApplicationBackgroundFetchIntervalNever
        }
        
        public static var didChangeStatusBarOrientationNotification: Notification.Name {
            return .UIApplicationDidChangeStatusBarOrientation
        }
        
        public static var didReceiveMemoryWarningNotification: Notification.Name {
            return .UIApplicationDidReceiveMemoryWarning
        }
        
        public static var openSettingsURLString: String {
            return UIApplicationOpenSettingsURLString
        }
        
        public static var willEnterForegroundNotification: Notification.Name {
            return .UIApplicationWillEnterForeground
        }
    }
    
    extension UIBarButtonItem {
        public typealias Style = UIBarButtonItemStyle
    }
    
    extension UIButton {
        public typealias ButtonType = UIButtonType
    }
    
    extension UIControl {
        public typealias Event = UIControlEvents
    }
    
    extension UIFont {
        public typealias TextStyle = UIFontTextStyle
    }
    
    extension UIImage {
        public func pngData() -> Data? {
            return UIImagePNGRepresentation(self)
        }

        func jpegData(compressionQuality: CGFloat) -> Data? {
            return UIImageJPEGRepresentation(self, 1)
        }
    }
    
    extension UINavigationController {
        public typealias Operation = UINavigationControllerOperation
    }
    
    extension UIResponder {
        public static var keyboardDidShowNotification: Notification.Name {
            return .UIKeyboardDidShow
        }
        
        public static var keyboardFrameEndUserInfoKey: String {
            return UIKeyboardFrameEndUserInfoKey
        }
        
        public static var keyboardWillChangeFrameNotification: Notification.Name {
            return .UIKeyboardWillChangeFrame
        }
        
        public static var keyboardWillHideNotification: Notification.Name {
            return .UIKeyboardWillHide
        }
    }
    
    extension UISegmentedControl {
        public static var noSegment: Int {
            return UISegmentedControlNoSegment
        }
    }
    
    extension UITableView {
        public typealias ScrollPosition = UITableViewScrollPosition
        public typealias Style = UITableViewStyle
        
        public static var automaticDimension: CGFloat {
            return UITableViewAutomaticDimension
        }
        
        public static var indexSearch: String {
            return UITableViewIndexSearch
        }
    }
    
    extension UITableViewCell {
        public typealias AccessoryType = UITableViewCellAccessoryType
        public typealias CellStyle = UITableViewCellStyle
        public typealias EditingStyle = UITableViewCellEditingStyle
        public typealias SelectionStyle = UITableViewCellSelectionStyle
    }
    
    extension UITextField {
        public typealias ViewMode = UITextFieldViewMode
        
        public static var textDidBeginEditingNotification: Notification.Name {
            return .UITextFieldTextDidBeginEditing
        }
        
        public static var textDidChangeNotification: Notification.Name {
            return .UITextFieldTextDidChange
        }
        
        public static var textDidEndEditingNotification: Notification.Name {
            return .UITextFieldTextDidEndEditing
        }
    }
    
    extension UITextView {
        public static var textDidChangeNotification: Notification.Name {
            return .UITextViewTextDidChange
        }
        
        public static var textDidEndEditingNotification: Notification.Name {
            return .UITextViewTextDidEndEditing
        }
    }
    
    @available(iOS 9.0, *)
    extension UITouch {
        public typealias TouchType = UITouchType
    }
    
    extension UIView {
        public typealias AutoresizingMask = UIViewAutoresizing
        public typealias ContentMode = UIViewContentMode
        
        public func bringSubviewToFront(_ view: UIView) {
            self.bringSubview(toFront: view)
        }
        
        public static var layoutFittingCompressedSize: CGSize {
            return UILayoutFittingCompressedSize
        }
        
        public func sendSubviewToBack(_ view: UIView) {
            self.sendSubview(toBack: view)
        }
    }
    
    extension UIViewController {
        public func addChild(_ viewController: UIViewController) {
            self.addChildViewController(viewController)
        }
        
        public func didMove(toParent viewController: UIViewController?) {
            self.didMove(toParentViewController: viewController)
        }
        
        public var isMovingFromParent: Bool {
            return self.isMovingFromParentViewController
        }
        
        public var isMovingToParent: Bool {
            return self.isMovingToParentViewController
        }
        
        public func removeFromParent() {
            return self.removeFromParentViewController()
        }
        
        public func willMove(toParent viewController: UIViewController?) {
            self.willMove(toParentViewController: viewController)
        }
    }
    
    @available(iOS 10.0, *)
    extension UNNotificationSound {
        public static var defaultSound: UNNotificationSound {
            return .default()
        }
    }
    
    extension UIEvent {
        public typealias EventSubtype = UIEventSubtype
    }
    
    extension UIApplication {
        public typealias LaunchOptionsKey = UIApplicationLaunchOptionsKey
    }
    
#endif
