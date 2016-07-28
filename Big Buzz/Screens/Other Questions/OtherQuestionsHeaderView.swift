//
//  OtherQuestionsHeaderView.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 7/27/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit

protocol OtherQuestionsHeaderViewDelegate: class {
    func backButtonTapped()
}

class OtherQuestionsHeaderView: UICollectionReusableView {

    weak var delegate: OtherQuestionsHeaderViewDelegate?
    
    @IBAction func backButtonTapped() {
        delegate?.backButtonTapped()
    }
}
