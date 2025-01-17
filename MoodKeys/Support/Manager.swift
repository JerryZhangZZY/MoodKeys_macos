//
//  Manager.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/13.
//

import Cocoa
import Foundation
import ViaLightingAPI

let DEFAULT_LOCATION = "here"

class Manager : KbdConnectionDelegate {
  
  static let shared = Manager()
  
  private var kbd: ViaLightingAPI
  var scheduler: Scheduler?
  var isActive: Bool
  var isConnected: Bool = false
  var curLightEntry: LightEntry = LightEntry()
  
  private init() {
    Log.d("Init")
    kbd = Manager.createKbdInstance()
    isActive = prefs.bool(forKey: PrefKey.gnrActivateOnLaunch.rawValue)
    setColorCorrection()
    kbd.delegate = self
  }
  
  private static func createKbdInstance() -> ViaLightingAPI {
    let vendorID = prefs.integer(forKey: PrefKey.kbdVendorID.rawValue)
    let productID = prefs.integer(forKey: PrefKey.kbdProductID.rawValue)
    let usage = prefs.integer(forKey: PrefKey.kbdUsage.rawValue)
    let usagePage = prefs.integer(forKey: PrefKey.kbdUsagePage.rawValue)
    return ViaLightingAPI(vendorID: vendorID, productID: productID, usage: usage, usagePage: usagePage)
  }
  
  /**
   * 键盘连接
   */
  func onConnected(kbdName: String) {
    Log.i("Connected to \(kbdName)")
    isConnected = true
    
    DispatchQueue.main.async {
      self.refreshStatusBarBtnImg()
    }
    
    stopLighting()
    if isActive {
      startScheduling()
    }
  }
  
  /**
   * 键盘断开
   */
  func onDisconnected() {
    Log.i("Disconnected")
    isConnected = false
    
    DispatchQueue.main.async {
      self.refreshStatusBarBtnImg()
    }
    
    if isActive {
      stopScheduling()
    }
  }
  
  /**
   * 开始调度
   */
  func startScheduling() {
    Log.d("Start scheduling")
    let timeInterval = prefs.double(forKey: PrefKey.gnrPeriod.rawValue)
    var startTimeStr: String?
    var endTimeStr: String?
    if prefs.bool(forKey: PrefKey.timerSwitch.rawValue) {
      startTimeStr = prefs.string(forKey: PrefKey.timerStartTime.rawValue)
      endTimeStr = prefs.string(forKey: PrefKey.timerEndTime.rawValue)
    }
    let skipHolidays = prefs.bool(forKey: PrefKey.timerSkipHolidays.rawValue)
    scheduler = Scheduler(interval: timeInterval, startTimeStr: startTimeStr, endTimeStr: endTimeStr, skipHolidays: skipHolidays)
    scheduler?.start()
  }
  
  /**
   * 结束调度
   */
  func stopScheduling() {
    Log.d("Stop scheduling")
    scheduler?.stop()
    scheduler = nil
  }
  
  /**
   * 切换激活状态
   */
  func toggleActiveness() {
    isActive.toggle()
    refreshStatusBarBtnImg()
    
    if isConnected {
      if isActive {
        startScheduling()
      } else {
        stopScheduling()
        stopLighting()
      }
    }
  }
  
  /*
   * 修改了键盘（API）相关参数
   */
  func onKbdCfgChange() {
    Log.d("Reinit API")
    if isActive && isConnected {
      stopScheduling()
    }
    isConnected = false
    kbd.delegate = nil
    kbd = Manager.createKbdInstance()
    setColorCorrection()
    kbd.delegate = self
  }
  
  /*
   * 修改了调度器相关参数
   */
  func onSchedulerCfgChange() {
    if isActive && isConnected {
      Log.d("Rescheduling")
      stopScheduling()
      stopLighting()
      startScheduling()
    }
  }
  
  /**
   * 更新状态栏图标
   */
  func refreshStatusBarBtnImg() {
    var image: NSImage?
    if isConnected {
      image = NSImage(named: NSImage.Name(isActive ? "StatusActive" : "StatusInactive"))
    } else {
      image = NSImage(named: NSImage.Name(isActive ? "StatusActiveDc" : "StatusInactiveDc"))
    }
    app.setStatusBarBtnImg(image)
  }
  
