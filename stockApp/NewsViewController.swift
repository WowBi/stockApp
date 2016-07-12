//
//  NewsViewController.swift
//  stockApp
//
//  Created by WangBi on 4/15/16.
//  Copyright © 2016 Bi Wang. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var newsSymbol: String?
    var currStock: [String:AnyObject]?
    var guide: Int=0
    var newsResult = [AnyObject]()
    
    @IBOutlet weak var navBar: UINavigationBar!
 
    @IBOutlet weak var newsBtn: UIButton!
    
    @IBAction func currentTapped(sender: AnyObject) {
        guide = 1
    }
    
    @IBAction func historicalTapped(sender: AnyObject) {
        guide = 2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResult.count > 4 ? 4:newsResult.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsTableViewCell", forIndexPath: indexPath) as! NewsTableViewCell
        cell.titleLabel.text = self.newsResult[indexPath.row]["Title"]!! as? String
        cell.descriptionLabel.text = self.newsResult[indexPath.row]["Description"]!! as? String
        cell.publisherLabel.text = self.newsResult[indexPath.row]["Source"]!! as? String
        
        let dateFormatter1 = NSDateFormatter()
        let dateFormatter2 = NSDateFormatter()
        
        let str = self.newsResult[indexPath.row]["Date"]!! as? String
        dateFormatter1.dateFormat = "yyyy-MM-ddEEEEEHH:mm:ssZ"
        let newDate = dateFormatter1.dateFromString(str!)
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm"
        cell.dateLabel.text = dateFormatter2.stringFromDate(newDate!)
        cell.titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        cell.titleLabel.numberOfLines = 2
        cell.descriptionLabel.numberOfLines = 4
        cell.publisherLabel.textColor = UIColor.grayColor()
        cell.dateLabel.textColor = UIColor.grayColor()

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        let trimUrl = self.newsResult[indexPath.row]["Url"]!! as? String
        UIApplication.sharedApplication().openURL(NSURL(string: trimUrl!)!)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsBtn.backgroundColor = self.view.tintColor
        self.navBar.topItem?.title = self.newsSymbol!
        
        let key: String = "**********"
        let PasswordString = "\(key):\(key)"
        let PasswordData = PasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = PasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let urlPath: String = "https://aabbccwe1314.appspot.com/index.php?newsquery=\(self.newsSymbol!)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.setValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "GET"
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        let session = NSURLSession(configuration: config)
        let semaphore = dispatch_semaphore_create(0)
        
        session.dataTaskWithURL(url) {(let data, let response, let error) in
            
            if (response as? NSHTTPURLResponse) != nil {
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let jsonStr = dataString as! String
                let thedata = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(thedata, options: []) as! [String: AnyObject]
                    
                    let results = json["d"]!["results"]!!
                    
                    for i in 0 ..< results.count {
                        
                        self.newsResult.append(results[i])
                        
                    }
                    
                } catch let error as NSError {
                    
                    print("Failed to load: \(error.localizedDescription)")
                    
                }
                
                dispatch_semaphore_signal(semaphore)
                
            }
            }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if guide == 1 {
            
            let currentScene = segue.destinationViewController as! CurrentViewController
            currentScene.currSymbol = self.newsSymbol
            currentScene.currStock = self.currStock
            
        } else if guide == 2 {
            
            let historicalScene = segue.destinationViewController as! HistoricalViewController
            historicalScene.highSymbol = self.newsSymbol
            historicalScene.currStock = self.currStock
            
        } else {
            
            print("Back to main.")
            
        }

    }
}
