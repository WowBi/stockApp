//
//  ViewController.swift
//  stockApp
//
//  Created by WangBi on 4/14/16.
//  Copyright © 2016 Bi Wang. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import CCAutocomplete
import MJAutoComplete
import MLPAutoCompleteTextField
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate, AutocompleteDelegate {
    
    var refreshTimer: NSTimer?
    var searchedStock: [String:AnyObject]?
    var symbol: String?
    var autoSymbols = [String]()
    var keySearch: Bool = false
    var validation: Bool = false
    var selectRow: Bool = false
    var isFirstLoad: Bool = true
    var fetchedCompany = [Company]()
    let moc = DataController().managedObjectContext
    var autoCompleteViewController: AutoCompleteViewController!
    
    
    @IBOutlet weak var inputText: UITextField!
    
    @IBOutlet weak var autoRefresh: UISwitch!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favoriteTableView: UITableView!
    
    
    @IBAction func autoRefreshTapped(sender: AnyObject) {
        if autoRefresh.on {
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ViewController.refresh), userInfo: nil, repeats: true)
        } else {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        refresh()
    }

    //Get Quote -> show stock details
    @IBAction func getQuote(sender: AnyObject) {
        
        inputText.resignFirstResponder()
        if inputText.text == "" {
            keySearch = false
            let alert = UIAlertController(title: "", message: "Please Enter a Stock Name or Symbol.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
    
        //check symbols with length < 3
        if inputText.text?.characters.count < 3 {
            print(inputText.text?.characters.count)
            autoCompleteItemsForSearchTerm(inputText.text!)
        }
        
        var tempInput = inputText.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        tempInput = tempInput.uppercaseString
        
        if autoSymbols.contains(tempInput) {
            
            validation = true
        }
        
        if validation {
            
            symbol = tempInput
            self.searchedStock = callQuoteAPI(symbol!)
            let status = self.searchedStock!["Status"] as! String
            if status == "Failure|APP_SPECIFIC_ERROR" {
                keySearch = false
                let alert = UIAlertController(title: "", message: "Invalid Symbol", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                if keySearch {
                    self.performSegueWithIdentifier("CurrentView", sender: self)
                }
            }
            
        } else {
            
            keySearch = false
            let alert = UIAlertController(title: "", message: "Invalid Symbol", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func refresh(){
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.favoriteTableView.reloadData()
        NSTimer.scheduledTimerWithTimeInterval(1.1, target: self, selector: #selector(ViewController.hideIND), userInfo: nil, repeats: false)
    }
    
    func hideIND(timer : NSTimer) {
        activityIndicator.hidden = true
    }
    
    //text field autocomplete
    func autoCompleteTextField() -> UITextField {
        return self.inputText
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        
        self.autoSymbols.removeAll()
        
        let trimmedTerm = term.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        
        //let phrase = "Test case"
        let range = trimmedTerm.rangeOfCharacterFromSet(whitespace)
        
        // range will be nil if no whitespace is found
        if range != nil {
            return [AutocompletableOption]()
        }
        
        let urlString: String = "https://aabbccwe1314.appspot.com/index.php?lookup=\(trimmedTerm)"
        var apiResults: [AnyObject]?
        
        //Construct NSURL object
        let url: NSURL! = NSURL(string:urlString)
        
        //Construct request object
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        
        let semaphore = dispatch_semaphore_create(0)
        
        let dataTask = session.dataTaskWithRequest(request,
                                                   completionHandler: {(data, response, error) -> Void in
                                                    if error != nil{
                                                        print(error?.code)
                                                        print(error?.description)
                                                    } else {
                                                        let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                        let jsonStr = str as! String
                                                        let data = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                                                        do {
                                                            apiResults = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [AnyObject]
                                                            
                                                        } catch let error as NSError {
                                                            print("Failed to load: \(error.localizedDescription)")
                                                        }
                                                    }
                                                    dispatch_semaphore_signal(semaphore)
        }) as NSURLSessionTask
        
        //initialize task by calling resume
        dataTask.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        var lookupResults = [String]()
        
        if apiResults?.count == 0 {
            return [AutocompletableOption]()
        }
        
        for aResult in apiResults! {
            lookupResults.append("\(aResult["Symbol"])-\(aResult["Name"])-\(aResult["Exchange"])")
            self.autoSymbols.append("\(aResult["Symbol"])")
            
        }
        
        let companies: [AutocompletableOption] = lookupResults.map{ ( let company) -> AutocompleteCellData in
            return AutocompleteCellData(text: company, image: UIImage(named: company))
            }.map({$0 as AutocompletableOption})
        
        return companies
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    func didSelectItem(item: AutocompletableOption) {
        validation = true
        inputText.text = item.text.characters.split{$0 == "-"}.map(String.init)[0]
    }

    func callQuoteAPI(sym: String) -> [String: AnyObject]{
        
        let urlString: String = "https://aabbccwe1314.appspot.com/index.php?searchSymbol=\(sym)"
        var json: [String: AnyObject]?
        
        //Construct NSURL object
        let url: NSURL! = NSURL(string:urlString)
        
        //Construct request object
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        
        let semaphore = dispatch_semaphore_create(0)
        
        let dataTask = session.dataTaskWithRequest(request,
                                                   completionHandler: {(data, response, error) -> Void in
                                                    if error != nil {
                                                        print(error?.code)
                                                        print(error?.description)
                                                    } else {
                                                        let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                        let jsonStr = str as! String
                                                        let data = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                                                        do {
                                                            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
                                                            //print(json)
                                                            
                                                        } catch let error as NSError {
                                                            print("Failed to load: \(error.localizedDescription)")
                                                        }
                                                    }
                                                    dispatch_semaphore_signal(semaphore)
        }) as NSURLSessionTask
        
        //initialize task by calling resume
        dataTask.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return json!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.inputText.resignFirstResponder()
        keySearch = true
        getQuote(self)
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let companyFetch = NSFetchRequest(entityName:"Company")
        
        do {
            fetchedCompany = try moc.executeFetchRequest(companyFetch) as! [Company]

        }catch {
            fatalError("Bad things happen \(error)")
        }

        return fetchedCompany.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteTableViewCell", forIndexPath: indexPath) as! FavoriteTableViewCell
        let currCompany = fetchedCompany[indexPath.row]
        let searchedCompany:[String: AnyObject] = callQuoteAPI(currCompany.symbol!)
        
        cell.symbolLabel.text = searchedCompany["Symbol"] as? String
        cell.priceLabel.text = "$" + String(searchedCompany["LastPrice"] as! Float)
        let change = String(format: "%.2f", (searchedCompany["Change"] as? Float)!)
        let changePercent = String(format: "%.2f", (searchedCompany["ChangePercent"] as? Float)!)
        
       if Double(change) < 0 || Double(changePercent) < 0 {
            cell.changeLabel.backgroundColor = UIColor(red: 0.9, green: 0.31, blue: 0.28, alpha: 1)
            cell.changeLabel.text = String(change) + "(\(changePercent)%)"
        } else {
            if Double(change) > 0 {
                cell.changeLabel.text = "+" + String(change) + "(\(changePercent)%)"
            } else {
                //change =0 , no '+'
                cell.changeLabel.text = String(change) + "(\(changePercent)%)"
            }
        
            cell.changeLabel.backgroundColor = UIColor(red: 0.22, green: 0.67, blue: 0.40, alpha: 1)
        }
        
  
        cell.nameLabel.text = searchedCompany["Name"] as? String
        
        let marketCap = searchedCompany["MarketCap"] as! Float
        let BILLIONVALUE: Float = 1000000000
        let MILLIONVALUE: Float = 1000000
        var capString: String?
        
        if marketCap > BILLIONVALUE {
            capString = String(format: "%.2f", marketCap/BILLIONVALUE)+" Billion"
        } else if marketCap > MILLIONVALUE {
            capString = String(format: "%.2f", marketCap/MILLIONVALUE)+" Million"
        } else {
            capString = String(format: "%.2f", marketCap)
        }
        cell.capLabel.text = "Market Cap: \(capString!)"

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! FavoriteTableViewCell
            let selectedSymbol = currentCell.symbolLabel.text
            //delete row data
            for oneCompany in self.fetchedCompany {
                if (oneCompany.symbol == selectedSymbol) {
                    self.moc.deleteObject(oneCompany)
                    do {
                        try self.moc.save()
                    }catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! FavoriteTableViewCell
        let selectedSymbol = currentCell.symbolLabel.text
        self.searchedStock = callQuoteAPI(selectedSymbol!)
        self.performSegueWithIdentifier("CurrentView", sender: indexPath)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        inputText.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.hideIND), userInfo: nil, repeats: false)
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return validation
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let currentScene = segue.destinationViewController as! CurrentViewController
        currentScene.currStock = self.searchedStock
        
    }
    
}