  func setColorCorrection() {
    if prefs.bool(forKey: PrefKey.kbdColorCorrection.rawValue) {
      if let colorString = prefs.string(forKey: PrefKey.kbdColorCorrectionColor.rawValue) {
        if let rbgArray = hexStringToRGB(hex: colorString) {
          Log.d("Set color correction: \(rbgArray)")
          kbd.setColorCorrection(trueWhite: rbgArray)
        }
      }
    } else {
      kbd.disableColorCorrection()
    }
  }
  
  /**
   * 对于不变的设置，不重复发送 HID 指令，避免键盘灯光闪烁
   */
  func smartApplyLightEntry(lightEntry: LightEntry) {
    if isConnected {
      /* 只包含有变化的灯光设置的光效 */
      let retLightEntry = LightEntry()
      
      if lightEntry.brightness != curLightEntry.brightness {
        retLightEntry.brightness = lightEntry.brightness
      }
      if lightEntry.effect != curLightEntry.effect {
        retLightEntry.effect = lightEntry.effect
      }
      if lightEntry.effectSpeed != curLightEntry.effectSpeed {
        retLightEntry.effectSpeed = lightEntry.effectSpeed
      }
      if lightEntry.color != curLightEntry.color {
        retLightEntry.color = lightEntry.color
      }
      if lightEntry.colorAbs != curLightEntry.colorAbs {
        retLightEntry.colorAbs = lightEntry.colorAbs
      }
      
      /* 应用只包含有变化的灯光设置的光效 */
      applyLightEntry(api: kbd, lightEntry: retLightEntry)
      Log.d("New light entry applied")
      
      /* 更新保存的当前光效 */
      curLightEntry = lightEntry
    } else {
      Log.w("Keyboard not connected")
    }
  }
  
  /**
   * 刷新键盘灯光
   */
  func refreshLighting() {
    if let aqi = Manager.getAqi() {
      /* 获取 AQI 成功 */
      Log.d("AQI fetched: \(aqi)")
      let lightEntry = LightEntry()
      lightEntry.effect = 1
      if aqi < 25 {
        lightEntry.colorAbs = Color.DKGREEN.rgb
      } else if aqi < 50 {
          lightEntry.colorAbs = Color.GREEN.rgb
      } else if aqi < 75 {
          lightEntry.colorAbs = Color.LTGREEN.rgb
      } else if aqi < 100 {
          lightEntry.colorAbs = Color.YELLOW.rgb
      } else if aqi < 125 {
          lightEntry.colorAbs = Color.LTORANGE.rgb
      } else if aqi < 150 {
          lightEntry.colorAbs = Color.ORANGE.rgb
      } else if aqi < 175 {
          lightEntry.colorAbs = Color.DKORANGE.rgb
      } else if aqi < 200 {
          lightEntry.colorAbs = Color.DKRED.rgb
      } else if aqi < 300 {
          lightEntry.colorAbs = Color.LTPURPLE.rgb
      } else {
          /* Insane AQI, apply breathing effect */
          lightEntry.effect = 5
          lightEntry.effectSpeed = 127
          if aqi < 400 {
              lightEntry.colorAbs = Color.PURPLE.rgb
          } else {
              lightEntry.colorAbs = Color.DKPURPLE.rgb
          }
      }
      Log.d("Refresh lighting")
      smartApplyLightEntry(lightEntry: lightEntry)
    } else {
      /* 获取 AQI 失败 */
      Log.w("AQI fetch failed")
      smartApplyLightEntry(lightEntry: WarningLightEntry())
    }
  }
  
  /**
   * 关闭键盘灯光
   */
  func stopLighting() {
    Log.d("Stop lighting")
    smartApplyLightEntry(lightEntry: OffLightEntry())
  }
  
  /**
   * 今天是否上班
   */
  static func isTodayWorkday() -> Bool {
    let duty = fetchDuty()
    Log.d("\(duty)")
    return duty
  }
  
  /**
   * 获取 AQI 值
   */
  static func getAqi() -> Int? {
    let token = prefs.string(forKey: PrefKey.aqiToken.rawValue)!
    let location = prefs.bool(forKey: PrefKey.aqiAutoLocation.rawValue) ? DEFAULT_LOCATION : prefs.string(forKey: PrefKey.aqiStation.rawValue) ?? DEFAULT_LOCATION
    if let aqi = fetchAqi(token: token, location: location) {
      return aqi
    } else {
      return nil
    }
  }
}

