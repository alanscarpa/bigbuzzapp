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
        return NSDate().dateByAddingTimeInterval(adjustedDaysInSeconds)
    }
    let kNumberOfQuestionsToDownload = 10
    var eligibleToDownloadMoreQuestions = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
    
    func getBatchOfQuestions() {
        var x = 0
        var questionsDownloaded = 0
        while x < kNumberOfQuestionsToDownload {
            QuestionManager.sharedManager.getQuestionForDate(adjustedDate) { (question, error) in
                print(question?.question)
                self.questions.append(question ?? Question())
                questionsDownloaded += 1
                if questionsDownloaded == self.kNumberOfQuestionsToDownload {
                    self.eligibleToDownloadMoreQuestions = true
                    self.collectionView?.reloadData()
                }
            }
            x += 1
            adjustedDays = x
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 99
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > questions.count && eligibleToDownloadMoreQuestions {
            adjustedDays += 1
            getBatchOfQuestions()
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellName, forIndexPath: indexPath)
        
        var colorNumber = indexPath.row + 1
        if colorNumber % 5 > 0 {
            colorNumber = colorNumber % 5
        }
        if colorNumber % 5 == 0 {
            cell.backgroundColor = UIColor.bbRedPink()
        } else if colorNumber % 4 == 0 {
            cell.backgroundColor = UIColor.bbUglyYellow()
        } else if colorNumber % 3 == 0 {
            cell.backgroundColor = UIColor.bbOrangeish()
        } else if colorNumber % 2 == 0 {
            cell.backgroundColor = UIColor.bbVibrantGreen()
        } else {
            cell.backgroundColor = UIColor.bbCyanTwo()
        }
        return cell
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
