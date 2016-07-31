//
//  UIColor+BigBuzz.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/27/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

extension UIColor {

    class func bbCyanTwo() -> UIColor {
        return UIColor(red: 0.0 / 255.0, green: 235.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }

    class func bbVibrantGreen() -> UIColor {
        return UIColor(red: 3.0 / 255.0, green: 222.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
    }
    
    class func bbOrangeish() -> UIColor {
        return UIColor(red: 251.0 / 255.0, green: 138.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
    }

    class func bbUglyYellow() -> UIColor {
        return UIColor(red: 227.0 / 255.0, green: 205.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }
    
    class func bbRedPink() -> UIColor {
        return UIColor(red: 247.0 / 255.0, green: 33.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    }
    
    class func colorForNumber(row: Int) -> UIColor {
        var colorNumber = row + 1
        if colorNumber % 5 > 0 {
            colorNumber = colorNumber % 5
        }
        var color = UIColor()
        if colorNumber % 5 == 0 {
            color = UIColor.bbRedPink()
        } else if colorNumber % 4 == 0 {
            color = UIColor.bbUglyYellow()
        } else if colorNumber % 3 == 0 {
            color = UIColor.bbOrangeish()
        } else if colorNumber % 2 == 0 {
            color = UIColor.bbVibrantGreen()
        } else {
            color = UIColor.bbCyanTwo()
        }
        return color
    }
    
}