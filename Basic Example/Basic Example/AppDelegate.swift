//
//  AppDelegate.swift
//  Basic Example
//
//  Created by brainCloud Support on 2018-08-14.
//  Copyright © 2018 brainCloud Support. All rights reserved.
//

import UIKit
import BrainCloud
import UserNotifications
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    static var _bc: BrainCloudWrapper = BrainCloudWrapper();
    
    static var pushToken: String?;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.register(defaults: ["HasAuthenticated" : true])
        
        /*
         BRAINCLOUD_INFO
         
         // We need to create the brainCloud Wrapper
         AppDelegate._bc = BrainCloudWrapper()
         
         // Let's enable debug logging to the console, to help with testing
         AppDelegate._bc.getBCClient().enableLogging(true)
         
         // Now let's pair this brainCloud Client with our app on the brainCloud dashboard
         
         // We need to change YOUR_SECRET and YOUR_APPID to match what is on the brainCloud dashboard.
         // See the readme for more info: https://github.com/getbraincloud/braincloud-objc/blob/master/README.md
         
         AppDelegate._bc.initialize("https://api.braincloudservers.com/dispatcherv2",
         secretKey: YOUR_SECRET,
         gameId: YOUR_APPID,
         gameVersion: "1.0.0",
         companyName: YOUR_COMPANY,
         gameName: YOUR_GAME_NAME)
         */
        
        AppDelegate._bc = BrainCloudWrapper()
        
        AppDelegate._bc.getBCClient().enableLogging(true)
        
        // read YOUR_SECRET and YOUR_APPID from info.plist
        var config: [String: Any]?
                
        if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: infoPlistPath)
                
                if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    config = dict
                }
            } catch {
                print(error)
            }
        }

        AppDelegate._bc.initialize(config?["BCServerUrl"] as? String,
                                   secretKey: config?["BCSecretKey"] as? String, // Replace the Secret and
                                   appId: config?["BCAppId"] as? String, // AppId with the one on the dashboard
                                   appVersion: "1.0.0",
                                   companyName: "brainCloud",
                                   appName: "Basic - Swift")
        
        
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
//            // Enable or disable features based on authorization.
//        }
//        application.registerForRemoteNotifications()
//        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state.
          } else {
            // Show the app's signed-in state.
          }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
//        AppDelegate.pushToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
//        self.sendDeviceTokenToServer(data: deviceToken)
        AppDelegate.pushToken = deviceToken.base64EncodedString()
        print("pushToken:\((AppDelegate.pushToken ?? ""))")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
}

