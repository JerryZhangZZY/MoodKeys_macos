//
//  Main.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/12.
//

import Cocoa
import Foundation

var app: AppDelegate!

let prefs = UserDefaults.standard

private let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
let mainPrefsVc = storyboard.instantiateController(withIdentifier: "MainPrefsVC") as? MainPrefsViewController
let kbdPrefsVc = storyboard.instantiateController(withIdentifier: "KbdPrefsVC") as? KbdPrefsViewController
let timerPrefVc = storyboard.instantiateController(withIdentifier: "TimerPrefsVC") as? TimerPrefsViewController
let aqiPrefVc = storyboard.instantiateController(withIdentifier: "AqiPrefsVC") as? AqiPrefsViewController
let aboutPrefsVc = storyboard.instantiateController(withIdentifier: "AboutPrefsVC") as? AboutPrefsViewController

autoreleasepool { () in
#if DEBUG
  Log.setLevel(.debug)
#else
  Log.setLevel(.off)
#endif
  
  let mc = NSApplication.shared
  let mcDelegate = AppDelegate()
  mc.delegate = mcDelegate
  mc.run()
}
