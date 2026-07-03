//
//  CocoaDebugWindowManager.swift
//  CocoaDebug
//
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

/// Central manager for CocoaDebug window lifecycle.
/// Does NOT modify host app windows or rootViewController.
@objc public class CocoaDebugWindowManager: NSObject {

    @objc public static let shared = CocoaDebugWindowManager()

    // MARK: - Properties

    private var bubbleWindow: CocoaDebugWindow?
    private var panelWindow: CocoaDebugWindow?

    private var bubbleVC: CocoaDebugViewController?

    private var desiredBubbleVisible = false
    private var desiredPanelVisible = false

    private var isEnabled = false

    private let accessibilityPrefix = "com.cocoadebug.window"

    // MARK: - Public API

    @objc public func start() {
        guard !isEnabled else { return }
        isEnabled = true

        if desiredBubbleVisible {
            showBubble()
        }
    }

    @objc public func stop() {
        isEnabled = false
        hideBubble()
        hidePanel()
    }

    @objc public func showBubble() {
        desiredBubbleVisible = true

        // Auto-start if not yet enabled — Settings.showBubbleAndWindow triggers this
        // before start() is explicitly called.
        if !isEnabled {
            isEnabled = true
        }

        if bubbleWindow == nil {
            createBubbleWindow()
        }
        bubbleWindow?.isHidden = false
    }

    @objc public func hideBubble() {
        desiredBubbleVisible = false
        bubbleWindow?.rootViewController = nil
        bubbleWindow?.delegate = nil
        bubbleWindow?.isHidden = true
        bubbleWindow = nil
        bubbleVC = nil
    }

    @objc public func showPanel() {
        desiredPanelVisible = true
        guard isEnabled, let bubbleVC = bubbleVC else { return }

        WindowHelper.shared.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: CocoaDebug.self))
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        vc.view.backgroundColor = .white
        vc.modalPresentationStyle = .fullScreen
        bubbleVC.present(vc, animated: true, completion: nil)
    }

    @objc public func hidePanel() {
        desiredPanelVisible = false
        guard let bubbleVC = bubbleVC else { return }
        if bubbleVC.presentedViewController != nil {
            bubbleVC.dismiss(animated: true, completion: nil)
        }
        WindowHelper.shared.displayedList = false
    }

    /// Reset the floating ball position to a safe default within screen bounds.
    @objc public func resetFloatingBallState() {
        CocoaDebugSettings.shared.bubbleFrameX = 0
        CocoaDebugSettings.shared.bubbleFrameY = 0

        guard let bubble = bubbleVC?.bubble else { return }
        let safePosition = safeBubblePosition()
        bubble.center = safePosition
        CocoaDebugSettings.shared.bubbleFrameX = Float(safePosition.x)
        CocoaDebugSettings.shared.bubbleFrameY = Float(safePosition.y)
    }

    // MARK: - Scene Lifecycle

    @available(iOS 13.0, *)
    @objc public func handleSceneDidActivate(_ scene: UIScene) {
        guard isEnabled, desiredBubbleVisible else { return }
        if bubbleWindow == nil {
            createBubbleWindowScene(assignScene: true)
        }
    }

    @objc public func handleDidEnterBackground() {
        hidePanel()
    }

    @objc public func handleWillEnterForeground() {
        guard isEnabled, desiredBubbleVisible else { return }
        if bubbleWindow == nil || bubbleWindow?.isHidden == true {
            createBubbleWindow()
        }
    }

    // MARK: - Window Creation

    private func createBubbleWindow() {
        if #available(iOS 13.0, *) {
            createBubbleWindowScene(assignScene: false)
        } else {
            createBubbleWindowLegacy()
        }
    }

    @available(iOS 13.0, *)
    private func createBubbleWindowScene(assignScene: Bool) {
        let windowScene = anyAvailableScene()
        let useScene = assignScene ? windowScene : windowScene

        // On iOS 13+, UIWindow needs a windowScene. If no scene is available yet
        // (e.g. during UIApplicationDidFinishLaunchingNotification before scene activation),
        // create the window with any connected scene — it will work once the scene activates.
        // Only register for deferred creation if there are zero scenes at all.
        guard let scene = useScene else {
            // No scene exists yet. Register one-shot observer for when one appears.
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if self.bubbleWindow == nil && self.desiredBubbleVisible {
                    self.createBubbleWindow()
                }
                if let token = token {
                    NotificationCenter.default.removeObserver(token)
                }
            }
            return
        }

        let vc = CocoaDebugViewController()
        bubbleVC = vc

        let window = CocoaDebugWindow(frame: scene.coordinateSpace.bounds)
        window.windowScene = scene
        window.accessibilityIdentifier = "\(accessibilityPrefix).bubble"
        window.bounds.size.height = scene.coordinateSpace.bounds.height.nextDown
        window.rootViewController = vc
        window.delegate = WindowHelper.shared
        window.isHidden = false
        bubbleWindow = window

        if CocoaDebugSettings.shared.enableUIBlockingMonitoring == true {
            WindowHelper.shared.startUIBlockingMonitoring()
        }
    }

    private func createBubbleWindowLegacy() {
        let vc = CocoaDebugViewController()
        bubbleVC = vc

        let window = CocoaDebugWindow(frame: UIScreen.main.bounds)
        window.accessibilityIdentifier = "\(accessibilityPrefix).bubble"
        window.bounds.size.height = UIScreen.main.bounds.height.nextDown
        window.rootViewController = vc
        window.delegate = WindowHelper.shared
        window.isHidden = false
        bubbleWindow = window

        if CocoaDebugSettings.shared.enableUIBlockingMonitoring == true {
            WindowHelper.shared.startUIBlockingMonitoring()
        }
    }

    // MARK: - Scene Helpers

    @available(iOS 13.0, *)
    private func anyAvailableScene() -> UIWindowScene? {
        // Prefer foregroundActive
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if scene.activationState == .foregroundActive {
                return windowScene
            }
        }
        // Then foregroundInactive
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if scene.activationState == .foregroundInactive {
                return windowScene
            }
        }
        // Then any UIWindowScene (e.g. .background during launch — will work once scene activates)
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                return windowScene
            }
        }
        return nil
    }

    /// Compute a safe bubble position within the current screen bounds.
    private func safeBubblePosition() -> CGPoint {
        var safeInsets = UIEdgeInsets.zero
        if #available(iOS 13.0, *) {
            if let scene = anyAvailableScene() {
                safeInsets = scene.windows.first?.safeAreaInsets ?? .zero
            }
        } else if #available(iOS 11.0, *) {
            safeInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }

        let screenBounds: CGRect
        if #available(iOS 13.0, *) {
            if let scene = anyAvailableScene() {
                screenBounds = scene.coordinateSpace.bounds
            } else {
                screenBounds = UIScreen.main.bounds
            }
        } else {
            screenBounds = UIScreen.main.bounds
        }

        let bubbleWidth = Bubble.size.width
        let bubbleHeight = Bubble.size.height
        let halfWidth = bubbleWidth / 2
        let halfHeight = bubbleHeight / 2

        let x = max(halfWidth, min(screenBounds.width - halfWidth, screenBounds.width / 2))
        let y = max(halfHeight + safeInsets.top, min(screenBounds.height - halfHeight - safeInsets.bottom,
                                                     screenBounds.height / 2))

        return CGPoint(x: x, y: y)
    }

    // MARK: - Internal helpers

    internal func currentBubbleVC() -> CocoaDebugViewController? {
        return bubbleVC
    }
}
