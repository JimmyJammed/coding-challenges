//
//  CodingExerciseTests.swift
//  CodingExercise
//
//  Created by James Hickman on 8/22/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import Foundation
import XCTest

class CodingExerciseTest: XCTestCase
{
    let articleTableViewController = ArticleTableViewController()
    let baseTimeOutDuration = 5.0

    override func setUp()
    {
        super.setUp()

    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    /// Test that the NY Times API is currently responding
    func testApiResponds()
    {
        let expectation = expectationWithDescription("testApiResponse")
        let term = "HotelTonight"
        articleTableViewController.downloadArticlesForTerm(term, completion: { (data) -> Void in
            XCTAssertNotNil(data, "API Returned Nil.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(baseTimeOutDuration) { (error) in
            XCTAssertNil(error, "Timeout in \(__FUNCTION__) \(error)")
        }
    }
    
    /// Test that the app can parse a response from the NY Times API
    func testJsonParse()
    {
        let expectation = expectationWithDescription("testJsonParse")
        let term = "HotelTonight"
        articleTableViewController.downloadArticlesForTerm(term, completion: { (data) -> Void in
            if let data = data, let articles = self.articleTableViewController.parseArticleData(data)
            {
                XCTAssertNotNil(articles, "Articles Failed To Parse.")
            }
            else
            {
                XCTFail("Data")
            }
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(baseTimeOutDuration) { (error) in
            XCTAssertNil(error, "Timeout in \(__FUNCTION__) \(error)")
        }
    }
    
}
