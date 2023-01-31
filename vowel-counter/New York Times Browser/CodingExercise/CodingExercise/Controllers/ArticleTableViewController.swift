//
//  ArticleTableViewController.swift
//  CodingExercise
//
//  Created by James Hickman on 8/19/15.
//  Copyright (c) 2015 Hotel Tonight. All rights reserved.
//

import UIKit

@objc class ArticleTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate
{
    let cellHeight: CGFloat = 150.0
    let cellIdentifier = "ArticleTableViewCellIdentifier"
    
    var searchController = UISearchController(searchResultsController: nil)
    var articles = [Article]()
    var currentPage = 0
    var currentTerm = ""
    var blockOperations = [NSBlockOperation]()
    var webViewController: WebViewController!
    var tapGestureRecognizer: UITapGestureRecognizer!

    // MARK: Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Navigation Bar Init
        let navImageView = UIImageView(image: UIImage(named: "Logo"))
        navImageView.frame = CGRectMake(0, 0, 100, 30)
        navImageView.contentMode = UIViewContentMode.ScaleAspectFit
        navigationItem.titleView = navImageView

        // TableView Init
        tableView.tableFooterView = UIView(frame: CGRectZero) // Hide empty cells
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.registerClass(ArticleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorColor = UIColor.lightGrayColor()
        // Pull to load more articles
        tableView.addInfiniteScrollingWithActionHandler {[weak self] () -> Void in
            if let weakSelf = self
            {
                weakSelf.currentPage++
                weakSelf.downloadArticlesForTerm(weakSelf.currentTerm, completion: { (data) -> Void in
                    if let data = data, let articles = weakSelf.parseArticleData(data)
                    {
                        // Append new articles to existing
                        weakSelf.articles += articles
                        weakSelf.reloadData()
                    }
                    else
                    {
                        weakSelf.displayAlert()
                    }
                })
            }
        }
        
        // Search Controller Init
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        // Tap Gesture Recognizer Init
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapView:")
        tapGestureRecognizer.cancelsTouchesInView = false // Ensure tableView cell can be tapped
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Disable the UISearchController (bug when search controller is active and you push new view controller, then rotate pushed view controller and come back, search bar is concealed under navigation bar)
        searchController.active = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    
        articles = []
        cancelBlockOperations()
    }
    
