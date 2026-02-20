import Flutter
import SwiftUI
import UIKit

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
    // Flutter 가 네이티브 탭바 높이(49pt)를 safe area 로 인식하도록 설정
    // → Flutter SafeArea 위젯이 탭바 위에 콘텐츠를 배치한다
    flutterVC.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)

    let hostingController = UIHostingController(rootView: LiquidRoot(flutterViewController: flutterVC, engine: engine))
    // 다른 화면 갔다 나올 때 흰색 깜빡임 방지 — 앱에 화이트 테마 없으므로 루트를 검정으로 고정
    hostingController.view.backgroundColor = .black
    hostingController.view.layer.backgroundColor = UIColor.black.cgColor

    let window = UIWindow(windowScene: windowScene)
    window.backgroundColor = .black
    window.rootViewController = hostingController
    self.window = window
    window.makeKeyAndVisible()
  }
}
