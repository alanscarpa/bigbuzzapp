//
//  CommentInputTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/1/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class CommentInputTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.placeholder = "SAY SOMETHING..."
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
