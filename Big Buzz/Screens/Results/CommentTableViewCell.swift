//
//  CommentTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/1/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

protocol CommentUpVoteDelegate: class {
    func upVoteButtonTapped()
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var upVotesLabel: UILabel!
    weak var delegate: CommentUpVoteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        commentLabel.text = ""
        upVotesLabel.text = ""
    }
    
    func configureWithComment(comment: Comment) {
        dateLabel.text = NSDate(timeIntervalSince1970: NSTimeInterval(comment.date)).fullMonthDayYear()
        commentLabel.text = comment.comment
        upVotesLabel.text = String(comment.upVotes)
    }
    
    @IBAction func upVoteButtonTapped() {
        delegate?.upVoteButtonTapped()
    }
}
