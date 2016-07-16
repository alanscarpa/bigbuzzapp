//
//  AnimationManager.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/16/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation
import UIKit
import Pulsator

class AnimationManager {
    
    static var sharedManager = AnimationManager()
    
    func addFloatingCirclesToView(view: UIView) {
        for i in 0..<8 {
            let circle = UIImageView(image: UIImage(named: "Oval_Big"))
            let percentageOfCircle = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (1 - 0.35) + 0.35
            let circleSize = CGFloat(200 * percentageOfCircle)
            let animationDuration = 4.0 + (Double(i) / 2)
            view.insertSubview(circle, atIndex: 1)
            
            let yLayoutConstraint = circle.autoAlignAxisToSuperviewAxis(.Horizontal)
            yLayoutConstraint.constant = CGFloat(i * 3)
            let xLayoutConstraint = circle.autoAlignAxisToSuperviewAxis(.Vertical)
            xLayoutConstraint.constant = CGFloat(i * 3)
            
            circle.autoSetDimension(.Height, toSize: circleSize)
            circle.autoSetDimension(.Width, toSize: circleSize)
            
            let multiplier: CGFloat = i % 2 == 0 ? 1 : -1
            var rand1 = CGFloat(arc4random_uniform(100) + 50)
            rand1 = rand1 * multiplier
            var rand2 = CGFloat(arc4random_uniform(100) + 50)
            rand2 = rand2 * multiplier
            
            view.layoutIfNeeded()
            UIView.animateWithDuration(animationDuration, delay:0, options: [.Repeat, .Autoreverse], animations: {
                yLayoutConstraint.constant = rand1
                xLayoutConstraint.constant = rand2
                circle.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
                view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func startPulsator(pulsator: Pulsator, onView view: UIView) {
        view.layer.addSublayer(pulsator)
        view.superview?.layer.insertSublayer(pulsator, above: view.layer)
        pulsator.position = view.center
        
        pulsator.numPulse = 10
        pulsator.animationDuration = 2.0
        pulsator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pulsator.radius = view.frame.size.width
        pulsator.backgroundColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1.0).CGColor
        
        pulsator.start()
    }
    
    func stopPulsator(pulsator: Pulsator) {
        pulsator.stop()
    }
    
}
