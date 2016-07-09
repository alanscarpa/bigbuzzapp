//
//  ResultsViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/5/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    
    @IBOutlet weak var agreePercentageLabel: UILabel!
    @IBOutlet weak var disagreePercentageLabel: UILabel!
    
    // A height constant of 193 == 100%
    let kOneHundredPercent: CGFloat = 193
    
    @IBOutlet weak var agreePercentageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var disagreePercentageHeighConstraint: NSLayoutConstraint!
    
    var question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        yesLabel.text = String(question.yesVotes)
        noLabel.text = String(question.noVotes)
        
        setPollResults()
    }
    
    func setPollResults() {
        let totalVotes = question.yesVotes + question.noVotes
        
        let agreePercentage = CGFloat(question.yesVotes) / CGFloat(totalVotes)
        let disagreePercentage = CGFloat(question.noVotes) / CGFloat(totalVotes)
        
        let agreeHeightConstraint = kOneHundredPercent * agreePercentage
        let disagreeHeightConstraint = kOneHundredPercent * disagreePercentage
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .PercentStyle
        numberFormatter.minimumFractionDigits = 0
        agreePercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(agreePercentage)))
        disagreePercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(disagreePercentage)))
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(2.0) {
            self.agreePercentageHeightConstraint.constant = agreeHeightConstraint
            self.disagreePercentageHeighConstraint.constant = disagreeHeightConstraint
            self.agreePercentageLabel.alpha = 1
            self.disagreePercentageLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func xButtonTapped() {
        self.navigationController?.pop(transitionType: kCATransitionFade, duration: 0.5)
    }
    
}
