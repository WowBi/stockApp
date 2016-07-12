//
//  CurrentViewController.swift
//  stockApp
//
//  Created by WangBi on 4/15/16.
//  Copyright © 2016 Bi Wang. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class CurrentViewController: UIViewController, UITableViewDataSource, FBSDKSharingDelegate {

    let tableTitles = ["Name","Symbol","LastPrice","Change","ChangePercent","Timestamp","MarketCap","Volume","ChangeYTD","ChangePercentYTD","High","Low","Open"]
    
    let displayTitles = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD", "High Price", "Low Price", "Opening Price"]
    
    var currStock: [String:AnyObject]?
    var currSymbol: String?
    var guide: Int = 0
    var symbolExist: Bool = false
    
    let moc = DataController().managedObjectContext
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var currentBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var yahooChart: UIImageView!

    
    @IBAction func FBTapped(sender: AnyObject) {
        
        let currName = self.currStock!["Name"] as? String
        let currPrice = String(format: "%.2f", (self.currStock!["LastPrice"] as? Float)!)
        

            let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
       
            content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=\(self.currSymbol!)")
            content.contentTitle = "Current Stock Price of \(currName!) is $\(currPrice)"
            content.contentDescription = "Stock Information of \(currName!) (\(self.currSymbol!))"
            content.imageURL = NSURL(string: "https://chart.finance.yahoo.com/t?s=\(self.currSymbol!)&lang=en-US&width=450&height=380")
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
       
    }

    @IBAction func starTapped(sender: AnyObject) {
        
        var fetchedCompany=[Company]()
        let companyFetch=NSFetchRequest(entityName:"Company")
        do{
            fetchedCompany=try moc.executeFetchRequest(companyFetch) as! [Company]
            
        }catch{
            fatalError("Bad things happen \(error)")
        }
        
        if self.symbolExist{
            starBtn.setBackgroundImage(UIImage(named: "Star"),forState: UIControlState.Normal)
            
            for oneCompany in fetchedCompany {
                
                if(oneCompany.symbol==currSymbol){
                    
                    self.moc.deleteObject(oneCompany)
                    
                    do{
                        try self.moc.save()
                    }catch{
                        fatalError("Failure to save context: \(error)")
                    }
                    
                }
            }
            self.symbolExist=false
            
        }else{
            starBtn.setBackgroundImage(UIImage(named: "StarFilled"),forState: UIControlState.Normal)
            let entity=NSEntityDescription.insertNewObjectForEntityForName("Company", inManagedObjectContext: moc) as! Company
            
            entity.setValue(currSymbol!, forKey: "symbol")
            
            do{
                try moc.save()
            }catch{
                fatalError("Failure to save context: \(error)")
            }
            self.symbolExist=true
        }
      
    }
    
    @IBAction func historicalBtnTapped(sender: AnyObject) {
        guide=1
        //print("guide: ",guide)
    }
    
    @IBAction func newsBtnTapped(sender: AnyObject) {
        guide=2
        //print("guide: ",guide)
    }
    
    
    func delayMessage(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        
        if results["postId"] != nil {
            print("Posted Successfully!")
            
            let alert = UIAlertController(title: "", message: "Posted Successfully!", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(CurrentViewController.delayMessage), userInfo: nil, repeats: false)
            
            
        } else {
            print("Not Posted.")
            let alert = UIAlertController(title: "", message: "Not Posted ", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(CurrentViewController.delayMessage), userInfo: nil, repeats: false)
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("Fail to post!")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("Cancelled the post")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currSymbol = self.currStock!["Symbol"] as? String
        currentBtn.backgroundColor = self.view.tintColor
        self.navBar.topItem?.title = currSymbol
        var fetchedCompany = [Company]()
        let companyFetch = NSFetchRequest(entityName:"Company")
        
        do {
            fetchedCompany = try moc.executeFetchRequest(companyFetch) as! [Company]
            
        } catch {
            fatalError("Bad things happen \(error)")
        }
        
        for oneCompany in fetchedCompany {
            
            if oneCompany.symbol == self.currSymbol! {
                symbolExist = true
            }
        }
        
        if(symbolExist){
            
            starBtn.setBackgroundImage(UIImage(named: "StarFilled"),forState: UIControlState.Normal)
            
        } else {
            
            starBtn.setBackgroundImage(UIImage(named: "Star"),forState: UIControlState.Normal)
        }

        let yahooURL:String = "https://chart.finance.yahoo.com/t?s=\(currSymbol!)&lang=en-US&width=400&height=300"
        
        if let url = NSURL(string: yahooURL) {
            if let data = NSData(contentsOfURL: url) {
                
                yahooChart.image = UIImage(data: data)
            }        
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CELL_IDENTIFIER = "DetailTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath) as! DetailTableViewCell
        let index = indexPath.row
        let displayKey: String = displayTitles[index]
        let value: String?
        var arrowImage: UIImage?
        
        if displayKey == "Name" {
            
            value = self.currStock!["Name"] as? String
            cell.arrow.removeFromSuperview()
            cell.arrow = nil
            
        }else if displayKey == "Symbol" {
            
            value = self.currStock!["Symbol"] as? String
            
        } else if displayKey == "Last Price" {
            
            let number = self.currStock!["LastPrice"] as! Float
            value = "$" + String(number)
            
        } else if displayKey == "Change" {
            let change = self.currStock!["Change"] as! Float
            let changePercent = self.currStock!["ChangePercent"] as! Float
           
            if change < 0 || changePercent < 0 {
                
                arrowImage = UIImage(named: "Down")
                var changeStr = String(format: "%.2f",change)
                var changePercentStr = String(format: "%.2f",changePercent)
                if change > 0 {
                    changeStr = "+" + changeStr
                }
                if changePercent > 0 {
                    changePercentStr = "+" + changePercentStr
                }
                value = changeStr + "(" + changePercentStr + "%)"
                
            } else if change > 0 && changePercent == 0 {
                
                arrowImage = UIImage(named: "Up")
                value = "+" + String(format: "%.2f",change) + "(" + String(format: "%.2f",changePercent) + "%)"
                
            } else if change == 0 && changePercent > 0 {
                
                arrowImage = UIImage(named: "Up")
                value = String(format: "%.2f",change) + "(+" + String(format: "%.2f",changePercent) + "%)"
                
            } else if change > 0 && changePercent > 0 {
                
                arrowImage = UIImage(named: "Up")
                value = "+" + String(format: "%.2f",change) + "(+" + String(format: "%.2f",changePercent) + "%)"
                
            } else {
                
                cell.arrow.removeFromSuperview()
                cell.arrow = nil
                value = String(format: "%.2f",change)+"("+String(format: "%.2f",changePercent)+"%)"
            }
            
        } else if displayKey == "Time and Date" {
            
            let dateFormatter1 = NSDateFormatter()
            let dateFormatter2 = NSDateFormatter()
            
            let str = self.currStock!["Timestamp"] as? String
            dateFormatter1.dateFormat = "EEE MMMM dd HH:mm:ss zzz yyyy"
            let newDate = dateFormatter1.dateFromString(str!)
            dateFormatter2.dateFormat = "MMMM d yyyy HH:mm"
            value = dateFormatter2.stringFromDate(newDate!)
            cell.arrow.removeFromSuperview()
            cell.arrow = nil

        } else if displayKey == "Market Cap" {
            let marketCap = self.currStock!["MarketCap"] as? Float
            let BILLIONVALUE: Float=1000000000
            let MILLIONVALUE: Float=1000000

            if marketCap > BILLIONVALUE {
                
                value = String(format: "%.2f", marketCap!/BILLIONVALUE) + " Billion"
                
            } else if marketCap > MILLIONVALUE {
                
                value = String(format: "%.2f", marketCap!/MILLIONVALUE) + " Million"
                
            } else {
                value = String(format: "%.2f", marketCap!)
            }
        } else if displayKey == "Volume" {
            
            value = String(self.currStock!["Volume"] as! Int)
            
        } else if displayKey == "Change YTD" {
            let changeYTD = self.currStock!["ChangeYTD"] as! Float
            let changePercentYTD = self.currStock!["ChangePercentYTD"] as! Float
            
            if changeYTD < 0 || changePercentYTD < 0 {
                
                arrowImage = UIImage(named: "Down")
                var changeYTDStr = String(format: "%.2f",changeYTD)
                var changePercentYTDStr = String(format: "%.2f",changePercentYTD)
                if changeYTD > 0 {
                    changeYTDStr = "+" + changeYTDStr
                }
                if changePercentYTD > 0 {
                    changePercentYTDStr = "+" + changePercentYTDStr
                }
                value = changeYTDStr + "(" + changePercentYTDStr + "%)"
                
            } else if changeYTD > 0 && changePercentYTD == 0 {
                
                arrowImage = UIImage(named: "Up")
                value = "+" + String(format: "%.2f",changeYTD) + "(" + String(format: "%.2f",changePercentYTD) + "%)"
                
            } else if changeYTD == 0 && changePercentYTD > 0 {
                
                arrowImage = UIImage(named: "Up")
                value = String(format: "%.2f",changeYTD) + "(+" + String(format: "%.2f",changePercentYTD) + "%)"
                
            } else if changeYTD > 0 && changePercentYTD > 0 {
                
                arrowImage = UIImage(named: "Up")
                value = "+" + String(format: "%.2f",changeYTD) + "(+" + String(format: "%.2f",changePercentYTD)+"%)"
                
            } else {
                
                cell.arrow.removeFromSuperview()
                cell.arrow = nil
                value = String(format: "%.2f",changeYTD) + "(" + String(format: "%.2f",changePercentYTD) + "%)"
            }
        } else if displayKey == "High Price" {
            
            value = "$" + String(self.currStock!["High"] as! Float)
            
        } else if displayKey == "Low Price" {
            
            value = "$" + String(self.currStock!["Low"] as! Float)
            
        } else {
            
            value = "$" + String(self.currStock!["Open"] as! Float)
        }
    
        cell.titleLabel.text = displayKey
        cell.contentLabel.text = value
        
        if cell.arrow != nil {
            
            cell.arrow.image = arrowImage
        }
        cell.titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        myScrollView.contentSize=CGSizeMake(300, 680)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         //Get the new view controller using segue.destinationViewController.
         //Pass the selected object to the new view controller.
        if guide == 1 {
            
            let historicalScene = segue.destinationViewController as! HistoricalViewController
            historicalScene.highSymbol = self.currSymbol
            historicalScene.currStock = self.currStock
            
        } else if guide == 2 {
            
            let newsScene = segue.destinationViewController as! NewsViewController
            newsScene.newsSymbol = self.currSymbol
            newsScene.currStock = self.currStock
            
        } else {
            
            print("Back to main.")
            
        }
    }
}
