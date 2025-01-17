//
//  AqiPrefsViewController.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/16.
//

import Cocoa
import Settings

class AqiPrefsViewController: NSViewController, SettingsPane {
  let paneIdentifier = Settings.PaneIdentifier.aqi
  let paneTitle: String = NSLocalizedString("Aqi", comment: "")
  let toolbarItemIcon = NSImage(systemSymbolName: "key.icloud.fill", accessibilityDescription: "AQI settings")!
  
  @IBOutlet weak var tfApiToken: NSSecureTextField!
  @IBOutlet weak var rbLocationAuto: NSButton!
  @IBOutlet weak var rbLocationCustom: NSButton!
  @IBOutlet weak var tfLocationCustom: NSTextField!
  
  func initSettings() {
    prefs.set("", forKey: PrefKey.aqiToken.rawValue)
    prefs.set(true, forKey: PrefKey.aqiAutoLocation.rawValue)
    prefs.set("", forKey: PrefKey.aqiStation.rawValue)
  }
  
  func populateSettings() {
    if let token = prefs.string(forKey: PrefKey.aqiToken.rawValue) {
      tfApiToken.stringValue = token
    }
    
    let autoLocation = prefs.bool(forKey: PrefKey.aqiAutoLocation.rawValue)
    if (autoLocation) {
      rbLocationAuto.state = .on
    } else {
      rbLocationCustom.state = .on
    }
    tfLocationCustom.isEnabled = !autoLocation
    
    if let station = prefs.string(forKey: PrefKey.aqiStation.rawValue) {
      tfLocationCustom.stringValue = station
    }
  }
  
  func resetSettings() {
    initSettings()
    if isViewLoaded {
      populateSettings()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    populateSettings()
  }
  
  /**
   * Token 被修改
   */
  @IBAction func setApiToken(_ sender: Any) {
    prefs.set(tfApiToken.stringValue, forKey: PrefKey.aqiToken.rawValue)
    Manager.shared.onSchedulerCfgChange()
  }
  
  /**
   * 打开申请 token 的网页
   */
  @IBAction func openTokenPage(_ sender: Any) {
    if let url = URL(string: "https://aqicn.org/data-platform/token/") {
      NSWorkspace.shared.open(url)
    }
  }
  
  /**
   * 选择位置被点击
   */
  @IBAction func selectLocation(_ sender: NSButton) {
    if sender == rbLocationAuto {
      tfLocationCustom.isEnabled = false
      prefs.set(true, forKey: PrefKey.aqiAutoLocation.rawValue)
      
    } else if sender == rbLocationCustom {
      tfLocationCustom.isEnabled = true
      prefs.set(false, forKey: PrefKey.aqiAutoLocation.rawValue)
    }
    Manager.shared.onSchedulerCfgChange()
  }
  
  /**
   * 自定义位置被修改
   */
  @IBAction func setCustomLocation(_ sender: Any) {
    prefs.set(tfLocationCustom.stringValue, forKey: PrefKey.aqiStation.rawValue)
    Manager.shared.onSchedulerCfgChange()
  }
}
