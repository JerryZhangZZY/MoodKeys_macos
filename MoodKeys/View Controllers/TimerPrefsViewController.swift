//
//  TimerPrefViewController.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/16.
//

import Cocoa
import Settings

class TimerPrefsViewController: NSViewController, SettingsPane {
  let paneIdentifier = Settings.PaneIdentifier.timer
  let paneTitle: String = NSLocalizedString("Timer", comment: "")
  let toolbarItemIcon = NSImage(systemSymbolName: "timer.circle.fill", accessibilityDescription: "Timer settings")!
  
  @IBOutlet weak var chkTimer: NSButton!
  @IBOutlet weak var dpStart: NSDatePicker!
  @IBOutlet weak var dpEnd: NSDatePicker!
  @IBOutlet weak var chkSkipHolidays: NSButton!
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HHmm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  func initSettings() {
    prefs.set(false, forKey: PrefKey.timerSwitch.rawValue)
    prefs.set("0930", forKey: PrefKey.timerStartTime.rawValue)
    prefs.set("1950", forKey: PrefKey.timerEndTime.rawValue)
    prefs.set(true, forKey: PrefKey.timerSkipHolidays.rawValue)
  }
  
  func populateSettings() {
    chkTimer.state = prefs.bool(forKey: PrefKey.timerSwitch.rawValue) ? .on : .off
    if let startTimeStr = prefs.string(forKey: PrefKey.timerStartTime.rawValue) {
      dpStart.dateValue = dateFormatter.date(from: startTimeStr)!
    }
    if let endTimeStr = prefs.string(forKey: PrefKey.timerEndTime.rawValue) {
      dpEnd.dateValue = dateFormatter.date(from: endTimeStr)!
    }
    chkSkipHolidays.state = prefs.bool(forKey: PrefKey.timerSkipHolidays.rawValue) ? .on : .off
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
  
  @IBAction func enableTimer(_ sender: NSButton) {
    prefs.set(sender.state == .on, forKey: PrefKey.timerSwitch.rawValue)
    Manager.shared.onSchedulerCfgChange()
  }
  
  @IBAction func setStartTime(_ sender: NSDatePicker) {
    let startTime = sender.dateValue
    let startTimeStr = dateFormatter.string(from: startTime)
    prefs.set(startTimeStr, forKey: PrefKey.timerStartTime.rawValue)
    if prefs.bool(forKey: PrefKey.timerSwitch.rawValue) {
      /* 开了 timer 才重新调度 */
      Manager.shared.onSchedulerCfgChange()
    }
  }
  
  @IBAction func setEndTime(_ sender: NSDatePicker) {
    let endTime = sender.dateValue
    let endTimeStr = dateFormatter.string(from: endTime)
    prefs.set(endTimeStr, forKey: PrefKey.timerEndTime.rawValue)
    if prefs.bool(forKey: PrefKey.timerSwitch.rawValue) {
      /* 开了 timer 才重新调度 */
      Manager.shared.onSchedulerCfgChange()
    }
  }
  
  @IBAction func skipHolidays(_ sender: NSButton) {
    prefs.set(sender.state == .on, forKey: PrefKey.timerSkipHolidays.rawValue)
    Manager.shared.onSchedulerCfgChange()
  }
}
