//
//  ResultsArticleTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/9/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit
import SDWebImage

class ResultsArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleThumbnailImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleLedeLabel: UILabel!
    
    func configureForArticle(article: Article) {
        articleTitleLabel.text = article.title
        articleLedeLabel.text = article.lede
        articleThumbnailImageView.layer.cornerRadius = articleThumbnailImageView.frame.size.width / 2

        if let imageURL = NSURL(string: article.thumbnailURLString) {
            articleThumbnailImageView.sd_setImageWithURL(imageURL)
        }
    }
    
}
