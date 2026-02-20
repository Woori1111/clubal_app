import Flutter
import SwiftUI
import UIKit

// MARK: - LiquidRoot
// Flutter 전체 화면 + 하단 순수 네이티브 UITabBar 오버레이

struct LiquidRoot: View {
  private let flutterViewController: FlutterViewController
  private let navChannel: FlutterMethodChannel

  @State private var selectedTab = 0
  @State private var isTabBarVisible = true

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

      // 탭바는 항상 뷰 계층에 유지, opacity로만 숨김. 오버레이 배경은 투명(Flutter가 보이도록).
      NativeTabBarOverlay(
        selectedTab: $selectedTab,
        navChannel: navChannel
      )
      .background(Color.clear)
      .ignoresSafeArea(edges: .bottom)
      .opacity(isTabBarVisible ? 1 : 0)
      .allowsHitTesting(isTabBarVisible)
      .animation(.easeOut(duration: 0.2), value: isTabBarVisible)
    }
    .background(Color.black)
    .onAppear {
      navChannel.setMethodCallHandler { call, result in
        if call.method == "setTabBarVisible" {
          if let visible = call.arguments as? Bool {
            withAnimation(.easeOut(duration: 0.2)) {
              isTabBarVisible = visible
            }
            flutterViewController.additionalSafeAreaInsets = UIEdgeInsets(
              top: 0, 
              left: 0, 
              bottom: visible ? 49 : 0, 
              right: 0
            )
          }
          result(nil)
        } else if call.method == "setTab" {
          if let index = call.arguments as? Int, (0..<5).contains(index) {
            selectedTab = index
          }
          result(nil)
        }
      }
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
    let passThrough = PassThroughView()
    passThrough.backgroundColor = .clear
    view = passThrough
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear

    tabBar = UITabBar()
    // 첫 프레임부터 흰 배경이 나오지 않도록 즉시 투명/다크 처리 (앱에 화이트 테마 없음)
    tabBar.backgroundColor = .clear
    tabBar.barTintColor = .clear
    tabBar.backgroundImage = UIImage()
    tabBar.shadowImage = UIImage()
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
    // 다크테마 아이콘 색상 (선택: 하얀색 계열, 미선택: 중간 회색)
    let selectedColor = UIColor(red: 230.0/255.0, green: 237.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    let unselectedColor = UIColor(red: 139.0/255.0, green: 148.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    
    tabBar.items = items.enumerated().map { i, item in
      let baseImg = UIImage(systemName: item.icon, withConfiguration: cfg)
      
      let unselectedImg = baseImg?.withTintColor(unselectedColor, renderingMode: .alwaysOriginal)
      let selectedImg = baseImg?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
      
      let tabItem = UITabBarItem(title: item.title, image: unselectedImg, tag: i)
      tabItem.selectedImage = selectedImg
      return tabItem
    }
    
    // 초기 탭 설정
    tabBar.selectedItem = tabBar.items?.first
  }

  private func applyLiquidGlassAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    
    // 다크 전용 앱이므로 블러·배경 모두 다크 계열로 설정해 흰색 깜빡임 제거
    if #available(iOS 13.0, *) {
      appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
    } else {
      appearance.backgroundEffect = UIBlurEffect(style: .dark)
    }
    appearance.backgroundColor = UIColor.black.withAlphaComponent(0.25)
    
    // 전역 틴트 설정 (활성: 하얀색 계열, 비활성: 회색 계열)
    let selectedColor = UIColor(red: 230.0/255.0, green: 237.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    let unselectedColor = UIColor(red: 139.0/255.0, green: 148.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    
    // 아이콘과 텍스트 색상을 확실하게 적용하기 위한 ItemAppearance 생성
    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.normal.iconColor = unselectedColor
    itemAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
    itemAppearance.selected.iconColor = selectedColor
    itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
    
    appearance.stackedLayoutAppearance = itemAppearance
    appearance.inlineLayoutAppearance = itemAppearance
    appearance.compactInlineLayoutAppearance = itemAppearance

    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }
    tabBar.isTranslucent = true
    
    tabBar.tintColor = selectedColor
    tabBar.unselectedItemTintColor = unselectedColor
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // UITabBar 내부 _UIBarBackground 등이 한 프레임 흰색으로 그려지는 것 방지
    for sub in tabBar.subviews {
      if String(describing: type(of: sub)).contains("BarBackground") {
        sub.backgroundColor = .clear
        sub.layer.backgroundColor = UIColor.clear.cgColor
      }
    }
  }

  func updateSelectedTab(_ index: Int) {
    guard let items = tabBar.items, items.indices.contains(index) else { return }
    if tabBar.selectedItem != items[index] {
      tabBar.selectedItem = items[index]
    }
  }

  // MARK: - UITabBarDelegate
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let index = item.tag
    // SwiftUI 상태 업데이트를 메인 스레드 비동기 큐에 태워서 충돌 방지
    DispatchQueue.main.async { [weak self] in
      self?.selectedTabBinding.wrappedValue = index
    }
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
