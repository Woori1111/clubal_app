import Flutter
import SwiftUI
import UIKit

/// iOS 전용. Flutter가 하단까지 그리도록 호스팅 컨트롤러 safe area 상쇄.
final class FullFrameHostContainer: UIViewController {
  private let hostingController: UIHostingController<LiquidRoot>

  init(hostingController: UIHostingController<LiquidRoot>) {
    self.hostingController = hostingController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .black
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.view.frame = view.bounds
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingController.didMove(toParent: self)
    applyFullFrameInsets()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    applyFullFrameInsets()
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    applyFullFrameInsets()
  }

  private func applyFullFrameInsets() {
    hostingController.additionalSafeAreaInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: -view.safeAreaInsets.bottom, right: 0
    )
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let engine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine

    let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    flutterVC.additionalSafeAreaInsets = .zero
    flutterVC.view.backgroundColor = .black

    let hosting = UIHostingController(rootView: LiquidRoot(flutterViewController: flutterVC, engine: engine))
    hosting.view.backgroundColor = .black
    hosting.view.clipsToBounds = false

    let container = FullFrameHostContainer(hostingController: hosting)
    let window = UIWindow(windowScene: windowScene)
    window.backgroundColor = .black
    window.rootViewController = container
    self.window = window
    window.makeKeyAndVisible()
  }
}
