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
    let black = UIColor(red: 28/255,  green: 28/255,  blue: 30/255,  alpha: 1) // #1C1C1E
    let gray  = UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1) // #A0A0A5

    // UITabBarItemStateAppearance 로 normal/selected 색상을 각각 명시
    // — SwiftUI .tint() 보다 우선순위가 높아 파란색 덮어쓰기 방지
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()

    appearance.stackedLayoutAppearance.normal.iconColor  = gray
    appearance.stackedLayoutAppearance.normal.titleTextAttributes  = [.foregroundColor: gray]
    appearance.stackedLayoutAppearance.selected.iconColor = black
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: black]

    UITabBar.appearance().standardAppearance    = appearance
    UITabBar.appearance().scrollEdgeAppearance  = appearance
    UITabBar.appearance().tintColor             = black   // 추가 보장
    UITabBar.appearance().unselectedItemTintColor = gray
  }
}
