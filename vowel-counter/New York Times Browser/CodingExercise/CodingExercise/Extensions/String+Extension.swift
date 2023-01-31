//
//  String+Extension.swift
//  CodingExercise
//
//  Created by James Hickman on 8/22/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import Foundation

extension String
{
    /// Convert an HTML encoded string to a more readable string.
    ///
    /// :returns: String decoded string.
    func decodedHtmlString() -> String
    {
        let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
        return attributedString.string
    }
}