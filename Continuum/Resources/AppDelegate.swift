//
//  AppDelegate.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func checkICloudStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(false)
                return
            } else {
                DispatchQueue.main.async {
                    let tabBarController = self.window?.rootViewController
                    let errorMessage = "Sign into Cloud in settings"
                    switch status {
                    case .available:
                        completion(true)
                    case .noAccount:
                        tabBarController?.presentSimpleAlert(title: "You have no account!", message: "Please create one.")
                        completion(false)
                    case .couldNotDetermine:
                        tabBarController?.presentSimpleAlert(title: "Unknown error occurred, please try again.", message: nil   )
                        completion(false)
                    case .restricted:
                        tabBarController?.presentSimpleAlert(title: "Restricted user", message: "Please login to accessible user")
                        completion(false)
                    default:
                        tabBarController?.presentSimpleAlert(title: "WTF IS HAPPENING", message: nil)
                        completion(false)
                    }
                }
            }
        }
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            application.registerForRemoteNotifications()
            
            checkICloudStatus { (success) in
                let checkedUserInfo = success ? "Got 'em" : "Don't gott'em"
                print(checkedUserInfo)
            }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                if let error = error {
                    print("💩  There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)  💩")
                    return
                }
                success ? print("Successfully authorized to send push notfiication") : print("DENIED, Can't send this person notificiation")
            }
            application.registerForRemoteNotifications()
            return true
        }
    }
}
