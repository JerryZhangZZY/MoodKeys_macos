//
//  AppDelegate.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/9.
//

import Cocoa
import Foundation
import Settings
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  let statusMenu = NSMenu(title: "menu")
  
  lazy var settingsWindowController: SettingsWindowController = SettingsWindowController(
    panes: [
      mainPrefsVc!,
      kbdPrefsVc!,
      timerPrefVc!,
      aqiPrefVc!,
      aboutPrefsVc!,
    ],
    style: .toolbarItems,
    animated: true
  )
  
  /**
   * app 启动
   */
  @available(macOS, deprecated: 10.14)
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)
    app = self
    
    /* 首次启动 */
    if (!prefs.bool(forKey: PrefKey.initialized.rawValue)) {
      print("first")
      mainPrefsVc?.initSettings()
      kbdPrefsVc?.initSettings()
      timerPrefVc?.initSettings()
      aqiPrefVc?.initSettings()
      prefs.set(true, forKey: PrefKey.initialized.rawValue)
    }
    
    showWindow(self)
    
    /* 创建 manager 单例 */
    let _ = Manager.shared
    
    /* 设置状态栏图标 */
    self.setStatusItem()
  }
  
  /**
   * 点击了 app 图标
   */
  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    showWindow(self)
    return true
  }
  
  func applicationWillTerminate(_: Notification) {
    self.statusItem.isVisible = true
  }
  
  /**
   * 显示设置窗口
   */
  @objc func showWindow(_: AnyObject) {
    self.settingsWindowController.show()
  }
  
  /**
   * 退出 app
   */
  @objc func quit(_: AnyObject) {
    Manager.shared.stopLighting()
    NSApplication.shared.terminate(self)
  }
  
  /**
   * 设置状态栏图标和菜单
   */
  @available(macOS, deprecated: 10.14)
  private func setStatusItem() {
    Manager.shared.refreshStatusBarBtnImg()
    statusItem.button?.action = #selector(self.statusBarButtonClicked(sender:))
    statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    statusMenu.addItem(
      withTitle: NSLocalizedString("Settings", comment: ""),
      action: #selector(showWindow),
      keyEquivalent: ",")
    statusMenu.addItem(
      withTitle: NSLocalizedString("Quit", comment: ""),
      action: #selector(quit),
      keyEquivalent: "q")
    statusItem.button?.action = #selector(self.statusBarButtonClicked(sender:))
  }
  
  func setStatusBarBtnImg(_ image: NSImage?) {
    statusItem.button?.image = image
  }
  
  @available(macOS, deprecated: 10.14)
  @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
    switch NSApp.currentEvent!.type {
    case .leftMouseUp:
      Manager.shared.toggleActiveness()
    case .rightMouseUp:
      statusItem.popUpMenu(statusMenu)
    default:
      break
    }
  }
  
  func removeSettings() {
    if let bundleID = Bundle.main.bundleIdentifier {
      prefs.removePersistentDomain(forName: bundleID)
    }
  }
  
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

