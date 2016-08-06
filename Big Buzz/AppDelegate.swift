//
//  AppDelegate.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/2/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit
import Firebase
import IntrepidSwiftWisdom
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let navigationVC = UINavigationController()
    let mainVC = QuestionViewController.ip_fromNib()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        FIRApp.configure()
    
        navigationVC.viewControllers = [mainVC]
        
        self.window?.rootViewController = navigationVC
        self.window?.makeKeyAndVisible()
        
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types == .None {
            print("failed")
        } else {
            let now = NSDate()
            let tomorrowComponents = NSDateComponents()
            tomorrowComponents.day = 1
            
            let calendar = NSCalendar.currentCalendar()
            if let tomorrow = calendar.dateByAddingComponents(tomorrowComponents, toDate: now, options: NSCalendarOptions.MatchFirst) {
                
                let flags: NSCalendarUnit = [.Era, .Year, .Month, .Day]
                let tomorrowValidTime: NSDateComponents = calendar.components(flags, fromDate: tomorrow)
                tomorrowValidTime.hour = 13
                
                let notification = UILocalNotification()
                notification.fireDate = calendar.dateFromComponents(tomorrowValidTime)
                notification.repeatInterval = NSCalendarUnit.Day
                notification.alertBody = "We've got a new question for you to vote on!"
                notification.alertAction = "Come vote now."
                notification.applicationIconBadgeNumber = 1
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

