//
//  NSDateFormatter+BigBuzz.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/30/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    class func bbFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter
    }
}