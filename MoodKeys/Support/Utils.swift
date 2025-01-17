//
//  Utils.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2025/1/3.
//

import Cocoa

/**
 * NSColor 转 HEX 字符串
 */
func colorToHexString(color: NSColor) -> String {
  let red = Int(color.redComponent * 255.0)
  let green = Int(color.greenComponent * 255.0)
  let blue = Int(color.blueComponent * 255.0)
  return String(format: "#%02X%02X%02X", red, green, blue)
}

/**
 * HEX 字符串转 NSColor
 */
func hexStringToColor(hex: String) -> NSColor? {
  guard hex.hasPrefix("#"), hex.count == 7 else { return nil }
  
  let rString = String(hex[hex.index(hex.startIndex, offsetBy: 1)..<hex.index(hex.startIndex, offsetBy: 3)])
  let gString = String(hex[hex.index(hex.startIndex, offsetBy: 3)..<hex.index(hex.startIndex, offsetBy: 5)])
  let bString = String(hex[hex.index(hex.startIndex, offsetBy: 5)..<hex.index(hex.startIndex, offsetBy: 7)])
  
  var r: UInt64 = 0
  var g: UInt64 = 0
  var b: UInt64 = 0
  
  Scanner(string: rString).scanHexInt64(&r)
  Scanner(string: gString).scanHexInt64(&g)
  Scanner(string: bString).scanHexInt64(&b)
  
  return NSColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
}

/**
 * HEX 字符串转 [R, G, B] 数组
 */
func hexStringToRGB(hex: String) -> [UInt8]? {
  var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
  if hexColor.hasPrefix("#") {
    hexColor.remove(at: hexColor.startIndex)
  }
  
  guard hexColor.count == 6 || hexColor.count == 3 else {
    return nil
  }
  
  if hexColor.count == 3 {
    let r = hexColor[hexColor.startIndex]
    let g = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 1)]
    let b = hexColor[hexColor.index(hexColor.startIndex, offsetBy: 2)]
    hexColor = "\(r)\(r)\(g)\(g)\(b)\(b)"
  }
  
  var rgb: [UInt8] = []
  for i in stride(from: 0, to: hexColor.count, by: 2) {
    let startIndex = hexColor.index(hexColor.startIndex, offsetBy: i)
    let endIndex = hexColor.index(startIndex, offsetBy: 2)
    let hexComponent = String(hexColor[startIndex..<endIndex])
    if let value = UInt8(hexComponent, radix: 16) {
      rgb.append(value)
    } else {
      return nil
    }
  }
  
  return rgb
}

/**
 * "HHmm" 转 [Int, Int]
 */
func timeStrToArray(_ timeString: String) -> [Int]? {
  guard timeString.count == 4 else {
    return nil
  }
  
  let hourString = String(timeString.prefix(2))
  let minuteString = String(timeString.suffix(2))
  
  if let hour = Int(hourString), let minute = Int(minuteString) {
    return [hour, minute]
  }
  
  return nil
}

class Log {
  private static var curLogLevel: LogLevel = .off
  
  enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case off = 4
    
    var description: String {
      switch self {
      case .debug:
        return "DEBUG"
      case .info:
        return "INFO "
      case .warning:
        return "WARN "
      case .error:
        return "ERROR"
      case .off:
        return "OFF"
      }
    }
  }
  
  static func setLevel(_ logLevel: LogLevel) {
    curLogLevel = logLevel
  }
  
  static func d(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(msg, .debug, file: file, function: function, line: line)
  }
  
  static func i(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(msg, .info, file: file, function: function, line: line)
  }
  
  static func w(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(msg, .warning, file: file, function: function, line: line)
  }
  
  static func e(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(msg, .error, file: file, function: function, line: line)
  }
  
  private static func log(_ msg: String, _ logLevel: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
    if logLevel.rawValue >= curLogLevel.rawValue {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MM-dd hh:mm:ss.SSS"
      let timestamp = dateFormatter.string(from: Date())
      let fileName = (file as NSString).lastPathComponent
      let logMessage = "\(timestamp) \(logLevel.description) [\(fileName) \(function):\(line)] \(msg)"
      print(logMessage)
    }
  }
}
