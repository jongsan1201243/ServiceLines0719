//
//  ServicelinesTools.swift
//  ServiceLines
//
//  Created by Mac on 19/06/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UserNotifications

class ServiceLinesTools{
    
    static func registerSyncNotification(notifyTime: TimeInterval){
        
//        let ok = UNNotificationAction(identifier: "OKIdentifier",
//                                      title: "OK", options: [])
//        
//        let cancel = UNNotificationAction(identifier: "CancelIdentifier",
//                                          title: "Cancel",
//                                          options: [])
//        
//        let category = UNNotificationCategory(identifier: "message",
//                                              actions: [ok, cancel],
//                                              minimalActions: [ok, cancel],
//                                              intentIdentifiers: [],
//                                              options: [])
//        
//        UNUserNotificationCenter.current().setNotificationCategories([category!])
        
//        let content = UNMutableNotificationContent()
//        content.title = contentTitle
//        content.subtitle = contentSubtitle
//        content.body = contentBody
        
//        let model: TimeIntervalNotificationModel = notificationsModel as!  TimeIntervalNotificationModel
//        
//        trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: model.timeInterval!, repeats: notificationsModel.repeats) as UNTimeIntervalNotificationTrigger
//        
//        let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().add(request){(error) in
//            if (error != nil){
//                //handle here
//                print("Error: Adding notification failed:\(error?.description)")
//                
//                self.delegate?.didFailToAddNotification(error: error!)
//            }
//        }
        
//        let content = UNMutableNotificationContent()
//        content.title = "Servicelines Notification"
//        content.body = "Ricordati di trasferire le registrazioni e le immagini al server Servicelines!"
//        content.categoryIdentifier = "message"
//        
//        var dateComponents = DateComponents()
//        dateComponents.hour = notifyTime.timeIntervalAsHours()
//        dateComponents.minute = notifyTime.timeIntervalAsMinutes()
//        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        
////        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0, repeats: true)
//        let request = UNNotificationRequest(identifier: "10.second.message", content: content, trigger: dateTrigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }
    

}
