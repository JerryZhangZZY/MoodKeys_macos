//
//  AboutPrefsViewController.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/12.
//

import Cocoa
import Settings

class AboutPrefsViewController: NSViewController, SettingsPane {
  let paneIdentifier = Settings.PaneIdentifier.about
  let paneTitle: String = NSLocalizedString("About", comment: "")
  let toolbarItemIcon = NSImage(systemSymbolName: "info.circle.fill", accessibilityDescription: "About page")!
  
  @IBOutlet weak var lbVersion: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setVersionInfo()
  }
  
  func setVersionInfo() {
    let versionName = NSLocalizedString("Version", comment: "")
    let versionNum = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "error"
    let buildNum = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "error"
    lbVersion.stringValue = "\(versionName): \(versionNum) (\(buildNum))"
  }
}
