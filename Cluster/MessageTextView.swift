//
//  MessageTextView.swift
//  Cluster
//
//  Created by Michael Fellows on 2/24/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation


// MARK: - MessageTextView

class MessageTextView: UIView {
    
    // MARK: Variables and constants
    
    var textField: UITextField = UITextField.init()
    var sendButton: UIButton = UIButton.init()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let width = self.frame.size.width
        let height = self.frame.size.height
        let textFieldPadding = 5.0 as CGFloat
        let buttonWidth = 60.0 as CGFloat
        let textFieldWidth = width - (3 * textFieldPadding) - buttonWidth
        
        let spacingView = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: 1.0))
        spacingView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.addSubview(spacingView)
        
        let textFieldFrame = CGRect(x: textFieldPadding, y: textFieldPadding, width: textFieldWidth, height: height - (2 * textFieldPadding))
        textField = UITextField.init(frame: textFieldFrame)
        textField.placeholder = "Enter a message..."
        self.addSubview(textField)
        
        sendButton = UIButton.init(type: .custom)
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.frame = CGRect(x: textFieldWidth + (2 * textFieldPadding), y: textFieldPadding, width: buttonWidth, height: height - (2 * textFieldPadding))
        sendButton.setTitleColor(.klusterPurpleColor(), for: UIControlState())
        self.addSubview(sendButton)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero)
    }
}

