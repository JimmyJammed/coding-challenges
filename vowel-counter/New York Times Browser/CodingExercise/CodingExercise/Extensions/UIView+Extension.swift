//
//  UIView+Extension.swift
//  CodingExercise
//
//  Created by James Hickman on 8/19/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import UIKit

extension UIView
{    
    /// Add a subview to a view, and set it's constraints to fill the superview.
    ///
    /// :param: subview UIView to add and constrain as subview.
    func addSubviewWithFillConstraints(subview: UIView)
    {
        addSubview(subview)
        subview.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let topConstraint = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        addConstraints([topConstraint,bottomConstraint,leftConstraint,rightConstraint])
    }
}