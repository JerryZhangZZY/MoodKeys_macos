//
//  Lighting.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2025/1/16.
//

import ViaLightingAPI

/**
 * 空光效
 */
class LightEntry {
  var brightness: UInt8?
  var effect: UInt8?
  var effectSpeed: UInt8?
  var color: [UInt8]?
  var colorAbs: [UInt8]?
}

/**
 * 白色呼吸光效
 */
class StandbyLightEntry: LightEntry {
  override init() {
    super.init()
    self.effect = 5
    self.effectSpeed = 100
    self.colorAbs = Color.WHITE.rgb
  }
}

/**
 * 红色闪烁光效
 */
class WarningLightEntry: LightEntry {
  override init() {
    super.init()
    self.effect = 5
    self.effectSpeed = 255
    self.colorAbs = Color.RED.rgb
  }
}

/**
 * 关灯光效
 */
class OffLightEntry: LightEntry {
  override init() {
    super.init()
    self.effect = 0
  }
}

/**
 * 应用光效
 */
func applyLightEntry(api: ViaLightingAPI, lightEntry: LightEntry) {
  if let effect = lightEntry.effect {
    api.setEffect(effect: effect)
    if effect == 0 {
      return
    }
  }
  if let effectSpeed = lightEntry.effectSpeed {
    api.setEffectSpeed(speed: effectSpeed)
  }
  if let colorAbs = lightEntry.colorAbs {
    api.setColorAbs(color: colorAbs)
  } else {
    if let color = lightEntry.color {
      api.setColor(color: color)
    }
    if let brightness = lightEntry.brightness {
      api.setBrightness(brightness: brightness)
    }
  }
}
