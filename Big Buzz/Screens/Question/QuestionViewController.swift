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
        setUpUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        animateBackgroundColor()
        AnimationManager.sharedManager.addFloatingCirclesToView(view)
        if question.question.isEmpty {
            getQuestionForToday()
            reAddNotificationForTomorrow()
        }
    }
    
    func reAddNotificationForTomorrow() {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        guard settings.types != .None && !UserDefaultsManager.sharedManager.didDeclineLocalNotifications else { return }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.layer.removeAllAnimations()
        AnimationManager.sharedManager.removeCircles()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        dateLabel.text = NSDate().fullMonthDayYear()
    }
    
    func animateBackgroundColor() {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(5.0, delay:0, options: [.Repeat, .Autoreverse, .AllowUserInteraction], animations: { [weak self] in
            self?.view.backgroundColor = UIColor.colorForNumber(Int(arc4random_uniform(6)))
            self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func getQuestionForToday() {
        QuestionManager.sharedManager.getQuestionForDate(NSDate()) { [weak self] (question, error) in
            SVProgressHUD.dismiss()
            self?.handleQuestion(question, error: error)
            if UserDefaultsManager.sharedManager.didVoteToday() {
                self?.showVotedState()
            } else {
                self?.showVoteState()
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
        QuestionManager.sharedManager.submitVoteForQuestion(question, yesVote: true) { [weak self] error in
            self?.handleVote(error)
        }
    }
    
    @IBAction func noButtonTapped() {
        answerLabel.text = "NO"
        AnimationManager.sharedManager.startPulsator(pulsator, onView: questionLabel)
        QuestionManager.sharedManager.submitVoteForQuestion(question, yesVote: false) { [weak self] error in
            self?.handleVote(error)
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
        UIView.animateWithDuration(1.0, animations: { [weak self] in
            self?.animateShowAnswer()
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
