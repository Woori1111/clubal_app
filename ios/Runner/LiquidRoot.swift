import Flutter
import SwiftUI
import UIKit

// MARK: - LiquidRoot (iOS 전용)
// Flutter 전체 화면 + 하단 네이티브 탭바. 블러 없음.

private let kOverlayHeight: CGFloat = 180
private let kCornerRadius: CGFloat = 24
private let kBarColor = UIColor.black.withAlphaComponent(0.5)
private let kSelectedColor = UIColor(red: 230/255, green: 237/255, blue: 243/255, alpha: 1)
private let kUnselectedColor = UIColor(red: 139/255, green: 148/255, blue: 158/255, alpha: 1)

struct LiquidRoot: View {
  private let flutterViewController: FlutterViewController
  private let navChannel: FlutterMethodChannel
  @State private var selectedTab = 0
  @State private var isTabBarVisible = true

  init(flutterViewController: FlutterViewController, engine: FlutterEngine) {
    self.flutterViewController = flutterViewController
    self.navChannel = FlutterMethodChannel(name: "com.clubal.app/navigation", binaryMessenger: engine.binaryMessenger)
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      FlutterViewRepresentable(viewController: flutterViewController)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)

      NativeTabBarOverlay(selectedTab: $selectedTab, isTabBarVisible: isTabBarVisible, navChannel: navChannel)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: kOverlayHeight, maxHeight: kOverlayHeight)
        .ignoresSafeArea(.all)
        .allowsHitTesting(isTabBarVisible)
        .animation(.easeOut(duration: 0.2), value: isTabBarVisible)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea(.all)
    .background(Color.clear)
    .onAppear { installChannelHandler() }
  }

  private func installChannelHandler() {
    navChannel.setMethodCallHandler { call, result in
      if call.method == "setTabBarVisible", let visible = call.arguments as? Bool {
        if visible {
          var t = Transaction()
          t.disablesAnimations = true
          withTransaction(t) { isTabBarVisible = true }
        }
        else { withAnimation(.easeOut(duration: 0.15)) { isTabBarVisible = false } }
        flutterViewController.additionalSafeAreaInsets = .zero
        result(nil)
      } else if call.method == "setTab", let index = call.arguments as? Int, (0..<5).contains(index) {
        selectedTab = index
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

// MARK: - NativeTabBarOverlay

private struct NativeTabBarOverlay: UIViewControllerRepresentable {
  @Binding var selectedTab: Int
  let isTabBarVisible: Bool
  let navChannel: FlutterMethodChannel

  func makeUIViewController(context: Context) -> NativeTabBarViewController {
    NativeTabBarViewController(selectedTab: $selectedTab, navChannel: navChannel)
  }

  func updateUIViewController(_ vc: NativeTabBarViewController, context: Context) {
    vc.updateSelectedTab(selectedTab)
    vc.setTabBarVisible(isTabBarVisible)
  }
}

// MARK: - NativeTabBarViewController

private final class NativeTabBarViewController: UIViewController, UITabBarDelegate {
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
    let v = PassThroughView()
    v.backgroundColor = .clear
    v.clipsToBounds = false
    v.layer.masksToBounds = false
    view = v
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    tabBar = UITabBar()
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.delegate = self
    applyAppearance()
    view.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    setupItems()
    tabBar.selectedItem = tabBar.items?.first
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tabBar.layer.cornerRadius = kCornerRadius
    tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    // masksToBounds = false: 탭 누를 때 선택 하이라이트가 위에서 잘리지 않게 함
    tabBar.layer.masksToBounds = false
  }

  func setTabBarVisible(_ visible: Bool) {
    tabBar.alpha = visible ? 1 : 0
    tabBar.isUserInteractionEnabled = visible
  }

  func updateSelectedTab(_ index: Int) {
    guard let items = tabBar.items, items.indices.contains(index), tabBar.selectedItem != items[index] else { return }
    tabBar.selectedItem = items[index]
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    DispatchQueue.main.async { [weak self] in self?.selectedTabBinding.wrappedValue = item.tag }
    navChannel.invokeMethod("setTab", arguments: item.tag)
  }

  private func applyAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = kBarColor
    let item = UITabBarItemAppearance()
    item.normal.iconColor = kUnselectedColor
    item.normal.titleTextAttributes = [.foregroundColor: kUnselectedColor]
    item.selected.iconColor = kSelectedColor
    item.selected.titleTextAttributes = [.foregroundColor: kSelectedColor]
    appearance.stackedLayoutAppearance = item
    appearance.inlineLayoutAppearance = item
    appearance.compactInlineLayoutAppearance = item
    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = appearance }
    tabBar.tintColor = kSelectedColor
    tabBar.unselectedItemTintColor = kUnselectedColor
  }

  private func setupItems() {
    let items: [(String, String)] = [
      ("house.fill", "홈"),
      ("person.2.fill", "매칭"),
      ("bubble.fill", "채팅"),
      ("sparkles", "커뮤니티"),
      ("line.3.horizontal", "메뉴"),
    ]
    let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
    tabBar.items = items.enumerated().map { i, pair in
      let img = UIImage(systemName: pair.0, withConfiguration: cfg)
      let item = UITabBarItem(title: pair.1, image: img?.withTintColor(kUnselectedColor, renderingMode: .alwaysOriginal), tag: i)
      item.selectedImage = img?.withTintColor(kSelectedColor, renderingMode: .alwaysOriginal)
      return item
    }
  }
}

// MARK: - PassThroughView

private class PassThroughView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hit = super.hitTest(point, with: event)
    return hit == self ? nil : hit
  }
}

// MARK: - FlutterViewRepresentable

private struct FlutterViewRepresentable: UIViewControllerRepresentable {
  let viewController: FlutterViewController
  func makeUIViewController(context: Context) -> FlutterViewController { viewController }
  func updateUIViewController(_ vc: FlutterViewController, context: Context) {}
}
