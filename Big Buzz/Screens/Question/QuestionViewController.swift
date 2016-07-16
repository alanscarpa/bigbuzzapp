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

class QuestionViewController: UIViewController {

    var ref = FIRDatabaseReference()
    var question = Question() {
        didSet {
            self.questionLabel.text = question.question.uppercaseString
        }
    }
    var questionRef: FIRDatabaseReference {
        return ref.child("questions/\(NSDate().currentDateInDayMonthYear())")
    }
    let pulsator = Pulsator()
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Question Of The Day"
        
        ref = FIRDatabase.database().reference()

        questionRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let question = snapshot.value as? [String: AnyObject] {
                self.question = Question(questionDictionary: question, withDate: NSDate())
                self.getArticles()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        AnimationManager.sharedManager.addFloatingCirclesToView(self.view)
    }
    
    func articleRef(articleId: String) -> FIRDatabaseReference {
        return ref.child("articles/\(articleId)")
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
    
    // MARK: Actions
    
    @IBAction func yesButtonTapped() {
        submitYesVote(true)
    }
    
    @IBAction func noButtonTapped() {
        submitYesVote(false)
    }
    
    func submitYesVote(yesVote: Bool) {
        answerLabel.text = yesVote ? "YES" : "NO"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        sendVoteToFirebase(yesVote) { error in
            if let error = error {
                print(error.localizedDescription)
                AnimationManager.sharedManager.stopPulsator(self.pulsator)
            } else {
                self.stopPulsatorWithCompletion({ [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.transitionToResultsViewController()
                    strongSelf.showAlreadyAnsweredState()
                })
            }
        }
    }
    
    func sendVoteToFirebase(yesVote: Bool, completion: (NSError?) -> Void) {
        questionRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
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
            self.showAnswer()
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
    
    private func showAlreadyAnsweredState() {
        questionLabel.alpha = 1
        answerLabel.alpha = 0
    }
    
    private func showAnswer() {
        questionLabel.alpha = 0
        yesButton.alpha = 0
        noButton.alpha = 0
        answerLabel.alpha = 1
    }
    
}
