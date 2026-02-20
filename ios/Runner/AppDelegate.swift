import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  let flutterEngine = FlutterEngine(name: "clubal_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    flutterEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)
    configureTabBarAppearance()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureTabBarAppearance() {
    // 앱에 화이트 테마 없음 — 전역 탭바도 다크/투명으로 설정해 어디서든 흰색이 안 나오도록
    let fg = UIColor(red: 230/255, green: 237/255, blue: 243/255, alpha: 1)
    let dim = UIColor(red: 139/255, green: 148/255, blue: 158/255, alpha: 1)

    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    if #available(iOS 13.0, *) {
      appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
    } else {
      appearance.backgroundEffect = UIBlurEffect(style: .dark)
    }
    appearance.backgroundColor = UIColor.black.withAlphaComponent(0.25)

    appearance.stackedLayoutAppearance.normal.iconColor = dim
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: dim]
    appearance.stackedLayoutAppearance.selected.iconColor = fg
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: fg]

    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
    UITabBar.appearance().tintColor = fg
    UITabBar.appearance().unselectedItemTintColor = dim
  }
}
