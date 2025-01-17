//
//  Scheduler.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/30.
//

import Foundation

class Scheduler {
  /* 内部计时调度器 */
  private var dailyTimerScheduler: TimerScheduler?
  private var startTimerScheduler: TimerScheduler?
  private var endTimerScheduler: TimerScheduler?
  private var taskTimerScheduler: TimerScheduler?
  
  /* 参数 */
  private var interval: TimeInterval
  private var startTime: [Int]?
  private var endTime: [Int]?
  private var skipHolidays: Bool
  
  /* 状态 */
  private var onDuty: Bool = true
  
  init(interval: TimeInterval, startTimeStr: String?, endTimeStr: String?, skipHolidays: Bool) {
    /* 设置参数 */
    Log.d("interval: \(interval), startTimeStr: \(String(describing: startTimeStr)), endTimeStr: \(String(describing: endTimeStr)), skipHolidays: \(skipHolidays)")
    self.interval = interval
    if let tmp = startTimeStr {
      self.startTime = timeStrToArray(tmp)
    }
    if let tmp = endTimeStr {
      self.endTime = timeStrToArray(tmp)
    }
    self.skipHolidays = skipHolidays
  }
  
  /**
   * 开始调度
   * 内部逻辑：
   *  - 都关：开 task 调度器
   *  - 单开计时器：判断是否在工作时间内，在的话开 task 调度器；开 timer 调度器
   *  - 单开跳过节假日：更新 onDuty；判断是否上班，上的话开 task 调度器；开 holiday 调度器
   *  - 都开：更新 onDuty；判断是否上班，上的话判断是否在工作时间内，在的话开 task 调度器；开 timer 调度器；开 holiday 调度器
   */
  func start() {
    Log.d("start scheduling")
    
    var enableTimer = false
    var enableSkipHolidays = false
    
    taskTimerScheduler = TimerScheduler(executionTime: nil, interval: interval, task: mainTask)
    
    if startTime != nil && endTime != nil {
      /* 开了计时器 */
      startTimerScheduler = TimerScheduler(executionTime: startTime, interval: 1440, task: onStartTime)
      endTimerScheduler = TimerScheduler(executionTime: endTime, interval: 1440, task: onEndTime)
      enableTimer = true
    }
    if skipHolidays {
      /* 开了跳过节假日 */
      dailyTimerScheduler = TimerScheduler(executionTime: [0, 0], interval: 1440, task: onStartOfTheDay)
      self.onDuty = Manager.isTodayWorkday()
      enableSkipHolidays = true
    }
    
    /* 不同模式对应不同启动逻辑 */
    Log.d("enableTimer: \(enableTimer), enableSkipHolidays: \(enableSkipHolidays)")
    if !enableTimer && !enableSkipHolidays {
      /* 都关 */
      taskTimerScheduler?.start()
    } else if enableTimer && !enableSkipHolidays {
      /* 单开计时器 */
      if isCurrentTimeInRange(startTime: startTime, endTime: endTime) {
        taskTimerScheduler?.start()
      }
      startTimerScheduler?.start()
      endTimerScheduler?.start()
    } else if !enableTimer && enableSkipHolidays {
      /* 单开跳过假期 */
      if onDuty {
        taskTimerScheduler?.start()
      }
      dailyTimerScheduler?.start()
    } else if enableTimer && enableSkipHolidays {
      /* 都开 */
      if onDuty && isCurrentTimeInRange(startTime: startTime, endTime: endTime) {
        taskTimerScheduler?.start()
      }
      startTimerScheduler?.start()
      endTimerScheduler?.start()
      dailyTimerScheduler?.start()
    }
  }
  
  /**
   * 停止调度
   */
  func stop() {
    taskTimerScheduler?.stop()
    startTimerScheduler?.stop()
    endTimerScheduler?.stop()
    dailyTimerScheduler?.stop()
  }
  