    // MARK: NY Times API
    func downloadArticlesForTerm(term: String, completion: (data: NSDictionary?) -> Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {[weak self] () -> Void in
            if let weakSelf = self
            {
                // Show loading indicator
                weakSelf.showActivityIndicator()

                // Build API Query
                var urlString = Constant.NYTimesApiQueryString()
                urlString += "q="+term.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                urlString += "&fl="+Constant.NYTimesApiFieldsKey() // Limit API response to only fields we need (i.e. url, headline, thumbnail) to help lighten payload
                urlString += "&page="+String(weakSelf.currentPage)
                urlString += "&api-key="+Constant.NYTimesApiKey()
                
                if let url = NSURL(string: urlString), let data = NSData(contentsOfURL: url)
                {
                    var error: NSError?
                    if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as? NSDictionary
                    {
                        completion(data: json)
                    }
                    else
                    {
                        completion(data: nil)
                        weakSelf.displayAlert()
                    }
                    weakSelf.hideActivityIndicator()
                }
                else
                {
                    completion(data: nil)
                    weakSelf.hideActivityIndicator()
                    weakSelf.displayAlert()
                }
            }
        })
    }
    
    func parseArticleData(data: NSDictionary) -> [Article]?
    {
        if let response = data[Constant.NYTimesApiResponseKey()] as? [String: AnyObject], let docs = response[Constant.NYTimesApiResponseDocsKey()] as? [AnyObject]
        {
            // Check for empty data (i.e. no articles found for search term)
            if docs.count == 0
            {
                return []
            }
            
            // Iterate each article's JSON data and build Article objects
            var articles = [Article]()
            for articleData in docs as! [[String: AnyObject]]
            {
                let title = ((articleData[Constant.NYTimesApiHeadlineKey()] as! [String: AnyObject])[Constant.NYTimesApiHeadlineMainKey()] as! String).decodedHtmlString()
                let urlString = articleData[Constant.NYTimesApiUrlKey()] as! String
                
                // Check for thumbnail image
                var thumbnailUrlString: String?
                if let multimedia = articleData[Constant.NYTimesApiMultimediaKey()] as? [[String: AnyObject]]
                {
                    if multimedia.count > 0
                    {
                        let urlString = (multimedia[0])[Constant.NYTimesApiMultimediaUrlKey()] as? String
                        thumbnailUrlString = urlString
                    }
                }
                let article = Article(title: title, urlString: urlString, thumbnailUrlString: thumbnailUrlString)
                articles.append(article)
            }
            return articles
        }
        return nil
    }
    
    func displayAlert()
    {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let weakSelf = self
            {
                var alertController = UIAlertController(title: "OOPS!", message: "Looks like there was a problem downloading the articles. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(okAction)
                weakSelf.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: UITableViewControllerDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return articles.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ArticleTableViewCell!
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? ArticleTableViewCell
        {
            cell = dequeuedCell
        }
        else
        {
            cell = ArticleTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        // Load article data
        cell.loadWithArticle(articles[indexPath.row])
        
        return cell
    }
    
    // MARK: UITableViewControllerDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ArticleTableViewCell
        presentWebViewControllerForArticle(cell.article)
    }
    
    // MARK: UIScrollViewDelegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        // Hide keyboard once user starts scrolling through results
        dismissKeyboard()
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        // Search
        searchArticlesForTerm(searchBar.text)
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // Search while typing 
        /* DISABLED - Uncomment to enable API calls while typing */
        //searchArticlesForTerm(searchController.searchBar.text, withDelay:1.0)
    }
    
    // MARK: DZNEmptyDataSetSource
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor!
    {
        return Constant.lightGrayColor()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return Constant.newspaperIconImage()
    }
    
    // MARK: DZNEmptyDataSetDelegate
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString!
    {
        return NSAttributedString(string: "No Articles", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString!
    {
        var string = "Search for articles above."
        if currentTerm != ""
        {
            string = "Nothing found for \"\(currentTerm)\""
        }
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    }
    
    
    // MARK: WebViewController
    func presentWebViewControllerForArticle(article: Article)
    {
        webViewController = WebViewController()
        webViewController.article = article
        
        // Build navigation bar
        var backBarButton = UIBarButtonItem(image: Constant.arrowLeftImage(), style: .Plain, target: self, action: "didTapCloseButton")
        webViewController.navigationItem.leftBarButtonItem = backBarButton
        webViewController.navigationItem.title = article.title
        
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didTapCloseButton()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Helper functions
    func didTapView(sender: UITapGestureRecognizer)
    {
        dismissKeyboard()
    }
    
    func dismissKeyboard()
    {
        searchController.resignFirstResponder()
        searchController.view.endEditing(true)
    }
    
    func searchArticlesForTerm(term: String, withDelay: Double = 0.0)
    {
        // Ignore blank text or same search term
        if term == "" || term == currentTerm
        {
            return
        }
        
        // Use an NSBlockOperation to allow aborting of API calls (i.e. user calls multiple searches rapidly)
        cancelBlockOperations()
        
        var searchBlockOperation = NSBlockOperation()
        searchBlockOperation.addExecutionBlock {[weak self] () -> Void in
            if let weakSelf = self
            {
                // Check if cancelled
                if searchBlockOperation.cancelled
                {
                    return
                }
                
                // Reset
                weakSelf.currentPage = 0
                weakSelf.currentTerm = term
                weakSelf.downloadArticlesForTerm(weakSelf.currentTerm, completion: { (data) -> Void in
                    if let data = data, let articles = weakSelf.parseArticleData(data)
                    {
                        weakSelf.articles = articles
                        weakSelf.reloadData()
                    }
                    else
                    {
                        weakSelf.displayAlert()
                    }
                })
            }
        }
        blockOperations.append(searchBlockOperation)
        
        // Delay calling API (i.e. for auto-search while typing)
        Constant.delay(withDelay, closure: { () -> () in
            searchBlockOperation.start()
        })
    }
    
    func reloadData()
    {
        // Update TableView
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let weakSelf = self
            {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.infiniteScrollingView.stopAnimating()
                if weakSelf.currentPage == 0
                {
                    // Scroll to top if there are new results
                    if weakSelf.articles.count > 0
                    {
                        weakSelf.searchController.active = false
                        weakSelf.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
                    }
                }
                weakSelf.hideActivityIndicator()
            }
        })
    }

    func cancelBlockOperations()
    {
        for blockOperation in blockOperations
        {
            blockOperation.cancel()
        }
        blockOperations.removeAll()
    }
    
    func showActivityIndicator()
    {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let weakSelf = self
            {
                MBProgressHUD.hideHUDForView(weakSelf.view, animated: true)
                MBProgressHUD.showHUDAddedTo(weakSelf.view, animated: true)
            }
        })
    }
    
    func hideActivityIndicator()
    {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let weakSelf = self
            {
                MBProgressHUD.hideHUDForView(weakSelf.view, animated: true)
            }

        })
    }
    
}

@objc class Article: NSObject
{
    var title: String!
    var url: NSURL!
    var thumbnailUrl: NSURL?
    
    init(title: String, urlString: String, thumbnailUrlString: String?)
    {
        super.init()
        self.title = title
        self.url = NSURL(string: urlString)
        if let thumbString = thumbnailUrlString, let thumbUrl = NSURL(string: Constant.NYTimesDomain()+thumbString)
        {
            self.thumbnailUrl = thumbUrl
        }
    }
}

