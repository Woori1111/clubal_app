import Flutter
import SwiftUI
import UIKit

// MARK: - Channel names for Flutter ↔ Native UI callbacks
private let kIOSUIChannelName = "com.clubal.app/ios_ui"
private let kSettingsTogglesChannelName = "com.clubal.app/settings_toggles"
private let kMarketingTogglesChannelName = "com.clubal.app/marketing_toggles"

// MARK: - 1. 매칭 화면 + 버튼
struct MatchingPlusButtonView: View {
  var onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      Image(systemName: "plus")
        .font(.system(size: 28, weight: .medium))
        .foregroundStyle(Color.primary)
        .frame(width: 52, height: 52)
        .background(.ultraThinMaterial, in: Circle())
        .overlay(Circle().strokeBorder(Color.primary.opacity(0.2), lineWidth: 1.2))
    }
    .buttonStyle(.plain)
  }
}

// MARK: - 2. 자동매치 FAB (Expanding Search Bar Transition)
struct AutoMatchFabSwiftView: View {
  var compact: Bool
  var onTap: () -> Void

  private let labelColor = Color(uiColor: .label)

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 10) {
        Image(systemName: "bolt.fill")
          .font(.system(size: compact ? 22 : 20, weight: .semibold))
          .foregroundStyle(labelColor)
        if !compact {
          Text("자동매치")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(labelColor)
        }
      }
      .padding(.horizontal, compact ? 0 : 16)
      .frame(width: compact ? 58 : 156, height: 58)
      .background(.ultraThinMaterial, in: Capsule())
      .overlay(Capsule().strokeBorder(labelColor.opacity(0.2), lineWidth: 1.5))
      .animation(.easeInOut(duration: 0.26), value: compact)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - 3. 채팅 상단 바 (모임 채팅 | 1:1 채팅) — 하단 네비 동일 느낌, 슬라이딩 pill
struct ChatTopBarSwiftView: View {
  let initialIndex: Int
  var onChanged: (Int) -> Void
  @State private var selectedIndex: Int
  private let labels = ["모임 채팅", "1:1 채팅"]

  init(initialIndex: Int, onChanged: @escaping (Int) -> Void) {
    self.initialIndex = initialIndex
    self.onChanged = onChanged
    _selectedIndex = State(initialValue: initialIndex)
  }

  var body: some View {
    GeometryReader { geo in
      let segmentW = geo.size.width / CGFloat(labels.count)
      ZStack(alignment: .leading) {
        Capsule()
          .fill(.regularMaterial)
        Capsule()
          .fill(Color(UIColor.systemBackground))
          .frame(width: segmentW - 6, height: geo.size.height - 10)
          .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
          .offset(x: 3 + segmentW * CGFloat(selectedIndex), y: 5)
          .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: selectedIndex)
        HStack(spacing: 0) {
          ForEach(0..<labels.count, id: \.self) { i in
            Button {
              withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8)) { selectedIndex = i }
              onChanged(i)
            } label: {
              Text(labels[i])
                .font(.system(size: 15, weight: selectedIndex == i ? .semibold : .medium))
                .foregroundStyle(selectedIndex == i ? Color.primary : Color.secondary)
                .frame(width: segmentW, height: geo.size.height)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding(5)
    }
    .frame(height: 50)
  }
}

// MARK: - 4. 커뮤니티 상단 바 (최신 | 인기) — 하단 네비 동일 느낌, 슬라이딩 pill
struct CommunityTopBarSwiftView: View {
  let initialIndex: Int
  var onChanged: (Int) -> Void
  @State private var selectedIndex: Int
  private let labels = ["최신", "인기"]

  init(initialIndex: Int, onChanged: @escaping (Int) -> Void) {
    self.initialIndex = initialIndex
    self.onChanged = onChanged
    _selectedIndex = State(initialValue: initialIndex)
  }

  var body: some View {
    GeometryReader { geo in
      let segmentW = geo.size.width / CGFloat(labels.count)
      ZStack(alignment: .leading) {
        Capsule()
          .fill(.regularMaterial)
        Capsule()
          .fill(Color(UIColor.systemBackground))
          .frame(width: segmentW - 6, height: geo.size.height - 10)
          .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
          .offset(x: 3 + segmentW * CGFloat(selectedIndex), y: 5)
          .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: selectedIndex)
        HStack(spacing: 0) {
          ForEach(0..<labels.count, id: \.self) { i in
            Button {
              withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8)) { selectedIndex = i }
              onChanged(i)
            } label: {
              HStack(spacing: 4) {
                Text(labels[i])
                  .font(.system(size: 15, weight: selectedIndex == i ? .semibold : .medium))
                if labels[i] == "인기" {
                  Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                }
              }
              .foregroundStyle(selectedIndex == i ? Color.primary : Color.secondary)
              .frame(width: segmentW, height: geo.size.height)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding(5)
    }
    .frame(height: 50)
  }
}

// MARK: - 5. 커뮤니티 글쓰기 FAB (Expanding Search Bar Transition)
struct CommunityWriteFabSwiftView: View {
  var expanded: Bool
  var onTap: () -> Void

