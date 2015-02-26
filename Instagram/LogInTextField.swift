//
//  logInTextField.swift
//  Instagram
//
//  Created by Yu Andrew - andryu on 2/13/15.
//  Copyright (c) 2015 Andrew Yu. All rights reserved.
//

import Foundation

class LogInTextField: UITextField {
    
    override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 7, y: bounds.origin.y, width: bounds.height-5, height: bounds.height-5)
    }
}
