//
//  Article.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/9/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation

class Article {
    
    var title = ""
    var lede = ""
    var thumbnailURLString = ""
    var urlString = ""
    var id = ""
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    func setUpWithValues(articleDictionary: [String: AnyObject]) {
        if let title = articleDictionary["title"] as? String {
            self.title = title
        }
        if let lede = articleDictionary["lede"] as? String {
            self.lede = lede
        }
        if let thumbnailURLString = articleDictionary["thumbnailURLString"] as? String {
            self.thumbnailURLString = thumbnailURLString
        }
        if let urlString = articleDictionary["urlString"] as? String {
            self.urlString = urlString
        }
    }
}