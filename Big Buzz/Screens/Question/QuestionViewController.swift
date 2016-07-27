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
    let pulsator = Pulsator()
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var showResultsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Called here because storyboard loads this VC before AppDelegate
        ref = FIRDatabase.database().reference()
//        createQuestion()
        setUpUI()
        getQuestionForToday()
    }
    
    func setUpUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        title = "Question Of The Day"
        dateLabel.text = NSDate().dayMonthYear()
        AnimationManager.sharedManager.addFloatingCirclesToView(view)
        if UserDefaultsManager.sharedManager.didVoteToday() {
            showVotedState()
        }
    }
    
    func getQuestionForToday() {
        QuestionManager.sharedManager.getQuestionForDate(NSDate()) { (question, error) in
            self.handleQuestion(question, error: error)
        }
    }
    
    // TODO: Create questions for next 100 days
    func createQuestion() {
        let post = ["question": "question of the 27th",
                    "no": 0,
                    "yes": 0
                    ]
        
        let childUpdates = ["/questions/07-27-2016": post]
        
        ref.updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func yesButtonTapped() {
        answerLabel.text = "YES"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        QuestionManager.sharedManager.submitYesVoteForQuestion(question, yesVote: true) { error in
            self.handleVote(error)
        }
    }
    
    @IBAction func noButtonTapped() {
        answerLabel.text = "NO"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        QuestionManager.sharedManager.submitYesVoteForQuestion(question, yesVote: false) { error in
            self.handleVote(error)
        }
    }
    
    private func handleVote(error: NSError?) {
        if error != nil {
            // TODO: handle
            print("error submitting vote")
            AnimationManager.sharedManager.stopPulsator(self.pulsator)
        } else {
            self.stopPulsatorWithCompletion({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.transitionToResultsViewController()
                strongSelf.showVotedState()
                })
        }
    }
    
    private func handleQuestion(question: Question?, error: NSError?) {
        if error != nil {
            // TODO: handle
            print(error)
        } else if let question = question {
            self.question = question
        }
    }
    
    @IBAction func showResultsButtonTapped() {
        transitionToResultsViewController()
    }
    
    @IBAction func leftDateButtonTapped() {
        getQuestionForDayBefore(true)
    }
    
    @IBAction func rightDateButtonTapped() {
        getQuestionForDayBefore(false)
    }
    
    func getQuestionForDayBefore(dayBefore: Bool) {
        QuestionManager.sharedManager.getQuestionForAdjustedDay(dayBefore: dayBefore) { (question, error) in
            self.dateLabel.text = question?.date.dayMonthYear()
            self.handleQuestion(question, error: error)
        }
        showVotedState()
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
