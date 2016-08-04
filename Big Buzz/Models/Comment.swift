//
//  Comment.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/2/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

class Comment {
    var comment = ""
    var upVotes = 0
    var id = ""
    var date = Int(NSDate().timeIntervalSince1970)
    var canBeVotedOn = true
    
    convenience init(_ id: String, comment: String = "") {
        self.init()
        self.id = id
        self.comment = comment
    }
    
    func setUpWithValues(commentDictionary: [String: AnyObject]) {
        if let comment = commentDictionary["comment"] as? String {
            self.comment = comment
        }
        if let upVotes = commentDictionary["upVotes"] as? Int {
            self.upVotes = upVotes
        }
        if let date = commentDictionary["date"] as? Int {
            self.date = date
        }
    }
}