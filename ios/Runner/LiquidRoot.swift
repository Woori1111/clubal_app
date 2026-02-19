import Flutter
import SwiftUI
import UIKit

// MARK: - LiquidRoot
// Flutter 전체 화면 + 하단 순수 네이티브 UITabBar 오버레이

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
    ZStack(alignment: .bottom) {
      // Flutter 화면 (전체 영역)
      FlutterViewRepresentable(viewController: flutterViewController)
        .ignoresSafeArea()

      // 네이티브 애플 기본 탭바 오버레이
      NativeTabBarOverlay(
        selectedTab: $selectedTab,
        navChannel: navChannel
      )
      .ignoresSafeArea(edges: .bottom) // 탭바 배경이 하단 기기 끝까지 채워지도록 함
    }
  }
}

// MARK: - NativeTabBarOverlay

private struct NativeTabBarOverlay: UIViewControllerRepresentable {
  @Binding var selectedTab: Int
  let navChannel: FlutterMethodChannel

  func makeUIViewController(context: Context) -> NativeTabBarViewController {
    NativeTabBarViewController(selectedTab: $selectedTab, navChannel: navChannel)
  }

  func updateUIViewController(_ vc: NativeTabBarViewController, context: Context) {
    vc.updateSelectedTab(selectedTab)
  }
}

final class NativeTabBarViewController: UIViewController, UITabBarDelegate {
  private var tabBar: UITabBar!
  private var selectedTabBinding: Binding<Int>
  private let navChannel: FlutterMethodChannel

  init(selectedTab: Binding<Int>, navChannel: FlutterMethodChannel) {
    self.selectedTabBinding = selectedTab
    self.navChannel = navChannel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    // 빈 공간 터치는 무시하고 탭바 터치만 받는 커스텀 뷰
    view = PassThroughView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear

    tabBar = UITabBar()
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.delegate = self
    view.addSubview(tabBar)

    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      // 높이는 UITabBar가 내부적으로 자동 계산(기본 49pt + 하단 Safe Area)
    ])

    setupTabBarItems()
    applyLiquidGlassAppearance()
  }

  private func setupTabBarItems() {
    let items = [
      (icon: "house.fill", title: "홈"),
      (icon: "person.2.fill", title: "매칭"),
      (icon: "bubble.fill", title: "채팅"),
      (icon: "sparkles", title: "커뮤니티"),
      (icon: "line.3.horizontal", title: "메뉴"),
    ]
    
    let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
    
    tabBar.items = items.enumerated().map { i, item in
      let img = UIImage(systemName: item.icon, withConfiguration: cfg)?
        .withRenderingMode(.alwaysTemplate)
      return UITabBarItem(title: item.title, image: img, tag: i)
    }
    
    tabBar.selectedItem = tabBar.items?.first
  }

  private func applyLiquidGlassAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    
    // 블러 효과 (리퀴드 글래스)
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    // 흰색 반투명 오버레이
    appearance.backgroundColor = UIColor.white.withAlphaComponent(0.22)
    
    // 아이콘 및 텍스트 색상
    let black = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
    let gray = UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1)
    
    appearance.stackedLayoutAppearance.normal.iconColor = gray
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: gray]
    appearance.stackedLayoutAppearance.selected.iconColor = black
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: black]

    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
    tabBar.isTranslucent = true

    tabBar.tintColor = black
    tabBar.unselectedItemTintColor = gray
  }

  func updateSelectedTab(_ index: Int) {
    guard let items = tabBar.items, items.indices.contains(index) else { return }
    tabBar.selectedItem = items[index]
  }

  // MARK: - UITabBarDelegate
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let index = item.tag
    selectedTabBinding.wrappedValue = index
    navChannel.invokeMethod("setTab", arguments: index)
  }
}

// MARK: - PassThroughView
private class PassThroughView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    // 뷰의 빈 공간(자신)을 터치하면 이벤트를 무시하여 뒤(Flutter)로 넘김
    if hitView == self { return nil }
    // 탭바 내부 요소(아이콘, 탭바 배경)를 터치한 경우는 정상적으로 터치 이벤트 수신
    return hitView
  }
}

// MARK: - FlutterViewRepresentable
private struct FlutterViewRepresentable: UIViewControllerRepresentable {
  let viewController: FlutterViewController
  func makeUIViewController(context: Context) -> FlutterViewController { viewController }
  func updateUIViewController(_ vc: FlutterViewController, context: Context) {}
}
