//
//  Constant.swift
//  CodingExercise
//
//  Created by James Hickman on 8/19/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import Foundation

class Constant: NSObject
{
    // MARK: NY Times API Keys
    class func NYTimesApiKey() -> String
    {
        return "30a8838f4ec339d29746cbed26b5a8db:5:71852801"
    }
    
    class func NYTimesDomain() -> String
    {
        return "http://nytimes.com/"
    }
    
    class func NYTimesApiQueryString() -> String
    {
        return "http://api.nytimes.com/svc/search/v2/articlesearch.json?"
    }
    
    class func NYTimesApiFieldsKey() -> String
    {
        return "web_url,multimedia,headline"
    }
    
    class func NYTimesApiResponseKey() -> String
    {
        return "response"
    }
    
    class func NYTimesApiResponseDocsKey() -> String
    {
        return "docs"
    }
    
    class func NYTimesApiHeadlineKey() -> String
    {
        return "headline"
    }
    
    class func NYTimesApiHeadlineMainKey() -> String
    {
        return "main"
    }
    
    class func NYTimesApiUrlKey() -> String
    {
        return "web_url"
    }
        
    class func NYTimesApiMultimediaKey() -> String
    {
        return "multimedia"
    }
    
    class func NYTimesApiMultimediaUrlKey() -> String
    {
        return "url"
    }
    
    // MARK: Images
    class func logoImage() -> UIImage
    {
        return UIImage(named: "Logo")!
    }
    
    class func newspaperIconImage() -> UIImage
    {
        return UIImage(named: "NewspaperIcon")!
    }
    
    class func arrowLeftImage() -> UIImage
    {
        return UIImage(named: "ArrowLeft")!
    }
    
    class func arrowRightImage() -> UIImage
    {
        return UIImage(named: "ArrowRight")!
    }
    
    // MARK: Colors
    class func lightGrayColor() -> UIColor
    {
        return UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    }
    
    // MARK: Miscellaneous Functions
    class func delay(delay:Double, closure:()->())
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), closure)
    }
}
