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

class ResultsViewController: UITableViewController {

    @IBOutlet weak var yesPercentageLabel: UILabel!
    @IBOutlet weak var noPercentageLabel: UILabel!
    
    // A height constant of 193 == 100%
    let kOneHundredPercent: CGFloat = 193
    
    @IBOutlet weak var yesPercentageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noPercentageHeighConstraint: NSLayoutConstraint!
    
    var question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerNib(UINib(nibName: ResultsHeaderView.ip_nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsHeaderView.ip_nibName)
        tableView.registerNib(UINib(nibName: ResultsArticleTableViewCell.ip_nibName, bundle: nil), forCellReuseIdentifier: ResultsArticleTableViewCell.ip_nibName)
        
        FIRDatabase.database().reference().child("questions/").observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.childrenCount)
//            if let question = snapshot.value as? [String: AnyObject] {
//                self.question = Question(questionDictionary: question, withDate: NSDate())
//                self.getArticles()
//            }
        }) { error in
            print(error)
        }
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
        guard totalVotes > 0 else { return }
        
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
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return question.articles.count
        } else {
            return question.articles.count
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView =  tableView.dequeueReusableHeaderFooterViewWithIdentifier(ResultsHeaderView.ip_nibName) as! ResultsHeaderView
        if section == 1 {
            headerView.titleLabel.text = "More Questions"
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
//            FIRDatabase.database().reference().child("questions/\(NSDate().currentDateInDayMonthYear())").observeSingleEventOfType(.Value, withBlock: { snapshot in
//                if let question = snapshot.value as? [String: AnyObject] {
//                    self.question = Question(questionDictionary: question, withDate: NSDate())
//                    self.getArticles()
//                }
//            }) { error in
//                print(error)
//            }
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let articleVC = ArticleViewController.ip_fromNib()
        articleVC.article = question.articles[indexPath.row]
        self.navigationController?.pushViewController(articleVC, animated: true)
    }
    
    @IBAction func xButtonTapped() {
        self.navigationController?.pop(transitionType: kCATransitionFade, duration: 0.5)
    }
    
}
