//
//  QuestionManager.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/26/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftyJSON

class QuestionManager {
    
    static let sharedManager = QuestionManager()
    private let kMaxAmountOfArticles = 3
    private var questionForTodayRef: FIRDatabaseReference {
        return FIRDatabase.database().reference().child("questions/\(NSDate().dayMonthYear())")
    }
    private var adjustedDays = 0
    private var adjustedDaysInSeconds: NSTimeInterval {
        return NSTimeInterval(adjustedDays * 86400)
    }
    private var adjustedDate: NSDate {
        return NSDate().dateByAddingTimeInterval(adjustedDaysInSeconds)
    }
    
    private func articleRef(articleId: String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("articles/\(articleId)")
    }
    
    private func commentRef(commentId: String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("comments/\(commentId)")
    }
    
    private func questionRefForDate(date: String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("questions/\(date)")
    }
    
    // MARK: Public
    
    func getQuestionForDate(date: NSDate, completion: (Question?, NSError?) -> Void) {
        questionRefForDate(date.dayMonthYear()).observeSingleEventOfType(.Value, withBlock: { [weak self] snapshot in
            if let questionDictionary = snapshot.value as? [String: AnyObject] {
                let question = Question(questionDictionary: questionDictionary, withDate: date)
                if question.articles.count == 0 {
                    self?.getArticlesFromBingForQuestion(question, completion: { (question, error) in
                        if error != nil {
                            completion(nil, error)
                        } else {
                            completion(question, nil)
                        }
                    })
                } else {
                    self?.getArticlesFromFirebaseForQuestion(question, completion: { finished in
                        completion(question, nil)
                    })
                }
            } else {
                completion(nil, NSError(domain: "com.bigbuzz", code: 001, userInfo: nil))
            }
        }) { error in
            completion(nil, error)
        }
    }
    
    func submitVoteForQuestion(question: Question, yesVote: Bool, completion: (NSError?) -> Void) {
        UserDefaultsManager.sharedManager.setDidVoteToday()
        sendVoteToFirebaseForQuestion(question, yesVote: yesVote) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func writeComment(comment: String, forQuestion question: Question, completion: (NSError?) -> ()) {
        let questionCommentRef = questionForTodayRef.child("comments").childByAutoId()
        let commentData = ["comment": comment, "upVotes": 0, "date": NSDate().timeIntervalSince1970]
        let childUpdates = ["comments/\(questionCommentRef.key)" : commentData, "\(question.firebasePath())/comments/\(questionCommentRef.key)/id": questionCommentRef.key]
        
        question.comments.insert(Comment(questionCommentRef.key, comment: comment), atIndex: 0)
        
        FIRDatabase.database().reference().updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func getCommentsForQuestion(question: Question,  completion: (NSError?) -> Void) {
        getLatestCommentsForQuestion(question) { [weak self] question, error in
            if error != nil {
                completion(error)
            } else if let question = question {
                let numberOfComments = question.comments.count
                var commentsFetched = 0
                for comment in question.comments {
                    guard let commentRef = self?.commentRef(comment.id) else { return }
                    commentRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        commentsFetched += 1
                        if let comment = question.comments.filter({ $0.id == snapshot.key }).first {
                            if let commentDictionary = snapshot.value as? [String: AnyObject] {
                                comment.setUpWithValues(commentDictionary)
                            }
                        }
                        if commentsFetched == numberOfComments {
                            completion(nil)
                        }
                    })
                }
            } else {
                completion(NSError(domain: "com.bigbuzz", code: 002, userInfo: nil))
            }
        }
    }
    
