//
//  DataFetcher.swift
//  MoodKeys
//
//  Created by zhangzeyu07 on 2024/12/30.
//

import Foundation

/**
 * 从 api 获取今天是否工作
 */
func fetchDuty() -> Bool {
  let semaphore = DispatchSemaphore(value: 0)
  var result: Bool = true
  
  let url = URL(string: "http://api.haoshenqi.top/holiday/today")!
  var request = URLRequest(url: url)
  request.timeoutInterval = 2
  
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
      if let data = data, let responseString = String(data: data, encoding: .utf8) {
        result = responseString == "工作"
      }
    }
    semaphore.signal()
  }
  
  task.resume()
  semaphore.wait()
  return result
}

/**
 * 从 AQICN 获取空气质量
 */
func fetchAqi(token: String, location: String) -> Int? {
  let semaphore = DispatchSemaphore(value: 0)
  var result: Int?
  
  let url = URL(string: "http://api.waqi.info/feed/\(location)/?token=\(token)")!
  var request = URLRequest(url: url)
  request.timeoutInterval = 2
  
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
      if let data = data {
        do {
          if let airQualityData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
             let status = airQualityData["status"] as? String, status == "ok",
             let dataDict = airQualityData["data"] as? [String: Any],
             let aqi = dataDict["aqi"] as? Int {
            result = aqi
          }
        } catch {}
      }
    }
    semaphore.signal()
  }
  
  task.resume()
  semaphore.wait()
  return result
}
