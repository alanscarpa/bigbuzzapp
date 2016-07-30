//
//  OtherQuestionsCollectionViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/27/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

class OtherQuestionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    
    func configureWithQuestion(question: Question) {
        dateLabel.text = question.date.dayMonthYear()
        thumbImageView.image = question.yesVotes >= question.noVotes ? UIImage(named: "bTNAgree") : UIImage(named: "bTNDisagree")
        questionLabel.text = question.question
    }

}
