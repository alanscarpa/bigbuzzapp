//
//  ResultsArticleTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/9/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

class ResultsArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleThumbnailImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleLedeLabel: UILabel!
    
    func configureForArticle(article: Article) {
        articleTitleLabel.text = article.title
        articleLedeLabel.text = article.lede
    }
    
}
