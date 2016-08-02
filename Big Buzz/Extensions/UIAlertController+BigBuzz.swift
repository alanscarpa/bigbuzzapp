//
//  UIAlertController+BigBuzz.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/1/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func alertWithTitle(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
}