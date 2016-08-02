//
//  CommentInputTableViewCell.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/1/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import PureLayout

protocol CommentInputDelegate: class {
    func commentSubmitButtonTappedWithComment(comment: String)
    func tooManyCharactersError()
}

class CommentInputTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    weak var delegate: CommentInputDelegate?
    let submitButton = UIButton()
    let kMaxTextAllowed = 2000
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        
        resetTextView()
        
        let customAccessoryView = UIView(frame: CGRectMake(0, 0, 10, 40))
        customAccessoryView.backgroundColor = UIColor.greenColor()
        
        submitButton.setTitle("SUBMIT", forState: .Normal)
        
        submitButton.setBackgroundColor(UIColor.blueColor(), forUIControlState: .Normal)
        submitButton.setBackgroundColor(UIColor.greenColor(), forUIControlState: .Disabled)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Disabled)
        
        submitButton.addTarget(self, action: #selector(submitButtonTapped), forControlEvents: .TouchUpInside)
        submitButton.enabled = false
        
        customAccessoryView.addSubview(submitButton)
        submitButton.autoPinEdgesToSuperviewEdges()
        
        textView.inputAccessoryView = customAccessoryView
    }
    
    private func resetTextView() {
        textView.text = ""
        textView.placeholder = "SAY SOMETHING..."
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        submitButton.enabled = !textView.text.isEmptyOrWhitespace()
        if textView.text.characters.count > kMaxTextAllowed {
            textView.text = textView.text.substringToIndex(textView.text.startIndex.advancedBy(2000))
            delegate?.tooManyCharactersError()
        }
    }
    
    func submitButtonTapped() {
        textView.resignFirstResponder()
        delegate?.commentSubmitButtonTappedWithComment(textView.text)
        resetTextView()
    }

}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if self.isEmpty {
            return true
        }
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""
    }
}

extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), forState: state)
    }
}