  private let labelColor = Color(uiColor: .label)

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 10) {
        Image(systemName: "square.and.pencil")
          .font(.system(size: expanded ? 20 : 24, weight: .medium))
          .foregroundStyle(labelColor)
        if expanded {
          Text("글 쓰기")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(labelColor)
        }
      }
      .padding(.horizontal, expanded ? 16 : 0)
      .frame(width: expanded ? 120 : 56, height: 56)
      .background(.ultraThinMaterial, in: Capsule())
      .overlay(Capsule().strokeBorder(labelColor.opacity(0.2), lineWidth: 1.2))
      .animation(.easeInOut(duration: 0.26), value: expanded)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Platform View Wrappers (UIKit hosting SwiftUI + channel)

final class NativeUIFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let viewType: String

  init(messenger: FlutterBinaryMessenger, viewType: String) {
    self.messenger = messenger
    self.viewType = viewType
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let channel = FlutterMethodChannel(name: kIOSUIChannelName, binaryMessenger: messenger)
    let params = (args as? [String: Any]) ?? [:]
    switch viewType {
    case "ios_matching_plus":
      return MatchingPlusPlatformView(frame: frame, channel: channel)
    case "ios_auto_match_fab":
      let compact = (params["compact"] as? NSNumber)?.boolValue ?? true
      return AutoMatchFabPlatformView(frame: frame, channel: channel, compact: compact)
    case "ios_chat_top_bar":
      let idx = params["selectedIndex"] as? Int ?? 0
      return ChatTopBarPlatformView(frame: frame, channel: channel, initialIndex: idx)
    case "ios_community_top_bar":
      let idx = params["selectedIndex"] as? Int ?? 0
      return CommunityTopBarPlatformView(frame: frame, channel: channel, initialIndex: idx)
    case "ios_community_write_fab":
      let expanded = (params["expanded"] as? NSNumber)?.boolValue ?? true
      return CommunityWriteFabPlatformView(frame: frame, channel: channel, expanded: expanded)
    case "ios_toolbar_search_bar":
      let placeholder = params["placeholder"] as? String ?? "검색"
      let searchType = params["type"] as? String ?? "menu"
      return ToolbarSearchBarPlatformView(frame: frame, channel: channel, placeholder: placeholder, searchType: searchType)
    case "ios_toggle_row":
      let label = params["label"] as? String ?? ""
      let value = params["value"] as? Bool ?? false
      let key = params["key"] as? String ?? ""
      let channelName = params["channel"] as? String ?? kSettingsTogglesChannelName
      let toggleChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
      return ToggleRowPlatformView(frame: frame, channel: toggleChannel, label: label, value: value, key: key)
    default:
      return PlaceholderPlatformView(frame: frame)
    }
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

// Base: hold channel and hosting controller
private class MatchingPlusPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private var hosting: UIHostingController<MatchingPlusButtonView>?

  init(frame: CGRect, channel: FlutterMethodChannel) {
    self.frame = frame
    self.channel = channel
    super.init()
  }

  func view() -> UIView {
    let swiftUI = MatchingPlusButtonView {
      self.channel.invokeMethod("plusTapped", arguments: nil)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = frame
    h.view.backgroundColor = .clear
    hosting = h
    return h.view
  }
}

private class AutoMatchFabPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private var compact: Bool
  private var hosting: UIHostingController<AutoMatchFabSwiftView>?
  private var containerView: UIView!

  init(frame: CGRect, channel: FlutterMethodChannel, compact: Bool) {
    self.frame = frame
    self.channel = channel
    self.compact = compact
    super.init()
  }

  func view() -> UIView {
    containerView = UIView(frame: frame)
    containerView.backgroundColor = .clear
    updateHosting()
    return containerView
  }

  private func updateHosting() {
    hosting?.view.removeFromSuperview()
    hosting?.removeFromParent()
    let swiftUI = AutoMatchFabSwiftView(compact: compact) {
      self.channel.invokeMethod("autoMatchTapped", arguments: nil)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = containerView.bounds
    h.view.backgroundColor = .clear
    h.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(h.view)
    hosting = h
  }

  func setCompact(_ compact: Bool) {
    guard self.compact != compact else { return }
    self.compact = compact
    updateHosting()
  }
}

private class ChatTopBarPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private var selectedIndex: Int
  private var hosting: UIHostingController<ChatTopBarSwiftView>?

  init(frame: CGRect, channel: FlutterMethodChannel, initialIndex: Int) {
    self.frame = frame
    self.channel = channel
    self.selectedIndex = initialIndex
    super.init()
  }

  func view() -> UIView {
    let swiftUI = ChatTopBarSwiftView(initialIndex: selectedIndex) { [weak self] i in
      self?.selectedIndex = i
      self?.channel.invokeMethod("chatSegmentChanged", arguments: i)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = frame
    h.view.backgroundColor = .clear
    hosting = h
    return h.view
  }
}

private class CommunityTopBarPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private var selectedIndex: Int

  init(frame: CGRect, channel: FlutterMethodChannel, initialIndex: Int) {
    self.frame = frame
    self.channel = channel
    self.selectedIndex = initialIndex
    super.init()
  }

  func view() -> UIView {
    let swiftUI = CommunityTopBarSwiftView(initialIndex: selectedIndex) { [weak self] i in
      self?.selectedIndex = i
      self?.channel.invokeMethod("communityTabChanged", arguments: i)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = frame
    h.view.backgroundColor = .clear
    return h.view
  }
}

private class CommunityWriteFabPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private var expanded: Bool
  private var containerView: UIView!
  private var hosting: UIHostingController<CommunityWriteFabSwiftView>?

  init(frame: CGRect, channel: FlutterMethodChannel, expanded: Bool = true) {
    self.frame = frame
    self.channel = channel
    self.expanded = expanded
    super.init()
  }

  func view() -> UIView {
    containerView = UIView(frame: frame)
    containerView.backgroundColor = .clear
    updateHosting()
    return containerView
  }

  private func updateHosting() {
    hosting?.view.removeFromSuperview()
    hosting?.removeFromParent()
    let swiftUI = CommunityWriteFabSwiftView(expanded: expanded) {
      self.channel.invokeMethod("communityWriteTapped", arguments: nil)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = containerView.bounds
    h.view.backgroundColor = .clear
    h.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.addSubview(h.view)
    hosting = h
  }

  func setExpanded(_ expanded: Bool) {
    guard self.expanded != expanded else { return }
    self.expanded = expanded
    updateHosting()
  }
}

// MARK: - 6. 툴바 / Search Bar
struct ToolbarSearchBarSwiftView: View {
  let placeholder: String
  var onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(Color.secondary)
        Text(placeholder)
          .font(.system(size: 16))
          .foregroundStyle(Color.secondary)
        Spacer(minLength: 0)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity)
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
      .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
    .buttonStyle(.plain)
  }
}

// MARK: - 7. 설정 토글 행
struct ToggleRowSwiftView: View {
  let label: String
  @State private var isOn: Bool
  let key: String
  var onChanged: (Bool) -> Void

