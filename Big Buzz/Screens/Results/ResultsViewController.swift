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

class ResultsViewController: UITableViewController {

    @IBOutlet weak var agreePercentageLabel: UILabel!
    @IBOutlet weak var disagreePercentageLabel: UILabel!
    
    // A height constant of 193 == 100%
    let kOneHundredPercent: CGFloat = 193
    
    @IBOutlet weak var agreePercentageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var disagreePercentageHeighConstraint: NSLayoutConstraint!
    
    var question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerNib(UINib(nibName: ResultsHeaderView.ip_nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsHeaderView.ip_nibName)
        tableView.registerNib(UINib(nibName: ResultsArticleTableViewCell.ip_nibName, bundle: nil), forCellReuseIdentifier: ResultsArticleTableViewCell.ip_nibName)
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
        
        let agreePercentage = CGFloat(question.yesVotes) / CGFloat(totalVotes)
        let disagreePercentage = CGFloat(question.noVotes) / CGFloat(totalVotes)
        
        let agreeHeightConstraint = kOneHundredPercent * agreePercentage
        let disagreeHeightConstraint = kOneHundredPercent * disagreePercentage
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .PercentStyle
        numberFormatter.minimumFractionDigits = 0
        agreePercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(agreePercentage)))
        disagreePercentageLabel.text = numberFormatter.stringFromNumber(NSNumber(float: Float(disagreePercentage)))
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(2.0) {
            self.agreePercentageHeightConstraint.constant = agreeHeightConstraint
            self.disagreePercentageHeighConstraint.constant = disagreeHeightConstraint
            self.agreePercentageLabel.alpha = 1
            self.disagreePercentageLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
        
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question.articles.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView =  tableView.dequeueReusableHeaderFooterViewWithIdentifier(ResultsHeaderView.ip_nibName)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ResultsArticleTableViewCell.ip_nibName) as! ResultsArticleTableViewCell
        cell.configureForArticle(question.articles[indexPath.row])
        return cell
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