    func upVoteComment(comment: Comment, completion: (NSError?) -> Void) {
        commentRef(comment.id).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var commentDictionary = currentData.value as? [String : AnyObject] {
                var upVotes = commentDictionary["upVotes"] as? Int ?? 0
                upVotes += 1
                commentDictionary["upVotes"] = upVotes                
                currentData.value = commentDictionary
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Private
    
    private func getArticlesFromBingForQuestion(question: Question, completion: (Question?, NSError?) -> Void) {
        Alamofire.request(.GET, "https://api.cognitive.microsoft.com/bing/v5.0/news/search", parameters: ["q": question.question], headers: ["Ocp-Apim-Subscription-Key": kBingNewsKey])
            .responseJSON { [weak self] response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var articleCount = 0
                        for (_, subJson):(String, JSON) in json["value"] {
                            if articleCount < self?.kMaxAmountOfArticles {
                                var articleDictionary = [String: AnyObject]()
                                articleDictionary["title"] = subJson["name"].string
                                articleDictionary["lede"] = subJson["description"].string
                                articleDictionary["thumbnailURLString"] = subJson["image"]["thumbnail"]["contentUrl"].string
                                articleDictionary["urlString"] = subJson["url"].string
                                let article = Article()
                                article.setUpWithValues(articleDictionary)
                                question.articles.append(article)
                                articleCount += 1
                            }
                        }
                        self?.createArticlesOnFirebaseForQuestion(question, completion: { error in
                            if error != nil {
                                completion(nil, error)
                            } else {
                                completion(question, nil)
                            }
                        })
                    }
                case .Failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    private func createArticlesOnFirebaseForQuestion(question: Question, completion: (NSError?) -> Void) {
        var keys = [String]()
        var articles = [[String: String]]()
        
        for article in question.articles {
            let key = FIRDatabase.database().reference().child("articles").childByAutoId().key
            let article1 = ["lede": article.lede,
                            "thumbnailURLString" : article.thumbnailURLString,
                            "title" : article.title,
                            "urlString" : article.urlString]
            articles.append(article1)
            keys.append(key)
        }
        
        let post = ["question": question.question,
                    "no": 0,
                    "yes": 0,
                    "articles": keys]
        
        var childUpdates = ["questions/\(question.date.dayMonthYear())" : post]
        for (index, key) in keys.enumerate() {
            childUpdates["/articles/\(key)/"] = articles[index]
        }
        
        FIRDatabase.database().reference().updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    private func getArticlesFromFirebaseForQuestion(question: Question, completion: (Bool) -> Void) {
        let numberOfArticles = question.articles.count
        var articlesFetched = 0
        for article in question.articles {
            let articleRef = self.articleRef(article.id)
            articleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                articlesFetched += 1
                if let article = question.articles.filter({ $0.id == snapshot.key }).first {
                    if let articleDictionary = snapshot.value as? [String: AnyObject] {
                        article.setUpWithValues(articleDictionary)
                    }
                }
                // TODO: handle potential error
                if articlesFetched == numberOfArticles {
                    completion(true)
                }
            })
        }
    }
    
    private func sendVoteToFirebaseForQuestion(question: Question, yesVote: Bool, completion: (NSError?) -> Void) {
        questionForTodayRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var questionDictionary = currentData.value as? [String : AnyObject] {
                var noCount = questionDictionary["no"] as? Int ?? 0
                var yesCount = questionDictionary["yes"] as? Int ?? 0
                
                if yesVote {
                    yesCount += 1
                    questionDictionary["yes"] = yesCount
                } else {
                    noCount += 1
                    questionDictionary["no"] = noCount
                }
                
                question.yesVotes = yesCount
                question.noVotes = noCount
                
                currentData.value = questionDictionary
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    private func getLatestCommentsForQuestion(question: Question, completion: (Question?, NSError?) -> Void) {
        questionRefForDate(question.date.dayMonthYear()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let questionDictionary = snapshot.value as? [String: AnyObject] {
                question.updateCommentIds(questionDictionary)
                completion(question, nil)
            } else {
                completion(nil, NSError(domain: "com.bigbuzz", code: 001, userInfo: nil))
            }
        }) { error in
            completion(nil, error)
        }
    }
    
}