//
//  Question.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/5/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

class Question {
    var question = ""
    var yesVotes = 0
    var noVotes = 0
    var date = NSDate()
    var articles = [Article]()
    
    convenience init(questionDictionary: [String: AnyObject], withDate date: NSDate) {
        self.init()
        if let question = questionDictionary["question"] as? String {
            self.question = question
        }
        if let yesVotes = questionDictionary["yes"] as? Int {
            self.yesVotes = yesVotes
        }
        if let noVotes = questionDictionary["no"] as? Int {
            self.noVotes = noVotes
        }
        
        let articles = NSArray(array: questionDictionary["articles"] as! [Int])
        for articleId in articles {
            self.articles.append(Article(id: String(articleId)))
        }
        
        self.date = date
    }
}