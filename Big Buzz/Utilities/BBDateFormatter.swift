//
//  NSDateFormatter+BigBuzz.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/30/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

class BBDateFormatter {
    static let sharedInstance = BBDateFormatter()
    var formatter = NSDateFormatter()
    var calendar = NSCalendar.currentCalendar()
    func bbFormatter() -> NSDateFormatter {
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
    
    func fullMonthFormatter() -> NSDateFormatter {
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }
    
    func shortFormatter() -> NSDateFormatter {
        formatter.dateFormat = "MM.dd"
        return formatter
    }
}
