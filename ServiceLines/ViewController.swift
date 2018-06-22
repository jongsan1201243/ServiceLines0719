//
//  ViewController.swift
//  FlowCrypt
//
//  Created by Mac on 5/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//

//import "FlowCrypt-Bridge-Header.h"
import UIKit
import UserNotifications
import SCLAlertView

class ViewController: UITabBarController {

    struct Notification {
        
        struct Category {
            static let tutorial = "servicelines.sync"
        }
        
        struct Action {
            static let readLater = "readLater"
            static let uploadAll = "uploadAll"
            static let close = "closeNotification"
        }
        
    }
    
    // MARK: - View Life Cycle
    
    public func registerSyncNotification(syncTime: TimeInterval) {
        // Request Notification Settings
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization(completionHandler: { (success) in
                        guard success else { return }
                        
                        // Schedule Local Notification
                        self.scheduleLocalNotification(notifyTime: syncTime)
                    })
                case .authorized:
                    // Schedule Local Notification
                    self.scheduleLocalNotification(notifyTime: syncTime)
                case .denied:
                    print("Application Not Allowed to Display Notifications")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Private Methods
    
    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            // Define Actions
            //        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
            let actionUploadAll = UNNotificationAction(identifier: Notification.Action.uploadAll, title: "PROCEDI ORA", options: [.foreground])
            let actionClose = UNNotificationAction(identifier: Notification.Action.close, title: "ANNULLA", options: [.destructive, .authenticationRequired])
            
            // Define Category
            let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionUploadAll, actionClose], intentIdentifiers: [], options: [])
            
            // Register Category
            UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                if let error = error {
                    print("Request Authorization Failed (\(error), \(error.localizedDescription))")
                }
                
                completionHandler(success)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func scheduleLocalNotification(notifyTime: TimeInterval) {
        // Create Notification Content
        if #available(iOS 10.0, *) {
            let notificationContent = UNMutableNotificationContent()
            // Configure Notification Content
            notificationContent.title = "Service Lines"
            //        notificationContent.subtitle = "Local Notifications"
            notificationContent.body = "Ricordati di trasferire le registrazioni e le immagini al server Servicelines!"
            
            // Set Category Identifier
            notificationContent.categoryIdentifier = Notification.Category.tutorial
            
            // Add Trigger
            //        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60.0, repeats: true)
            var dateComponents = DateComponents()
            dateComponents.hour = notifyTime.timeIntervalAsHours()
            dateComponents.minute = notifyTime.timeIntervalAsMinutes()
            let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create Notification Request
            let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: dateTrigger)
            
            // Add Request to User Notification Center
            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                if let error = error {
                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBOutlet weak var btnContinueWithGmail: UIButton!
    
    var accessToken: String?
    let titlebarHeight = 40
    let titleLabel = UILabel()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        btnContinueWithGmail.layer.borderWidth = 1
//        btnContinueWithGmail.layer.borderColor = UIColor.gray.cgColor
        //self.tabBar.frame = CGRect(x: 0, y: 20, width: self.tabBar.frame.width, height: 50)
        
        configureUserNotificationsCenter()

        if let settings = UserDefaults.standard.array(forKey: "settings"){
            let settingsArr = settings as! [Dictionary<String, Any>]
            let syncTime = settingsArr[3]["value"] as! Int
            registerSyncNotification(syncTime: TimeInterval(syncTime))
        }
        
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        
        let rectArea = CGRect(x: 0, y: 20, width: Int(view.frame.width), height: titlebarHeight)
        titleLabel.frame = rectArea
        titleLabel.textAlignment = .center
        titleLabel.text = "SERVICE LINES"
        titleLabel.backgroundColor = UIColor.clear
        self.view.bringSubview(toFront: titleLabel)
        
        self.view.addSubview(titleLabel)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.selectedIndex=1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate{
            delegate.orientationLock = .all
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let titleWidth = view.frame.height
        let rectArea = CGRect(x: 0, y: 20, width: Int(titleWidth), height: titlebarHeight)
        titleLabel.frame = rectArea
        let toolbars = view.subviews.filter({$0 is UIToolbar})
        if toolbars.count > 0{
            toolbars[0].frame = rectArea
        }
    }
    
    func showMessage(_ message: String, title: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)

    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.uploadAll:
            print("Upload all clicked at notification.")
            self.selectedIndex = 2
        case Notification.Action.close:
            print("Close Notification")
        default:
            print("Other Action")
        }
        
        completionHandler()
    }
}


