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
import Kanna

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
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var showResultsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://www.pollshare.com/top-stories")
        if let doc = HTML(url: url!, encoding: NSUTF8StringEncoding) {
            // Search for nodes by XPath
            for question in doc.xpath("(//div[@data-real-poll-id]//h4)[1]") {
                print(question.text)
            }
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        title = "Question Of The Day"
        AnimationManager.sharedManager.addFloatingCirclesToView(self.view)
        if UserDefaultsManager.sharedManager.didVoteToday() {
            showVotedState()
        }
        // Called here because storyboard loads this VC before AppDelegate
        ref = FIRDatabase.database().reference()
        questionForTodayRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let question = snapshot.value as? [String: AnyObject] {
                self.question = Question(questionDictionary: question, withDate: NSDate())
                self.getArticles()
            }
        }) { error in
            print(error)
        }
    }
    
    func getArticles() {
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
                self.getArticles()
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
