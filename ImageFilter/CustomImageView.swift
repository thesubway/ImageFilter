//
//  CustomView.swift
//  UseAVFoundation
//
//  Created by Dan Hoang on 8/8/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

@IBDesignable class CustomImageView: UIImageView {

    var currentFilter = CIFilter(name: "CISepiaTone")
    
    @IBInspectable var borderColor: UIColor = UIColor.grayColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

}
