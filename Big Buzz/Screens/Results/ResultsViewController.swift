//
//  ResultsViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/5/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation
import UIKit
import IntrepidSwiftWisdom
import Firebase
import SVProgressHUD

class ResultsViewController: UITableViewController, CommentInputDelegate, CommentUpVoteDelegate {
    
    @IBOutlet weak var yesPercentageLabel: UILabel!
    @IBOutlet weak var noPercentageLabel: UILabel!
    
    // A height constant of 193 == 100%
    let kOneHundredPercent: CGFloat = 193
    
    @IBOutlet weak var yesPercentageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noPercentageHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var pollStatusLabel: UILabel!
    
    var question = Question()
    var otherQuestions = 0
    var questions = [Question]()
    var comments = [Comment]()
    
    var sortedComments: [Comment] {
        if sortComments {
            comments = comments.sort({ $0.upVotes == $1.upVotes ? $0.date > $1.date : $0.upVotes > $1.upVotes })
            return comments
        } else {
            return comments
        }
    }
    
    // comments.sort({ $0.upVotes > $1.upVotes })
    
    var sortComments = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        automaticallyAdjustsScrollViewInsets = false
        pollStatusLabel.text = question.question.uppercaseString
        
        tableView.registerNib(UINib(nibName: ResultsHeaderView.ip_nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsHeaderView.ip_nibName)
        tableView.registerNib(UINib(nibName: ResultsArticleTableViewCell.ip_nibName, bundle: nil), forCellReuseIdentifier: ResultsArticleTableViewCell.ip_nibName)
        tableView.registerNib(UINib(nibName: CommentInputTableViewCell.ip_nibName, bundle: nil), forCellReuseIdentifier: CommentInputTableViewCell.ip_nibName)
        tableView.registerNib(UINib(nibName: CommentTableViewCell.ip_nibName, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.ip_nibName)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tapOutsideOfTextView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapOutsideOfTextView.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutsideOfTextView)
        
        QuestionManager.sharedManager.getCommentsForQuestion(question) { error in
            if error != nil {
                print("error getting latest comments!")
            } else {
                self.comments = self.question.comments
                self.tableView.reloadData()
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setPollResults()
    }
    
    func setPollResults() {
        let totalVotes = question.yesVotes + question.noVotes
        guard totalVotes > 0 else {
            showNoResults()
            return
        }
        
        let yesPercentage = CGFloat(question.yesVotes) / CGFloat(totalVotes)
        let noPercentage = CGFloat(question.noVotes) / CGFloat(totalVotes)
        
        let yesHeightConstraint = kOneHundredPercent * yesPercentage
        let noHeightConstraint = kOneHundredPercent * noPercentage
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .PercentStyle
        numberFormatter.minimumFractionDigits = 0
        yesPercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(yesPercentage)))
        noPercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(noPercentage)))
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(2.0) {
            self.yesPercentageHeightConstraint.constant = yesHeightConstraint
            self.noPercentageHeighConstraint.constant = noHeightConstraint
            self.yesPercentageLabel.alpha = 1
            self.noPercentageLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func showNoResults() {
        yesPercentageLabel.text = "0%"
        noPercentageLabel.text = "0%"
        yesPercentageLabel.alpha = 1
        noPercentageLabel.alpha = 1
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return question.articles.count
        } else {
            return sortedComments.count + 1
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView =  tableView.dequeueReusableHeaderFooterViewWithIdentifier(ResultsHeaderView.ip_nibName) as! ResultsHeaderView
        if section == 0 {
            headerView.titleLabel.text = "Related Articles".uppercaseString
        } else {
            headerView.titleLabel.text = "Comments".uppercaseString
        }
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ResultsArticleTableViewCell.ip_nibName) as! ResultsArticleTableViewCell
            cell.configureForArticle(question.articles[indexPath.row])
            return cell
        } else {
            if indexPath.row == 0 {
                // return commentInputCell
                let cell = tableView.dequeueReusableCellWithIdentifier(CommentInputTableViewCell.ip_nibName, forIndexPath: indexPath) as! CommentInputTableViewCell
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(CommentTableViewCell.ip_nibName, forIndexPath: indexPath) as! CommentTableViewCell
                cell.configureWithComment(sortedComments[indexPath.row - 1])
                cell.delegate = self
                return cell
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let articleVC = ArticleViewController.ip_fromNib()
            articleVC.article = question.articles[indexPath.row]
            self.navigationController?.pushViewController(articleVC, animated: true)
        }
    }
    
    @IBAction func xButtonTapped() {
        navigationController?.pop(transitionType: kCATransitionFade, duration: 0.5)
    }
    
    // MARK: CommentInputDelegate
    
    func commentSubmitButtonTappedWithComment(comment: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            SVProgressHUD.show()
        }
        QuestionManager.sharedManager.writeComment(comment, forQuestion: self.question) { error in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                SVProgressHUD.dismiss()
            }
            if error != nil {
                print(error)
            } else {
                self.sortComments = false
                self.comments = self.question.comments
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Automatic)
                print("comment submitted!")
            }
        }
    }
    
    func tooManyCharactersError() {
        presentViewController(UIAlertController.alertWithTitle("Too Many Characters", message: "We really want you to share your thoughts, but the max character count is 2000."), animated: true, completion: nil)
    }
    
    // MARK: CommentUpVoteDelegate
    
    func upVoteButtonTapped() {
        print("tapped")
    }
    
}
