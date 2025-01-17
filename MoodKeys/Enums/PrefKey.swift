//
//  PrefKey.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/13.
//

enum PrefKey: String {
  
  /* -- MoodKeys -- */
  case initialized
  
  /* -- Keyboard Settings -- */
  
  // Vendor ID
  case kbdVendorID
  
  // Product ID
  case kbdProductID
  
  // Usage
  case kbdUsage
  
  // Usage page
  case kbdUsagePage
  
  // Color correction switch
  case kbdColorCorrection
  
  // Color correction color
  case kbdColorCorrectionColor
  
  
  /* -- General Settings -- */
  
  // Refresh period
  case gnrPeriod
  
  // Activate on launch
  case gnrActivateOnLaunch
  
  
  /* -- AQI Settings -- */
  
  // AQICN API token
  case aqiToken
  
  // AQI auto location switch
  case aqiAutoLocation
  
  // AQI station name
  case aqiStation
  
  
  /* -- Timer Settings -- */
  
  // Timer switch
  case timerSwitch
  
  // Start time
  case timerStartTime
  
  // End time
  case timerEndTime
  
  // Skip weekends and holidays switch
  case timerSkipHolidays
}
