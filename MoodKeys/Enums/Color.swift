//
//  Color.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2025/1/17.
//

enum Color {
  /* Base colors */
  case WHITE
  case RED
  
  /* AQI colors */
  case DKGREEN
  case GREEN
  case LTGREEN
  case YELLOW
  case LTORANGE
  case ORANGE
  case DKORANGE
  case DKRED
  case LTPURPLE
  case PURPLE
  case DKPURPLE
  
  var rgb: [UInt8] {
    switch self {
    case .WHITE:
      return [255, 255, 255]
    case .RED:
      return [255, 0, 0]
    case .DKGREEN:
      return [0, 120, 126]
    case .GREEN:
      return [5, 154, 101]
    case .LTGREEN:
      return [133, 189, 75]
    case .YELLOW:
      return [255, 221, 51]
    case .LTORANGE:
      return [255, 186, 51]
    case .ORANGE:
      return [254, 150, 51]
    case .DKORANGE:
      return [228, 73, 51]
    case .DKRED:
      return [202, 0, 53]
    case .LTPURPLE:
      return [151, 0, 104]
    case .PURPLE:
      return [120, 0, 63]
    case .DKPURPLE:
      return [78, 0, 22]
    }
  }
}
