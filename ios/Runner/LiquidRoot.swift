import Flutter
import SwiftUI
import UIKit

// MARK: - LiquidRoot

struct LiquidRoot: View {

  private let flutterViewController: FlutterViewController
  private let navChannel: FlutterMethodChannel

  @State private var selectedTab = 0

  init(flutterViewController: FlutterViewController, engine: FlutterEngine) {
    self.flutterViewController = flutterViewController
    self.navChannel = FlutterMethodChannel(
      name: "com.clubal.app/navigation",
      binaryMessenger: engine.binaryMessenger
    )
  }

  var body: some View {
    ZStack {
      // Flutter 가 전체 화면을 채운다
      FlutterViewRepresentable(viewController: flutterViewController)
        .ignoresSafeArea()

      // 네이티브 TabView — 탭바 UI 만 필요하고 콘텐츠 영역은 투명해야 한다
      TabView(selection: tabBinding) {
        // ★ 첫 번째 탭에만 TabBarFixer 삽입 (UITabBar 직접 접근)
        Color.clear
          .background(TabBarFixer())
          .tabItem { Image(systemName: "house.fill");    Text("홈")  }.tag(0)
        Color.clear
          .tabItem { Image(systemName: "person.2.fill"); Text("매칭") }.tag(1)
        Color.clear
          .tabItem { Image(systemName: "bubble.fill");   Text("채팅") }.tag(2)
        Color.clear
          .tabItem { Image(systemName: "sparkles");      Text("파티") }.tag(3)
        Color.clear
          .tabItem { Image(systemName: "line.3.horizontal"); Text("메뉴") }.tag(4)
      }
    }
    .ignoresSafeArea()
  }

  // Binding: 탭 선택 즉시 Flutter 에 전달
  private var tabBinding: Binding<Int> {
    Binding(
      get: { selectedTab },
      set: { newTab in
        selectedTab = newTab
        navChannel.invokeMethod("setTab", arguments: newTab)
      }
    )
  }
}

// MARK: - TabBarFixer
// UITabBarController 에 직접 접근해
// ① 탭 콘텐츠 뷰를 모두 투명하게 (Flutter 가 뒤에서 보이도록)
// ② 아이콘 크기를 12pt 로 통일
// ③ 색상을 인스턴스에 직접 지정 (appearance 프록시 재확인)

private struct TabBarFixer: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> TabBarFixerVC { TabBarFixerVC() }
  func updateUIViewController(_ vc: TabBarFixerVC, context: Context) {}
}

final class TabBarFixerVC: UIViewController {
  private var applied = false

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tryApply()
  }

  private func tryApply() {
    guard let tbc = tabBarController else {
      // 아직 계층이 구성되지 않은 경우 재시도
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        self?.tryApply()
      }
      return
    }
    guard !applied else { return }
    applied = true

    // ── ① 탭 콘텐츠 뷰 투명화 ──────────────────────────────
    // SwiftUI 가 각 탭을 UIHostingController 로 래핑하는데
    // 기본 backgroundColor 가 불투명 흰색이라 Flutter 를 가림
    tbc.viewControllers?.forEach { vc in
      vc.view.backgroundColor = .clear
      vc.children.forEach { $0.view.backgroundColor = .clear }
    }
    tbc.view.backgroundColor = .clear

    // ── ② 아이콘 크기 12pt (활성·비활성 동일) ──────────────
    let cfg   = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
    let names = ["house.fill", "person.2.fill", "bubble.fill", "sparkles", "line.3.horizontal"]
    tbc.tabBar.items?.enumerated().forEach { i, item in
      guard i < names.count else { return }
      let img = UIImage(systemName: names[i], withConfiguration: cfg)?
                  .withRenderingMode(.alwaysTemplate)
      item.image         = img
      item.selectedImage = img  // selected 도 같은 크기
    }

    // ── ③ 색상 인스턴스 직접 지정 (AppDelegate 의 appearance 보강) ──
    let black = UIColor(red: 28/255,  green: 28/255,  blue: 30/255,  alpha: 1)
    let gray  = UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1)
    tbc.tabBar.tintColor              = black
    tbc.tabBar.unselectedItemTintColor = gray
  }
}

// MARK: - FlutterViewRepresentable

private struct FlutterViewRepresentable: UIViewControllerRepresentable {
  let viewController: FlutterViewController
  func makeUIViewController(context: Context) -> FlutterViewController { viewController }
  func updateUIViewController(_ vc: FlutterViewController, context: Context) {}
}
