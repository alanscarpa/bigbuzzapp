//
//  OtherQuestionsViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/27/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

class OtherQuestionsViewController: UICollectionViewController, OtherQuestionsHeaderViewDelegate {
    
    private let cellName = "OtherQuestionsCollectionViewCell"
    private let headerViewName = "OtherQuestionsHeaderView"
    private var questions = [Question]()
    var adjustedDays = 0
    var adjustedDaysInSeconds: NSTimeInterval {
        return NSTimeInterval(adjustedDays * 86400)
    }
    var adjustedDate: NSDate {
        return NSDate().dateByAddingTimeInterval(-adjustedDaysInSeconds)
    }
    var eligibleToDownloadMoreQuestions = false
    var numberOfQuestionsToDisplay: Int {
        return NSDate.daysBetweenDates(NSDate.dateFromString(kStartDate)!, endDate: NSDate()) + 1
    }
    lazy var statusBarBackgroundView: UIView = {
        let backgroundView = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width,
                height: 20.0)
        )
        backgroundView.backgroundColor = UIColor.whiteColor()
        return backgroundView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: cellName, bundle: nil)
        let headerNib = UINib(nibName: headerViewName, bundle: nil)
        collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: cellName)
        collectionView?.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewName)
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSizeMake(0, 50)
            layout.sectionHeadersPinToVisibleBounds = true
        }
        getBatchOfQuestions()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().keyWindow?.addSubview(statusBarBackgroundView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarBackgroundView.removeFromSuperview()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func getBatchOfQuestions() {
        var questionsDownloaded = 0
        var numberOfQuestionsToDownloadAtATime = 10
        for _ in (0..<numberOfQuestionsToDownloadAtATime) {
            guard adjustedDate > NSDate.dateFromString(kStartDate) else {
                if adjustedDays < numberOfQuestionsToDownloadAtATime {
                    numberOfQuestionsToDownloadAtATime = adjustedDays
                } else {
                    numberOfQuestionsToDownloadAtATime = adjustedDays - numberOfQuestionsToDownloadAtATime
                }
                break
            }
            QuestionManager.sharedManager.getQuestionForDate(adjustedDate) { (question, error) in
                if error != nil {
                    print("error! \(error)")
                } else {
                    self.questions.append(question ?? Question())
                    questionsDownloaded += 1
                    if questionsDownloaded == numberOfQuestionsToDownloadAtATime {
                        self.eligibleToDownloadMoreQuestions = true
                        self.questions.sortInPlace({ $0.date > $1.date })
                        self.collectionView?.reloadData()
                    }
                }
            }
            adjustedDays += 1
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfQuestionsToDisplay
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= questions.count && eligibleToDownloadMoreQuestions {
            eligibleToDownloadMoreQuestions = false
            getBatchOfQuestions()
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellName, forIndexPath: indexPath) as! OtherQuestionsCollectionViewCell
        if indexPath.row < questions.count {
            cell.configureWithQuestion(questions[indexPath.row])
        }
        cell.backgroundColor = UIColor.colorForNumber(indexPath.row)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let resultsVC = ResultsViewController.ip_fromNib()
        resultsVC.question = questions[indexPath.row]
        navigationController?.push(viewController: resultsVC, transitionType: kCATransitionFade, duration: 0.5)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerViewName, forIndexPath: indexPath) as! OtherQuestionsHeaderView
        headerView.delegate = self
        return headerView
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(self.view.frame.width / 2, self.view.frame.width / 2)
    }
    
    // MARK: OtherQuestionsHeaderViewDelegate
    
    func backButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
