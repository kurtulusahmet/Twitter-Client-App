//
//  TweetTableViewController.swift
//  Tags
//
//  Created by Duc Tran on 10/8/15.
//  Copyright (c) 2015 Kurtulus Ahmet. All rights reserved.
//
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    var tweets = [[Tweet]]()
    
    //baslangicta fenerbahce :D
    var searchText: String? = "fenerbahce" {
        didSet {
            self.lastSuccessfulRequest = nil
            self.searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl?)
    {
        if let searchText = searchText {
            if let request = nextRequestToAttempt {
                // off the main queue
                request.fetchTweets({ (newTweets) -> Void in
                    
                    // go back to the main queue
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                        
                    })
                })
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh()
    {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    // MARK: - View Controller Lifecycle
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // change status bar into white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black

        refresh()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetWithImage = "TweetWithImage"
        static let TweetWithoutImage = "TweetWithoutImage"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let tweet = tweets[indexPath.section][indexPath.row]
        
        //eger tweet in image i varsa TweetWithImage id li cell cagriliyor
        if tweet.media.first?.url != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithImage, forIndexPath: indexPath)  as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithoutImage, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }


}























