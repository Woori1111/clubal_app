import Flutter
import SwiftUI
import UIKit

/// iOS 전용: Flutter가 화면 끝까지 그리도록 하단 Safe Area를 상쇄.
/// SwiftUI가 전체 높이를 쓰므로 Flutter·탭바 오버레이가 겹치지 않고, 탭바 외 영역은 Flutter만 보임(투명).
final class FullFrameHostContainer: UIViewController {
  private let hostingController: UIHostingController<LiquidRoot>

  init(hostingController: UIHostingController<LiquidRoot>) {
    self.hostingController = hostingController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    view.isOpaque = false
    view.layer.backgroundColor = nil
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
    let bottomInset = view.safeAreaInsets.bottom
    hostingController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: -bottomInset, right: 0)
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
    flutterVC.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
    // 투명: 탭바 바깥은 스크롤 시 뒤 컨텐츠가 보이도록
    flutterVC.view.backgroundColor = .clear
    flutterVC.view.isOpaque = false
    flutterVC.view.layer.backgroundColor = nil

    let hostingController = UIHostingController(rootView: LiquidRoot(flutterViewController: flutterVC, engine: engine))
    hostingController.view.backgroundColor = .clear
    hostingController.view.isOpaque = false
    hostingController.view.layer.backgroundColor = nil

    let container = FullFrameHostContainer(hostingController: hostingController)

    let window = UIWindow(windowScene: windowScene)
    window.backgroundColor = .clear
    window.isOpaque = false
    window.rootViewController = container
    self.window = window
    window.makeKeyAndVisible()

    // #region agent log
    let debugChannel = FlutterMethodChannel(name: "com.clubal.app/debug", binaryMessenger: engine.binaryMessenger)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      debugChannel.invokeMethod("log", arguments: [
        "message": "SceneDelegate colors",
        "hypothesisId": "H1",
        "data": [
          "flutterViewBg": String(describing: flutterVC.view.backgroundColor as Any),
          "flutterViewOpaque": flutterVC.view.isOpaque,
          "windowBg": String(describing: window.backgroundColor as Any),
          "hostingBg": String(describing: hostingController.view.backgroundColor as Any),
        ] as [String: Any]
      ])
    }
    // #endregion
  }
}
