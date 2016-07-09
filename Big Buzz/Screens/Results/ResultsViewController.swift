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
        
        setPercentageForAgree(0.5, andDisagree: 0.9)
    }
    
    func setPercentageForAgree(agreePercentage: CGFloat, andDisagree disagreePercentage: CGFloat) {
        let agreeHeightConstraint = kOneHundredPercent * agreePercentage
        let disagreeHeightConstraint = kOneHundredPercent * disagreePercentage
        agreePercentageHeightConstraint.constant = agreeHeightConstraint
        disagreePercentageHeighConstraint.constant = disagreeHeightConstraint
    }
    
    @IBAction func xButtonTapped() {
        self.navigationController?.pop(transitionType: kCATransitionFade, duration: 0.5)
    }
    
}
