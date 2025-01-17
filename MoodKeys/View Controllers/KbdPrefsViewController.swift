//
//  Untitled.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/20.
//

import Cocoa
import Settings

class KbdPrefsViewController: NSViewController, SettingsPane, NSTextFieldDelegate {
  let paneIdentifier = Settings.PaneIdentifier.keyboard
  let paneTitle: String = NSLocalizedString("Keyboard", comment: "")
  let toolbarItemIcon = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "Keyboard settings")!
  
  var isEditing: Bool = false
  
  @IBOutlet weak var tfVid: NSTextField!
  @IBOutlet weak var tfPid: NSTextField!
  @IBOutlet weak var tfUsage: NSTextField!
  @IBOutlet weak var tfUsagePage: NSTextField!
  @IBOutlet weak var btnModify: NSButton!
  @IBOutlet weak var chkColorCorrection: NSButton!
  @IBOutlet weak var cwColorCorrection: NSColorWell!
  
  let onlyIntFormatter = OnlyIntegerValueFormatter()
  
  var reinitTimer: Timer?
  
  deinit {
    reinitTimer?.invalidate()
  }
  
  func initSettings() {
    prefs.set(17498, forKey: PrefKey.kbdVendorID.rawValue)
    prefs.set(5158, forKey: PrefKey.kbdProductID.rawValue)
    prefs.set(97, forKey: PrefKey.kbdUsage.rawValue)
    prefs.set(65376, forKey: PrefKey.kbdUsagePage.rawValue)
    prefs.set(false, forKey: PrefKey.kbdColorCorrection.rawValue)
    prefs.set("#8CF032", forKey: PrefKey.kbdColorCorrectionColor.rawValue)
  }
  
  func populateSettings() {
    tfVid.stringValue = String(prefs.integer(forKey: PrefKey.kbdVendorID.rawValue))
    tfPid.stringValue = String(prefs.integer(forKey: PrefKey.kbdProductID.rawValue))
    tfUsage.stringValue = String(prefs.integer(forKey: PrefKey.kbdUsage.rawValue))
    tfUsagePage.stringValue = String(prefs.integer(forKey: PrefKey.kbdUsagePage.rawValue))
    chkColorCorrection.state = prefs.bool(forKey: PrefKey.kbdColorCorrection.rawValue) ? .on : .off
    if let colorString = prefs.string(forKey: PrefKey.kbdColorCorrectionColor.rawValue) {
      if let color = hexStringToColor(hex: colorString) {
        cwColorCorrection.color = color
      }
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
    btnModify.title = NSLocalizedString("Modify", comment: "")
    tfVid.formatter = onlyIntFormatter
    tfPid.formatter = onlyIntFormatter
    tfUsage.formatter = onlyIntFormatter
    tfUsagePage.formatter = onlyIntFormatter
    tfVid.delegate = self
    tfPid.delegate = self
    tfUsage.delegate = self
    tfUsagePage.delegate = self
    populateSettings()
  }
  
  /*
   * 编辑按钮被点击
   */
  @IBAction func edit(_ sender: Any) {
    if (!isEditing) {
      /* 启用编辑 */
      tfVid.isEnabled = true
      tfPid.isEnabled = true
      tfUsage.isEnabled = true
      tfUsagePage.isEnabled = true
      
      /* 检查是否可以保存 */
      checkSavable()
      
      /* 修改按钮文字 */
      btnModify.title = NSLocalizedString("Save", comment: "")
      
      isEditing = true
    } else {
      /* 移开焦点防止 tf 修改丢失 */
      self.view.window?.makeFirstResponder(nil)
      
      /* 保存设置 */
      prefs.set(tfVid.stringValue, forKey: PrefKey.kbdVendorID.rawValue)
      prefs.set(tfPid.stringValue, forKey: PrefKey.kbdProductID.rawValue)
      prefs.set(tfUsage.stringValue, forKey: PrefKey.kbdUsage.rawValue)
      prefs.set(tfUsagePage.stringValue, forKey: PrefKey.kbdUsagePage.rawValue)
      
      /* 禁用编辑 */
      tfVid.isEnabled = false
      tfPid.isEnabled = false
      tfUsage.isEnabled = false
      tfUsagePage.isEnabled = false
      
      /* 修改按钮文字 */
      btnModify.title = NSLocalizedString("Modify", comment: "")
      
      /* 重设 manager 中的 kbd*/
      Manager.shared.onKbdCfgChange()
      
      isEditing = false
    }
  }
  
  /**
   * 继承 NSControlTextEditingDelegate.controlTextDidChange(_:).
   */
  func controlTextDidChange(_ obj: Notification) {
    checkSavable()
  }
  
  /**
   * 开关颜色修正
   */
  @IBAction func setColorCorrection(_ sender: NSButton) {
    prefs.set(sender.state, forKey: PrefKey.kbdColorCorrection.rawValue)
    Manager.shared.onKbdCfgChange()
  }
  
  /**
   * 设置颜色修正颜色
   */
  @IBAction func setColorCorrectionColor(_ sender: NSColorWell) {
    let colorString = colorToHexString(color: sender.color)
    
    reinitTimer?.invalidate()
    reinitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {_ in
      prefs.set(colorString, forKey: PrefKey.kbdColorCorrectionColor.rawValue)
      Manager.shared.onKbdCfgChange()
    }
  }
  
  /**
   * 检查传入的 tfs 是否无空
   */
  func allFilled(textFields: [NSTextField]) -> Bool {
    return textFields.allSatisfy { textField in
      return !textField.stringValue.isEmpty
    }
  }
  
  /**
   * 如果 vid, pid, usage, usage page 无空，则可以保存
   */
  func checkSavable() {
    btnModify.isEnabled = allFilled(textFields: [tfVid, tfPid, tfUsage, tfUsagePage])
  }
  
  /**
   * 让 tf 只接受数字
   */
  class OnlyIntegerValueFormatter: NumberFormatter, @unchecked Sendable {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
      //            return !partialString.isEmpty && partialString.count <= 5 && Int(partialString) != nil
      if partialString.isEmpty {
        return true
      }
      return partialString.count <= 5 && Int(partialString) != nil
    }
  }
}
