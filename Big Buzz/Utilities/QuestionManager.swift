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
    let kMaxAmountOfArticles = 3
    var questionForTodayRef: FIRDatabaseReference {
        return FIRDatabase.database().reference().child("questions/\(NSDate().dayMonthYear())")
    }
    var adjustedDays = 0
    var adjustedDaysInSeconds: NSTimeInterval {
        return NSTimeInterval(adjustedDays * 86400)
    }
    var adjustedDate: NSDate {
        return NSDate().dateByAddingTimeInterval(adjustedDaysInSeconds)
    }
    var canGoBackADay: Bool {
        let minimumDate = NSDateFormatter.bbFormatter().dateFromString(kStartDate)
        if NSDateFormatter.bbFormatter().dateFromString(adjustedDate.dayMonthYear()) <= minimumDate {
            return false
        } else {
            return true
        }
    }
    var canGoForwardADay: Bool {
        let currentDate = NSDateFormatter.bbFormatter().dateFromString(NSDate().dayMonthYear())
        if NSDateFormatter.bbFormatter().dateFromString(adjustedDate.dayMonthYear()) >= currentDate {
            return false
        } else {
            return true
        }
    }
    
    private func articleRef(articleId: String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("articles/\(articleId)")
    }
    
    private func questionRefForDate(date: String) -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("questions/\(date)")
    }
    
    func getQuestionForDate(date: NSDate, completion: (Question?, NSError?) -> Void) {
        questionRefForDate(date.dayMonthYear()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let questionDictionary = snapshot.value as? [String: AnyObject] {
                let question = Question(questionDictionary: questionDictionary, withDate: date)
                if question.articles.count == 0 {
                    self.getArticlesFromBingForQuestion(question, completion: { (question, error) in
                        if error != nil {
                            completion(nil, error)
                        } else {
                            completion(question, nil)
                        }
                    })
                } else {
                    self.getArticlesFromFirebaseForQuestion(question, completion: { finished in
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
    
    func getArticlesFromBingForQuestion(question: Question, completion: (Question?, NSError?) -> Void) {
        Alamofire.request(.GET, "https://api.cognitive.microsoft.com/bing/v5.0/news/search", parameters: ["q": question.question], headers: ["Ocp-Apim-Subscription-Key": kBingNewsKey])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var articleCount = 0
                        for (_, subJson):(String, JSON) in json["value"] {
                            if articleCount < self.kMaxAmountOfArticles {
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
                        self.createArticlesOnFirebaseForQuestion(question, completion: { error in
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
    
    func createArticlesOnFirebaseForQuestion(question: Question, completion: (NSError?) -> Void) {
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
        
        var childUpdates = ["questions/\(NSDate().dayMonthYear())" : post]
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
    
    func getArticlesFromFirebaseForQuestion(question: Question, completion: (Bool) -> Void) {
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
    
    func getQuestionForAdjustedDay(dayBefore dayBefore: Bool,  completion: (Question?, NSError?) -> Void) {
        guard canAdjustDate(dayBefore) else { return }
        adjustedDays = dayBefore ? adjustedDays - 1 : adjustedDays + 1
        getQuestionForDate(adjustedDate) { (question, error) in
            completion(question, error)
        }
    }
    
    func canAdjustDate(dayBefore: Bool) -> Bool {
        if dayBefore && !canGoBackADay {
            // TODO: disable next button
            return false
        } else if !dayBefore && !canGoForwardADay {
            // TODO: disable next button
            return false
        } else {
            return true
        }
    }
    
    func submitYesVoteForQuestion(question: Question, yesVote: Bool, completion: (NSError?) -> Void) {
        UserDefaultsManager.sharedManager.setDidVoteToday()
        sendVoteToFirebaseForQuestion(question, yesVote: yesVote) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func sendVoteToFirebaseForQuestion(question: Question, yesVote: Bool, completion: (NSError?) -> Void) {
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
                return FIRTransactionResult.successWithValue(currentData)
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
    
}