import Flutter
import SwiftUI
import UIKit

// MARK: - 아이콘 이미지 (12pt 고정 — SwiftUI 가 tabItem 렌더 시 이 UIImage 를 그대로 사용)
private func tabIcon(_ name: String) -> Image {
  let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
  let img = UIImage(systemName: name, withConfiguration: cfg)?
              .withRenderingMode(.alwaysTemplate) ?? UIImage()
  return Image(uiImage: img)
}

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
      // Flutter 콘텐츠 — 전체 화면
      FlutterViewRepresentable(viewController: flutterViewController)
        .ignoresSafeArea()

      // 네이티브 Liquid Glass TabView
      TabView(selection: tabBinding) {
        Color.clear
          .background(TabContentClearer())       // ← 탭 콘텐츠 배경을 투명하게
          .tabItem { tabIcon("house.fill");       Text("홈")  }.tag(0)
        Color.clear
          .tabItem { tabIcon("person.2.fill");    Text("매칭") }.tag(1)
        Color.clear
          .tabItem { tabIcon("bubble.fill");      Text("채팅") }.tag(2)
        Color.clear
          .tabItem { tabIcon("sparkles");         Text("파티") }.tag(3)
        Color.clear
          .tabItem { tabIcon("line.3.horizontal");Text("메뉴") }.tag(4)
      }
      // 활성(ON) 색상 — SwiftUI 네이티브 방식으로 파란색 accent 덮어쓰기
      .tint(Color(red: 28/255, green: 28/255, blue: 30/255)) // #1C1C1E 검정
    }
    .ignoresSafeArea()
  }

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

// MARK: - TabContentClearer
// TabView 내부 UIHostingController 의 배경이 불투명 흰색이라 Flutter 를 가림
// → viewDidAppear 마다 투명으로 재설정 (SwiftUI 가 탭 전환 시 리셋하므로 매번 실행)

private struct TabContentClearer: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> _ClearVC { _ClearVC() }
  func updateUIViewController(_ vc: _ClearVC, context: Context) {}
}

final class _ClearVC: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // UITabBarController 의 모든 탭 콘텐츠 뷰를 투명하게
    tabBarController?.viewControllers?.forEach { vc in
      vc.view.backgroundColor = .clear
      vc.children.forEach { $0.view.backgroundColor = .clear }
    }
    tabBarController?.view.backgroundColor = .clear
  }
}

// MARK: - FlutterViewRepresentable

private struct FlutterViewRepresentable: UIViewControllerRepresentable {
  let viewController: FlutterViewController
  func makeUIViewController(context: Context) -> FlutterViewController { viewController }
  func updateUIViewController(_ vc: FlutterViewController, context: Context) {}
}
