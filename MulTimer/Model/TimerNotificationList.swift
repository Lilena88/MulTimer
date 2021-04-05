//
//  TimerNotificationList.swift
//  MulTimer
//
//  Created by Елена Ким on 18.03.2021.
//

import Foundation

class TimerNotificationList: Codable {
    struct KeysForList {
        static let finishTimeKey = "finish_time"
        static let idNotificationKey = "id_of_notification"
        static let restTimeKey = "rest_time"
    }
    
    var cellKey: String = ""
    var finishTime: Int = 0
    var idNotification: String = ""
    var restTime: Int = 0
    
    func encode() -> [String : Any] {
        return [
            KeysForList.finishTimeKey: finishTime,
            KeysForList.idNotificationKey: idNotification,
            KeysForList.restTimeKey: restTime
        ]
    }
    
    func decode(dictionary: [String: Any]) -> TimerNotificationList {
        let finishTime = dictionary[KeysForList.finishTimeKey] as! Int
        let id = dictionary[KeysForList.idNotificationKey] as! String
        let restTime = dictionary[KeysForList.restTimeKey] as! Int
        let timerNotificationList = TimerNotificationList()
        timerNotificationList.finishTime = finishTime
        timerNotificationList.idNotification = id
        timerNotificationList.restTime = restTime
        return timerNotificationList
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.setValue(encode(), forKey: cellKey)
    }
    
    func retrieveFromUserDefaults() -> TimerNotificationList? {
        guard let encodedNotificationList = UserDefaults.standard.dictionary(forKey: cellKey) else {
            return nil
        }
        let decodedNotificationList = decode(dictionary: encodedNotificationList)
        return decodedNotificationList
    }
    
    func removeFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: cellKey)
    }
}
