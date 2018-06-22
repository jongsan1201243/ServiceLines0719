//
//  AppDelegate.swift
//  FlowCrypt
//
//  Created by Mac on 5/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SCLAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var orientationLock = UIInterfaceOrientationMask.all
    
    static var SpaceLimited : Bool = false
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask{
        return self.orientationLock
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("url \(url)")
        let urlComponents = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        let items = (urlComponents?.queryItems)! as [NSURLQueryItem] // {name = backgroundcolor, value = red}
        let defaultValues = UserDefaults.standard
        
        if let societa = defaultValues.string(forKey: "societa"){
            defaultValues.set(societa, forKey: "oldSocieta")
        }
        
        if let codice = defaultValues.string(forKey: "codice")
        {
            defaultValues.set(codice, forKey: "oldCodice")
        }
        
        defaultValues.removeObject(forKey: "descridoc")
        for item in items {
            print(item.name + ":" + item.value!)
            defaultValues.set(item.value, forKey: item.name)
        }
        
        if let rootViewController = window?.rootViewController as? ViewController {
            let recorderVC = rootViewController.viewControllers?[1] as! RecorderViewController
            recorderVC.setButtonsVisible()
//            for child in rootViewController.childViewControllers{
//                if let recorderViewController = child as RecorderViewController{
//                    recorderViewController.setButtonsVisible()
//                }
//            }
        }
//        if (url.scheme == "swiftexamples") {
//            var color: UIColor? = nil
//            var vcTitle = ""
//            if let _ = items.first, let propertyName = items.first?.name, let propertyValue = items.first?.value {
//                vcTitle = propertyName
//                if (propertyValue == "red") {
//                    color = UIColor.red
//                } else if (propertyValue == "green") {
//                    color = UIColor.green
//                }
//            }
//            
//            if (color != nil) {
//                let vc = UIViewController()
//                vc.view.backgroundColor = color
//                vc.title = vcTitle
//                let navController = UINavigationController(rootViewController: vc)
//                let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
//                vc.navigationItem.leftBarButtonItem = barButtonItem
//                self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
//                return true
//            }
//        }
        // URL Scheme entered through URL example : swiftexamples://red
        //swiftexamples://?backgroundColor=red
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.sound , .alert , .badge]))
        
        var spaceLimit = 100 // MB
        if let bundle = Bundle.main.bundleIdentifier {
            if let settings = UserDefaults.standard.array(forKey: "settings") {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
                if settings.count == 5{
                    UserDefaults.standard.set(settings, forKey: "settings")
                    let settingsArr = settings as! [Dictionary<String, Any>]
                    spaceLimit = settingsArr[4]["value"] as! Int
                }
            }
            else{
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            
        }
        
        if let bytes = deviceRemainingFreeSpaceInBytes() {
            if bytes < Int64(spaceLimit) * 1024 * 1024{
                    AppDelegate.SpaceLimited = true
                }
            }

        return true
    }
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                // something failed
                return nil
        }
        return freeSize.int64Value
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

