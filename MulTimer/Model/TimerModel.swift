//
//  TimerModel.swift
//  MulTimer
//
//  Created by Елена Ким on 31.03.2021.
//

import Foundation
import UIKit
import UserNotifications
import AVFoundation

class TimerModel {
    var timer = Timer()
    var totalTime = 0
    var finishTime = 0
    var idNotification: String = ""
    var restTime = 0
    
    let centerNotification = UNUserNotificationCenter.current()
    let contentNotification = UNMutableNotificationContent()
    let timerNotificationList = TimerNotificationList()
    let defaults = UserDefaults.standard
    let systemSoundID: SystemSoundID = 1304
    
    func stopTimer(_ timerID: String) {
        timer.invalidate()
        defaults.removeObject(forKey: timerID)
        centerNotification.removePendingNotificationRequests(withIdentifiers: [idNotification])
    }
    
    func startTimer(_ durationSaveConstantTotalTime: Int, _ timerID: String, _ timerName: UILabel, _ durationLabel: UILabel, _ startPauseButton: UIButton) {
        let currentTime = Int((NSDate().timeIntervalSince1970))
        finishTime = currentTime + totalTime
        let id = Int.random(in: 0...4000000000)
        idNotification = String(id)
        timerNotificationList.finishTime = finishTime
        timerNotificationList.idNotification = idNotification
        timerNotificationList.restTime = 0
        defaults.set(timerNotificationList.encode(), forKey: timerID)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            let now = Int(NSDate().timeIntervalSince1970)
            if now <= self.finishTime {
                self.totalTime = self.finishTime - now
                durationLabel.text = self.timeToHoursMinSecFormat(time: self.totalTime)
            } else {
                self.stopTimer(timerID)
                durationLabel.text = "Complete!"
                AudioServicesPlaySystemSound(self.systemSoundID)
                durationLabel.isUserInteractionEnabled = true
                self.totalTime = durationSaveConstantTotalTime
                startPauseButton.setTitle("Start", for: .normal)
                startPauseButton.setTitleColor(.systemGreen, for: .normal)
            }
        })
        timer.tolerance = 0.1
        setNotificationTimer(timeInterval: TimeInterval(totalTime), name: timerName.text!, idNotification: String(idNotification))
    }
    
    func pauseTimer(_ timerID: String, _ durationLabel: UILabel){
        stopTimer(timerID)
        timerNotificationList.finishTime = 0
        timerNotificationList.idNotification = ""
        if totalTime == 0 {
            timerNotificationList.restTime = 1
            totalTime = 1
            durationLabel.text = timeToHoursMinSecFormat(time: totalTime)
        } else {
            timerNotificationList.restTime = totalTime
            restTime = totalTime
            totalTime = restTime
        }
        defaults.set(timerNotificationList.encode(), forKey: timerID)
    }
    
    func timeToHoursMinSecFormat(time: Int) -> String {
        let hours = time / 3600 % 60
        let prodMinutes = time / 60 % 60
        let prodSeconds = time % 60
        
        if hours  == 0 {
            return String(format: "%02d:%02d", prodMinutes, prodSeconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, prodMinutes, prodSeconds)
        }
    }
    
    func setNotificationTimer (timeInterval: TimeInterval, name: String, idNotification: String ) {
        contentNotification.body = name
        contentNotification.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: idNotification, content: contentNotification, trigger: trigger)
        centerNotification.add(request) { (error) in
            if error != nil {
                print("Error local notification \(error?.localizedDescription ?? "Error local notification")")
            }
        }
    }
    
    func startAppAfterTerminate(_ durationSaveConstantTotalTime: Int,_ timerID: String, _ timerName: UILabel, _ durationLabel: UILabel){
        timerNotificationList.cellKey = timerID
        if let encodedNotificationList = UserDefaults.standard.dictionary(forKey: timerID) {
            let decodedNotificationList = timerNotificationList.decode(dictionary: encodedNotificationList)
            finishTime = decodedNotificationList.finishTime
            idNotification = decodedNotificationList.idNotification
            restTime = decodedNotificationList.restTime
            durationLabel.text = self.timeToHoursMinSecFormat(time: restTime)
            
            let now = Int((NSDate().timeIntervalSince1970))
            if finishTime >= now {
                durationLabel.text = self.timeToHoursMinSecFormat(time: (finishTime - now))
                let id = Int.random(in: 0...4000000000)
                idNotification = String(id)
                timerNotificationList.finishTime = finishTime
                timerNotificationList.idNotification = idNotification
                defaults.set(timerNotificationList.encode(), forKey: timerID)
                
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                    let now = Int(NSDate().timeIntervalSince1970)
                    if now <= self.finishTime {
                        self.totalTime = self.finishTime - now
                        durationLabel.text = self.timeToHoursMinSecFormat(time: self.totalTime)
                    } else {
                        self.stopTimer(timerID)
                        durationLabel.text = "COMPLETED!"
                        durationLabel.isUserInteractionEnabled = true
                        self.totalTime = durationSaveConstantTotalTime
                    }
                })
                timer.tolerance = 0.1
            } else {
                timer.invalidate()
            }
        } else {
            print("NotificationList is empty for cell")
            durationLabel.text = timeToHoursMinSecFormat(time: durationSaveConstantTotalTime)
        }
    }
}