  init(label: String, value: Bool, key: String, onChanged: @escaping (Bool) -> Void) {
    self.label = label
    self.key = key
    self.onChanged = onChanged
    _isOn = State(initialValue: value)
  }

  var body: some View {
    HStack {
      Text(label)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(Color.primary)
      Spacer(minLength: 12)
      Toggle("", isOn: $isOn)
        .labelsHidden()
        .toggleStyle(.switch)
        .onChange(of: isOn) { newValue in
          onChanged(newValue)
        }
    }
    .padding(.vertical, 4)
  }
}

private class ToolbarSearchBarPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private let placeholder: String
  private let searchType: String

  init(frame: CGRect, channel: FlutterMethodChannel, placeholder: String, searchType: String) {
    self.frame = frame
    self.channel = channel
    self.placeholder = placeholder
    self.searchType = searchType
    super.init()
  }

  func view() -> UIView {
    let swiftUI = ToolbarSearchBarSwiftView(placeholder: placeholder) { [weak self] in
      self?.channel.invokeMethod("searchTapped", arguments: self?.searchType)
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = frame
    h.view.backgroundColor = .clear
    return h.view
  }
}

private class ToggleRowPlatformView: NSObject, FlutterPlatformView {
  private let frame: CGRect
  private let channel: FlutterMethodChannel
  private let label: String
  private let key: String
  private var value: Bool

  init(frame: CGRect, channel: FlutterMethodChannel, label: String, value: Bool, key: String) {
    self.frame = frame
    self.channel = channel
    self.label = label
    self.key = key
    self.value = value
    super.init()
  }

  func view() -> UIView {
    let swiftUI = ToggleRowSwiftView(label: label, value: value, key: key) { [weak self] newValue in
      self?.value = newValue
      self?.channel.invokeMethod("toggleChanged", arguments: [self?.key ?? "", newValue])
    }
    let h = UIHostingController(rootView: swiftUI)
    h.view.frame = frame
    h.view.backgroundColor = .clear
    return h.view
  }
}

private class PlaceholderPlatformView: NSObject, FlutterPlatformView {
  private let placeholderView: UIView
  init(frame: CGRect) {
    self.placeholderView = UIView(frame: frame)
    placeholderView.backgroundColor = .clear
    super.init()
  }
  func view() -> UIView { placeholderView }
}