  /**
   * 如果开启了跳过节假日功能，该函数每天 0 点运行一次；对应的调度器需要最后开始
   * 内部逻辑：
   *  - 只开了跳过节假日功能：每天 0 点控制 task 调度器
   *  - 同时开了计时器功能：每天 0 点只负责更新 onDuty，由 timer 调度器控制 task 调度器
   */
  private func onStartOfTheDay() {
    Log.d("Triggered")
    self.onDuty = Manager.isTodayWorkday()
    if startTime == nil || endTime == nil {
      /* 只开了跳过节假日功能 */
      if let taskStatus = taskTimerScheduler?.getStatus() {
        if self.onDuty || !taskStatus {
          taskTimerScheduler?.start()
        } else if !self.onDuty && taskStatus {
          Manager.shared.stopLighting()
          taskTimerScheduler?.stop()
        }
      }
    }
  }
  
  /**
   * 如果开启了计时器功能，该函数每天在开始时间运行一次
   * 内部逻辑：
   *  不管是否开启跳过节假日功能，根据 onDuty 控制 task 调度器
   */
  private func onStartTime() {
    Log.d("Triggered")
    if onDuty {
      taskTimerScheduler?.start()
    }
  }
  
  /**
   * 如果开启了计时器功能，该函数每天在结束时间运行一次
   * 内部逻辑：
   *  直接关灯，并关闭 task 调度器
   */
  private func onEndTime() {
    Log.d("Triggered")
    if let taskStatus = taskTimerScheduler?.getStatus(), taskStatus {
      Manager.shared.stopLighting()
      taskTimerScheduler?.stop()
    }
  }
  
  private func mainTask() {
    Log.d("Triggered")
    Manager.shared.refreshLighting()
  }
  
  private func isCurrentTimeInRange(startTime: [Int]?, endTime: [Int]?) -> Bool {
    /* 获取当前时间 */
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute, .second], from: now)
    
    guard let currentHour = components.hour, let currentMinute = components.minute, let currentSecond = components.second else {
      return false
    }
    
    /* 将当前时间转为秒表示 */
    let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
    
    /* 处理开始时间 */
    guard let start = startTime, start.count == 2 else {
      return false
    }
    let startTimeInSeconds = start[0] * 3600 + start[1] * 60
    
    /* 处理结束时间 */
    guard let end = endTime, end.count == 2 else {
      return false
    }
    let endTimeInSeconds = end[0] * 3600 + end[1] * 60
    
    if endTimeInSeconds >= startTimeInSeconds {
      /* 开始和结束在同一天 */
      return currentTimeInSeconds >= startTimeInSeconds && currentTimeInSeconds <= endTimeInSeconds
    } else {
      /* 结束时间在第二天 */
      return currentTimeInSeconds >= startTimeInSeconds || currentTimeInSeconds <= endTimeInSeconds
    }
  }
}

/**
 * 计时调度器类
 */
class TimerScheduler {
  private var timer: DispatchSourceTimer?
  private var isRunning = false
  
  private let executionTime: [Int]?
  private let interval: TimeInterval
  private let task: () -> Void
  
  init(executionTime: [Int]?, interval: TimeInterval, task: @escaping () -> Void) {
    self.executionTime = executionTime
    self.interval = interval * 60
    self.task = task
  }
  
  func start() {
    guard !isRunning else { return }
    isRunning = true
    
    if let executionTime = executionTime, executionTime.count == 2 {
      /* 设置了执行时间，计算延迟时间，延迟后开启定时器 */
      let calendar = Calendar.current
      let now = Date()
      let nextExecutionDate = calendar.nextDate(after: now, matching: DateComponents(hour: executionTime[0], minute: executionTime[1]), matchingPolicy: .nextTime)!
      
      /* 计算延迟时间 */
      let timeDelay = nextExecutionDate.timeIntervalSince(now)
      
      /* 创建定时器 */
      timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
      timer?.schedule(deadline: .now() + timeDelay, repeating: interval)
      timer?.setEventHandler { [weak self] in
        self?.task()
      }
      timer?.resume()
    } else {
      /* 没有设置执行时间，直接开启定时器 */
      timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
      timer?.schedule(deadline: .now(), repeating: interval)
      timer?.setEventHandler { [weak self] in
        self?.task()
      }
      timer?.resume()
    }
  }
  
  func stop() {
    timer?.cancel()
    timer = nil
    isRunning = false
  }
  
  func getStatus() -> Bool {
    return isRunning
  }
}
