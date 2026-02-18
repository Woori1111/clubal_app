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

    // 비활성(OFF) 회색 — appearance proxy 는 뷰 생성 전에 설정해야 적용됨
    UITabBar.appearance().unselectedItemTintColor =
      UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1) // #A0A0A5

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
