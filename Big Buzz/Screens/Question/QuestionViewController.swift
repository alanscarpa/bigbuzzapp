//
//  ViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/2/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import IntrepidSwiftWisdom
import EasyAnimation
import PureLayout
import Pulsator
import Alamofire
import SwiftyJSON

class QuestionViewController: UIViewController {

    var ref = FIRDatabaseReference()
    var question = Question() {
        didSet {
            self.questionLabel.text = question.question.uppercaseString
        }
    }
    var questionForTodayRef: FIRDatabaseReference {
        return ref.child("questions/\(NSDate().currentDateInDayMonthYear())")
    }
    let pulsator = Pulsator()
    var adjustedDays = 0
    var adjustedDaysInSeconds: NSTimeInterval {
        return NSTimeInterval(adjustedDays * 86400)
    }
    var adjustedDate: String {
        return NSDate().dateByAddingTimeInterval(adjustedDaysInSeconds).currentDateInDayMonthYear()
    }
    var canGoBackADay: Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let minimumDate = dateFormatter.dateFromString("07-16-2016")
        if dateFormatter.dateFromString(adjustedDate) <= minimumDate {
            return false
        } else {
            return true
        }
    }
    var canGoForwardADay: Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let currentDate = dateFormatter.dateFromString(NSDate().currentDateInDayMonthYear())
        if dateFormatter.dateFromString(adjustedDate) >= currentDate {
            return false
        } else {
            return true
        }
    }
    let kMaxAmountOfArticles = 3
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var showResultsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Called here because storyboard loads this VC before AppDelegate
        ref = FIRDatabase.database().reference()
        
        // Get question for today
        
        // See if articles key exists, if so, getArticlesFromFirebase()
        
        // If it does not exist, make call to getArticlesFromBing() and update question
        
        
//        createArticles()
        
        // todo: make sure this works
//        createQuestion()
        getQuestion()

        
//        getArticlesFromBing()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        title = "Question Of The Day"
        AnimationManager.sharedManager.addFloatingCirclesToView(self.view)
        
        if UserDefaultsManager.sharedManager.didVoteToday() {
            showVotedState()
        }
        
        
    }
    
    func getArticlesFromBing() {
        Alamofire.request(.GET, "https://api.cognitive.microsoft.com/bing/v5.0/news/search", parameters: ["q": self.question.question], headers: ["Ocp-Apim-Subscription-Key": kBingNewsKey])
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
                                self.question.articles.append(article)
                                articleCount += 1
                            }
                        }
                        self.createArticlesOnFirebaseForQuestion(self.question)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    func getQuestion() {
        questionForTodayRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let question = snapshot.value as? [String: AnyObject] {
                self.question = Question(questionDictionary: question, withDate: NSDate())
                if self.question.articles.count == 0 {
                    self.getArticlesFromBing()
                } else {
                    self.getArticlesFromFirebase()
                }
            } else {
                // TODO:  Handle gracefully
                print("There is no question today.")
            }
        }) { error in
            print(error)
        }
    }
    
    func createQuestion() {
        let post = ["question": "question of the day",
                    "no": 0,
                    "yes": 0
                    ]
        
        let childUpdates = ["/questions/07-26-2016": post]
        
        ref.updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
            }
        }
    }
    
    func createArticlesOnFirebaseForQuestion(question: Question) {
        var keys = [String]()
        var articles = [[String: String]]()
        
        for article in question.articles {
            let key = ref.child("articles").childByAutoId().key
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
        
        var childUpdates = ["questions/\(NSDate().currentDateInDayMonthYear())" : post]
        for (index, key) in keys.enumerate() {
            childUpdates["/articles/\(key)/"] = articles[index]
        }
        
        ref.updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
            }
        }
    }
    
    func getArticlesFromFirebase() {
        for article in self.question.articles {
            let articleRef = self.articleRef(article.id)
            articleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let article = self.question.articles.filter({ $0.id == snapshot.key }).first {
                    if let articleDictionary = snapshot.value as? [String: AnyObject] {
                        article.setUpWithValues(articleDictionary)
                    }
                }
            })
        }
    }
    
    func articleRef(articleId: String) -> FIRDatabaseReference {
        return ref.child("articles/\(articleId)")
    }
    
    // MARK: Actions
    
    @IBAction func yesButtonTapped() {
        submitYesVote(true)
    }
    
    @IBAction func noButtonTapped() {
        submitYesVote(false)
    }
    
    @IBAction func showResultsButtonTapped() {
        transitionToResultsViewController()
    }
    
    @IBAction func leftDateButtonTapped() {
        getQuestionForPreviousDay()
    }
    
    @IBAction func rightDateButtonTapped() {
        getQuestionForNextDay()
    }
    
    func getQuestionForPreviousDay() {
        guard canGoBackADay else { return }
        adjustedDays -= 1
        showVotedState()
        getQuestionForAdjustedDay(dayBefore: true)
    }
    
    func getQuestionForNextDay() {
        guard canGoForwardADay else { return }
        adjustedDays += 1
        showVotedState()
        getQuestionForAdjustedDay(dayBefore: false)
    }
    
    func getQuestionForAdjustedDay(dayBefore dayBefore: Bool) {
        ref.child("questions/\(adjustedDate)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let question = snapshot.value as? [String: AnyObject] {
                self.question = Question(questionDictionary: question, withDate: NSDate())
                self.getArticlesFromFirebase()
            } else {
                if dayBefore {
                    self.getQuestionForPreviousDay()
                } else {
                    self.getQuestionForNextDay()
                }
            }
        })
    }
    
    func submitYesVote(yesVote: Bool) {
        answerLabel.text = yesVote ? "YES" : "NO"
        UserDefaultsManager.sharedManager.setDidVoteToday()
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        sendVoteToFirebase(yesVote) { error in
            if let error = error {
                print(error.localizedDescription)
                AnimationManager.sharedManager.stopPulsator(self.pulsator)
            } else {
                self.stopPulsatorWithCompletion({ [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.transitionToResultsViewController()
                    strongSelf.showVotedState()
                })
            }
        }
    }
    
    func sendVoteToFirebase(yesVote: Bool, completion: (NSError?) -> Void) {
        questionForTodayRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var question = currentData.value as? [String : AnyObject] {
                var noCount = question["no"] as? Int ?? 0
                var yesCount = question["yes"] as? Int ?? 0
                
                if yesVote {
                    yesCount += 1
                    question["yes"] = yesCount
                } else {
                    noCount += 1
                    question["no"] = noCount
                }
                
                self.question.yesVotes = yesCount
                self.question.noVotes = noCount
                
                currentData.value = question
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
    
    func stopPulsatorWithCompletion(completion: () -> Void) {
        UIView.animateWithDuration(1.0, animations: {
            self.animateShowAnswer()
        }) { [weak self] finished in
            guard let strongSelf = self else { return }
            AnimationManager.sharedManager.stopPulsator(strongSelf.pulsator)
            completion()
        }
    }
    
    // MARK: Helpers
    
    private func transitionToResultsViewController() {
        let resultsVC = ResultsViewController.ip_fromNib()
        resultsVC.question = self.question
        navigationController?.push(viewController: resultsVC, transitionType: kCATransitionFade, duration: 0.5)
    }
    
    private func showVotedState() {
        questionLabel.alpha = 1
        answerLabel.alpha = 0
        yesButton.alpha = 0
        noButton.alpha = 0
        showResultsButton.hidden = false
    }
    
    private func animateShowAnswer() {
        questionLabel.alpha = 0
        yesButton.alpha = 0
        noButton.alpha = 0
        answerLabel.alpha = 1
    }
    
}
