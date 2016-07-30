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
        return NSDateFormatter.bbFormatter().stringFromDate(self)
    }
    
    class func dateFromString(string: String) -> NSDate? {
        return NSDateFormatter.bbFormatter().dateFromString(string)
    }
    
    class func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
    
}