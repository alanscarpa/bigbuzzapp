//
//  NSDate+BigBuzz.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/9/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

extension NSDate {
    
    func dayMonthYear() -> String {
        return BBDateFormatter.sharedInstance.bbFormatter().stringFromDate(self)
    }
    
    func fullMonthDayYear() -> String {
        return  BBDateFormatter.sharedInstance.fullMonthFormatter().stringFromDate(self)
    }
    
    func shortMonthDay() -> String {
        return  BBDateFormatter.sharedInstance.shortFormatter().stringFromDate(self)
    }
    
    class func dateFromString(string: String) -> NSDate? {
        return  BBDateFormatter.sharedInstance.bbFormatter().dateFromString(string)
    }
    
    class func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int {
        let components = BBDateFormatter.sharedInstance.calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
    
}