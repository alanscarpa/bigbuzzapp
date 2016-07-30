//
//  Constants.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/30/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

var kStartDate: String {
    let startDate = NSDateFormatter.bbFormatter().dateFromString("08-15-2016")
    if NSDate() < startDate {
        return "07-15-2016"
    } else {
        return "08-15-2016"
    }
}
