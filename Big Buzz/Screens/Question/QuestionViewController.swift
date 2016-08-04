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
import SVProgressHUD

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
        SVProgressHUD.show()
        // Called here because storyboard loads this VC before AppDelegate
        ref = FIRDatabase.database().reference()
        
        signIntoFirebaseAnonymously()
//        createQuestion()
        setUpUI()
        getQuestionForToday()
    }
    
    func signIntoFirebaseAnonymously() {
        FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
            if error != nil {
                print(error)
            } else {
                print(user)
            }
        }
    }
    
    func setUpUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        title = "Question Of The Day"
        showResultsButton.layer.borderColor = UIColor.whiteColor().CGColor
        showResultsButton.layer.borderWidth = 2
        showResultsButton.layer.cornerRadius = showResultsButton.frame.size.height / 2
        animateBackgroundColor()
        dateLabel.text = NSDate().fullMonthDayYear()
        AnimationManager.sharedManager.addFloatingCirclesToView(view)
    }
    
    func animateBackgroundColor() {
        UIView.animateWithDuration(5.0, delay: 0, options: .AllowUserInteraction, animations: { 
            self.view.backgroundColor = UIColor.colorForNumber(Int(arc4random_uniform(6)))
        }) { finished in
            self.animateBackgroundColor()
        }
    }
    
    func getQuestionForToday() {
        QuestionManager.sharedManager.getQuestionForDate(NSDate()) { (question, error) in
            SVProgressHUD.dismiss()
            self.handleQuestion(question, error: error)
            if UserDefaultsManager.sharedManager.didVoteToday() {
                self.showVotedState()
            } else {
                self.showVoteState()
            }
        }
    }
    
    // TODO: Create questions for next 99 days
    func createQuestion() {
        // TODO: change question
        let post = ["question": "Do you watch Netflix?",
                    "no": 0,
                    "yes": 0
                    ]
        
        // TODO: change date
        let childUpdates = ["/questions/08-04-2016": post]
        
        ref.updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func showResultsButtonTapped() {
        transitionToResultsViewController()
    }
    
    @IBAction func yesButtonTapped() {
        answerLabel.text = "YES"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        QuestionManager.sharedManager.submitVoteForQuestion(question, yesVote: true) { error in
            self.handleVote(error)
        }
    }
    
    @IBAction func noButtonTapped() {
        answerLabel.text = "NO"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        QuestionManager.sharedManager.submitVoteForQuestion(question, yesVote: false) { error in
            self.handleVote(error)
        }
    }
    
    @IBAction func otherQuestionsButtonTapped() {
        let otherQuestionsVC = OtherQuestionsViewController.ip_fromNib()
        navigationController?.pushViewController(otherQuestionsVC, animated: true)
    }
    
    // MARK: Helpers
    
    private func handleQuestion(question: Question?, error: NSError?) {
        if error != nil {
            // TODO: handle
            print(error)
        } else if let question = question {
            self.question = question
        }
    }
    
    private func handleVote(error: NSError?) {
        if error != nil {
            // TODO: handle
            print("error submitting vote")
            AnimationManager.sharedManager.stopPulsator(self.pulsator)
        } else {
            UserDefaultsManager.sharedManager.setDidVoteToday()
            self.stopPulsatorWithCompletion({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.transitionToResultsViewController()
                strongSelf.showVotedState()
                })
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
    
    private func showVoteState() {
        yesButton.alpha = 1
        noButton.alpha = 1
    }
    
    private func animateShowAnswer() {
        questionLabel.alpha = 0
        yesButton.alpha = 0
        noButton.alpha = 0
        answerLabel.alpha = 1
    }
    
}
