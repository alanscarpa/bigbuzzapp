//
//  CommentTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/1/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

protocol CommentUpVoteDelegate: class {
    func upVoteButtonTapped(sender: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var upVotesLabel: UILabel!
    weak var delegate: CommentUpVoteDelegate?
    var canVote = true
    var comment: Comment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        commentLabel.text = ""
        upVotesLabel.text = ""
        comment = nil
    }
    
    func configureWithComment(comment: Comment) {
        dateLabel.text = NSDate(timeIntervalSince1970: NSTimeInterval(comment.date)).fullMonthDayYear()
        commentLabel.text = comment.comment
        upVotesLabel.text = String(comment.upVotes)
        self.comment = comment
    }
    
    @IBAction func upVoteButtonTapped() {
        guard let comment = comment where comment.canBeVotedOn else { return }
        comment.canBeVotedOn = false
        let currentUpVotes = Int(upVotesLabel.text ?? "0") ?? 0
        upVotesLabel.text = String(currentUpVotes + 1)
        delegate?.upVoteButtonTapped(self)
    }
}
