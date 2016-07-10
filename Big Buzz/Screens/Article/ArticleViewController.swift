//
//  ArticleViewController.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/9/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    var article = Article()
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        title = article.title
        if let url = NSURL(string: article.urlString) {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }

}
