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
            self.questionLabel.text = question.question
        }
    }
    var questionRef: FIRDatabaseReference {
        return ref.child("questions/\(NSDate().currentDateInDayMonthYear())")
    }
    
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
    
    deinit {
        ref.removeAllObservers()
    }

    @IBAction func yesButtonTapped() {
        submitYesVote(true)
    }
    
    @IBAction func noButtonTapped() {
        submitYesVote(false)
    }
    
    private func submitYesVote(yesVote: Bool) {
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
                let resultsVC = ResultsViewController.ip_fromNib()
                resultsVC.question = self.question
                self.navigationController?.pushViewController(resultsVC, animated: true)
            }
        }
    }
    
}

