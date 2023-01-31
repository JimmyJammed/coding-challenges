//
//  WebViewController.swift
//  CodingExercise
//
//  Created by James Hickman on 8/19/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate
{
    let navigationToolbarHeight: CGFloat = 50.0

    var webView = WKWebView()
    var progressView = UIProgressView()
    var article: Article!
    var toolbar = UIToolbar()
    var previousButton: UIBarButtonItem!
    var nextButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // NOTE - Since setting layout programmatically, safest to do all UI inits in 'viewWillAppear' or 'viewDidAppear' to get proper frame values.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // WKWebView Init
        webView.navigationDelegate = self
        webView.frame = view.bounds
        view.addSubviewWithFillConstraints(webView)
        
        // Load Progress View
        progressView.frame = CGRectMake(0, 0, view.bounds.width, 1.0)
        progressView.progress = 0.05
        progressView.progressTintColor = UIColor.blackColor()
        view.addSubview(progressView)
        progressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let topProgressConstraint = NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        let leftProgressConstraint = NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let rightProgressConstraint = NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        view.addConstraints([topProgressConstraint, leftProgressConstraint, rightProgressConstraint])
        // Add Progress Observer
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
        // Toolbar
        toolbar.frame = CGRectMake(0, 0, 0, 0)
        toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
        toolbar.backgroundColor = UIColor.lightGrayColor()
        toolbar.tintColor = UIColor.darkGrayColor()
        view.insertSubview(toolbar, aboveSubview: webView)
        // Constraints
        let bottomConstraint = NSLayoutConstraint(item: toolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: toolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: toolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: toolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: navigationToolbarHeight)
        view.addConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        // Toolbar Buttons
        previousButton = UIBarButtonItem(image: Constant.arrowLeftImage(), style: .Plain, target: self, action: "didTapPreviousButton")
        var fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 20.0
        nextButton = UIBarButtonItem(image: Constant.arrowRightImage(), style: .Plain, target: self, action: "didTapNextButton")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "didTapShareButton")
        toolbar.items = [previousButton, fixedSpace, nextButton, flexibleSpace, shareButton]
        updateNavigationBar()
        
        // Load Request
        if let url = article.url
        {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Remove Progress Observer
        webView.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "estimatedProgress" && object as! NSObject == webView
        {
            updateProgressForWebView(webView)
        }
    }
    
    // MARK: WKNavigationDelegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void)
    {
        updateNavigationBar()
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!)
    {
        updateNavigationBar()
    }
    
    // MARK: Progress View
    func updateProgressForWebView(webView: WKWebView)
    {
        if webView.estimatedProgress <= 0.8
        {
            progressView.hidden = false
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
                if let weakSelf = self
                {
                    weakSelf.progressView.setProgress(1.0, animated: true)
                    UIView.animateWithDuration(1.0, delay: 2.0, options: .CurveEaseOut, animations: { () -> Void in
                        weakSelf.progressView.alpha = 0.0
                        }, completion: { (finished) -> Void in
                            if finished
                            {
                                weakSelf.progressView.hidden = true
                                weakSelf.progressView.alpha = 1.0
                                weakSelf.progressView.progress = 0.05
                            }
                    })
                }
            })
        }
    }
    
    // MARK: Navigation Toolbar
    func updateNavigationBar()
    {
        // Update toolbar navigation buttons
        if webView.canGoBack
        {
            previousButton.enabled = true
        }
        else
        {
            previousButton.enabled = false
        }
        
        if webView.canGoForward
        {
            nextButton.enabled = true
        }
        else
        {
            nextButton.enabled = false
        }
    }
    
    func didTapPreviousButton()
    {
        webView.goBack()
    }
    
    func didTapNextButton()
    {
        webView.goForward()
    }
    
    func didTapShareButton()
    {
        // Create item list
        var items: [AnyObject] = [article.title+"\n\n"+article.url.absoluteString!]

        // Generate a thumbnail for use with share controller
        if let thumbnailUrl = article.thumbnailUrl
        {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            var imageView = UIImageView() // Dummy imageView to generate image from url
            imageView.sd_setImageWithURL(thumbnailUrl, completed: {[weak self] (image, error, cacheType, url) -> Void in
                if let weakSelf = self
                {
                    MBProgressHUD.hideHUDForView(weakSelf.view, animated: true)
                    if let thumbnail = image
                    {
                        items.append(thumbnail)
                    }
                    weakSelf.displayShareControllerWithItems(items)
                }
            })
        }
        else
        {
            displayShareControllerWithItems(items)
        }
    }
    
    func displayShareControllerWithItems(items: [AnyObject])
    {
        var activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = shareButton.valueForKey("view") as! UIView // iPad requires anchor point for UIActivityViewController (or crashes)
        presentViewController(activityViewController, animated: true, completion: nil)
    }    
}
