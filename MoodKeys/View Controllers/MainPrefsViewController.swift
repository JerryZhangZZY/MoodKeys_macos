//
//  MainPrefViewController.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/12.
//

import Cocoa
import Settings
import ServiceManagement
import LaunchAtLogin

class MainPrefsViewController: NSViewController, SettingsPane {
  let paneIdentifier = Settings.PaneIdentifier.general
  let paneTitle: String = NSLocalizedString("General", comment: "")
  let toolbarItemIcon = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: "General settings")!
  
  @IBOutlet weak var sldPeriod: NSSlider!
  @IBOutlet weak var chkAutoStart: NSButton!
  @IBOutlet weak var chkAutoActivate: NSButton!
  
  func initSettings() {
    prefs.set(5, forKey: PrefKey.gnrPeriod.rawValue)
    prefs.set(false, forKey: PrefKey.gnrActivateOnLaunch.rawValue)
  }
  
  @available(macOS, deprecated: 10.10)
  func populateSettings() {
    sldPeriod.intValue = periodToSld(period: prefs.integer(forKey: PrefKey.gnrPeriod.rawValue))
    let startAtLogin = LaunchAtLogin.isEnabled
    self.chkAutoStart.state = startAtLogin ? .on : .off
    chkAutoActivate.state = prefs.bool(forKey: PrefKey.gnrActivateOnLaunch.rawValue) ? .on : .off
  }
  
  @available(macOS, deprecated: 10.10)
  func resetSettings() {
    initSettings()
    if isViewLoaded {
      populateSettings()
    }
  }
  
  @available(macOS, deprecated: 10.10)
  override func viewDidLoad() {
    super.viewDidLoad()
    populateSettings()
  }
  
  @IBAction func changPeriod(_ sender: NSSlider) {
    prefs.set(sldToPeriod(sliderRawValue: sender.intValue), forKey: PrefKey.gnrPeriod.rawValue)
    Manager.shared.onSchedulerCfgChange()
  }
  
  @IBAction func startAtLogin(_ sender: NSButton) {
    switch sender.state {
    case .on:
      LaunchAtLogin.isEnabled = true
    case .off:
      LaunchAtLogin.isEnabled = false
    default: break
    }
  }
  
  @IBAction func activateOnLaunch(_ sender: NSButton) {
    prefs.set(sender.state == .on, forKey: PrefKey.gnrActivateOnLaunch.rawValue)
  }
  
  /**
   * 重置
   */
  @available(macOS, deprecated: 10.10)
  @IBAction func resetApp(_ sender: Any) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("Reset Application", comment: "")
    alert.informativeText = NSLocalizedString("Are you sure you want to reset all settings?", comment: "")
    alert.addButton(withTitle: NSLocalizedString("Yes", comment: ""))
    alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
    if let window = self.view.window {
      alert.beginSheetModal(for: window, completionHandler: { modalResponse in self.resetSheetModalHander(modalResponse: modalResponse) })
    }
  }
  
  @available(macOS, deprecated: 10.10)
  func resetSheetModalHander(modalResponse: NSApplication.ModalResponse) {
    if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
      app.removeSettings()
      self.resetSettings()
      kbdPrefsVc?.resetSettings()
      timerPrefVc?.resetSettings()
      aqiPrefVc?.resetSettings()
      prefs.set(true, forKey: PrefKey.initialized.rawValue)
    }
  }
  
  func sldToPeriod(sliderRawValue: Int32) -> Int {
    switch sliderRawValue {
    case 1:
      return 1
    case 2:
      return 2
    case 3:
      return 5
    case 4:
      return 10
    case 5:
      return 30
    default:
      return 5
    }
  }
  
  func periodToSld(period: Int) -> Int32 {
    switch period {
    case 1:
      return 1
    case 2:
      return 2
    case 5:
      return 3
    case 10:
      return 4
    case 30:
      return 5
    default:
      return 3
    }
  }
}
