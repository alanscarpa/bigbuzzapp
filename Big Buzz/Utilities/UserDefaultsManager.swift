//
//  UserDefaultsManager.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/17/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let sharedManager = UserDefaultsManager()
    
    func setDidVoteToday() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSDate().dayMonthYear())
    }
    
    func didVoteToday() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(NSDate().dayMonthYear())
    }
    
    func setDidDeclineLocalNotifications() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "localNotificationsDeclined")
    }
    
    var didDeclineLocalNotifications: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("localNotificationsDeclined")
    }
}