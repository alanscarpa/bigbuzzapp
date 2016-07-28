//
//  OtherQuestionsViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/27/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

class OtherQuestionsViewController: UICollectionViewController {
    
    private let cellName = "OtherQuestionsCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let cellNib = UINib(nibName: cellName, bundle: nil)
        collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: cellName)

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 99
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellName, forIndexPath: indexPath)
        
        var colorNumber = indexPath.row + 1
        if colorNumber % 6 > 0 {
            colorNumber = colorNumber % 6
        }
        if colorNumber % 6 == 0 {
            cell.backgroundColor = UIColor.blueColor()
        } else if colorNumber % 5 == 0 {
            cell.backgroundColor = UIColor.greenColor()
        } else if colorNumber % 4 == 0 {
            cell.backgroundColor = UIColor.redColor()
        } else if colorNumber % 3 == 0 {
            cell.backgroundColor = UIColor.whiteColor()
        } else if colorNumber % 2 == 0 {
            cell.backgroundColor = UIColor.orangeColor()
        } else {
            cell.backgroundColor = UIColor.purpleColor()
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(self.view.frame.width / 2, self.view.frame.width / 2)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
