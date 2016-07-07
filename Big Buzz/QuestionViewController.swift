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

extension NSDate {
    func currentDateInDayMonthYear() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.stringFromDate(self)
    }
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Question Of The Day"
        
        ref = FIRDatabase.database().reference()
        
        questionRef.observeEventType(.Value, withBlock: { snapshot in
            if let question = snapshot.value as? [String: AnyObject] {
                self.question = Question(questionDictionary: question, withDate: NSDate())
                print(self.question.yesVotes)
            }
        })
    
        // This overwrites any value and children
        // ref.child("users").child("244634").setValue(["username": "bigAl"])
        
        // This updates value
//         ref.child("users/244634/username").setValue("bigAl3") { (error, ref) in
//            if error != nil {
//                print(error)
//            } else {
//                print(ref)
//            }
//        }
        // You can create new nodes
        // ref.child("users/244634/age").setValue(28)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        addFloatingCircles()
    }
    
    func addFloatingCircles() {
        for i in 0..<8 {
            let circle = UIImageView(image: UIImage(named: "Oval_Big"))
            let percentageOfCircle = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (1 - 0.25) + 0.25
            let circleSize = CGFloat(100 * percentageOfCircle)
            let animationDuration = 4.0 + (Double(i) / 2)
            self.view.insertSubview(circle, atIndex: 1)
            
            let yLayoutConstraint = circle.autoAlignAxisToSuperviewAxis(.Horizontal)
            yLayoutConstraint.constant = CGFloat(i * 3)
            let xLayoutConstraint = circle.autoAlignAxisToSuperviewAxis(.Vertical)
            xLayoutConstraint.constant = CGFloat(i * 3)
            
            circle.autoSetDimension(.Height, toSize: circleSize)
            circle.autoSetDimension(.Width, toSize: circleSize)
            
            let multiplier: CGFloat = i % 2 == 0 ? 1 : -1
            var rand1 = CGFloat(arc4random_uniform(100) + 50)
            rand1 = rand1 * multiplier
            var rand2 = CGFloat(arc4random_uniform(100) + 50)
            rand2 = rand2 * multiplier
            
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(animationDuration, delay:0, options: [.Repeat, .Autoreverse], animations: {
                yLayoutConstraint.constant = rand1
                xLayoutConstraint.constant = rand2
                circle.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    deinit {
        ref.removeAllObservers()
        
    }

    @IBAction func yesButtonTapped() {
        submitYesVote(true)
    }
    
    @IBAction func noButtonTapped() {
        submitYesVote(false)
    }
    
    func submitYesVote(yesVote: Bool) {
        questionLabel.layer.addSublayer(pulsator)
        questionLabel.superview?.layer.insertSublayer(pulsator, above: questionLabel.layer)
        pulsator.position = questionLabel.center
        
        pulsator.numPulse = 10
        pulsator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pulsator.radius = questionLabel.frame.size.width
        pulsator.backgroundColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1.0).CGColor
        
        pulsator.start()
        
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
    
                currentData.value = question
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.stopPulsator()
            }
        }
    }
    
    func stopPulsator() {
        UIView.animateWithDuration(2.0, animations: {
            self.questionLabel.alpha = 0
            self.yesButton.alpha = 0
            self.noButton.alpha = 0
        }) { [weak self] finished in
            guard let strongSelf = self else { return }
            strongSelf.pulsator.stop()
            let resultsVC = ResultsViewController.ip_fromNib()
            resultsVC.question = strongSelf.question
            strongSelf.navigationController?.push(viewController: resultsVC, transitionType: kCATransitionFade, duration: 1.0)
        }
    }
    
}

