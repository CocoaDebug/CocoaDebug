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
        // Re-assign the active scene to our window
        if let windowScene = scene as? UIWindowScene, let bw = bubbleWindow {
            bw.windowScene = windowScene
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
        let vc = CocoaDebugViewController()
        bubbleVC = vc

        // Create the window immediately with UIScreen.main.bounds.
        // On iOS 13+, we'll assign a windowScene below if available.
        // If no scene is available yet, the window still exists and will
        // be picked up by the system when a scene activates.
        let window = CocoaDebugWindow(frame: UIScreen.main.bounds)
        window.accessibilityIdentifier = "\(accessibilityPrefix).bubble"
        window.bounds.size.height = UIScreen.main.bounds.height.nextDown
        window.rootViewController = vc
        window.delegate = WindowHelper.shared
        window.isHidden = false
        bubbleWindow = window

        // On iOS 13+, try to assign a windowScene. Use any available scene
        // (not just foregroundActive) since at launch time the scene may
        // still be in .background state.
        if #available(iOS 13.0, *) {
            assignBestScene(to: window)
        }

        if CocoaDebugSettings.shared.enableUIBlockingMonitoring == true {
            WindowHelper.shared.startUIBlockingMonitoring()
        }
    }

    @available(iOS 13.0, *)
    private func assignBestScene(to window: CocoaDebugWindow) {
        if let scene = anyAvailableScene() {
            window.windowScene = scene
        }
        // If no scene is available, the window is still created and visible.
        // The host app should forward scene activation via handleSceneDidActivate.
    }

    // MARK: - Scene Helpers

    @available(iOS 13.0, *)
    private func anyAvailableScene() -> UIWindowScene? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if scene.activationState == .foregroundActive {
                return windowScene
            }
        }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if scene.activationState == .foregroundInactive {
                return windowScene
            }
        }
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
