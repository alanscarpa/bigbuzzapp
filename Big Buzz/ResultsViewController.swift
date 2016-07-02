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
    
    var question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        yesLabel.text = String(question.yesVotes)
        noLabel.text = String(question.noVotes)
    }
}
