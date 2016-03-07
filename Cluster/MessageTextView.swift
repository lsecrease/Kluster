//
//  MessageTextView.swift
//  Cluster
//
//  Created by Michael Fellows on 2/24/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class MessageTextView: UIView {
    
    var textField: UITextField = UITextField.init()
    var sendButton: UIButton = UIButton.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .whiteColor()
        
        let width = self.frame.size.width
        let height = self.frame.size.height
        let textFieldPadding = 5.0 as CGFloat
        let buttonWidth = 60.0 as CGFloat
        let textFieldWidth = width - (3 * textFieldPadding) - buttonWidth
        
        let spacingView = UIView.init(frame: CGRectMake(0, 0, width, 1.0))
        spacingView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.addSubview(spacingView)
        
        let textFieldFrame = CGRectMake(textFieldPadding, textFieldPadding, textFieldWidth, height - (2 * textFieldPadding))
        textField = UITextField.init(frame: textFieldFrame)
        textField.placeholder = "Enter a message..."
        self.addSubview(textField)
        
        sendButton = UIButton.init(type: .Custom)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.frame = CGRectMake(textFieldWidth + (2 * textFieldPadding), textFieldPadding, buttonWidth, height - (2 * textFieldPadding))
        sendButton.setTitleColor(.klusterPurpleColor(), forState: .Normal)
        self.addSubview(sendButton)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRectZero)
    }
}

