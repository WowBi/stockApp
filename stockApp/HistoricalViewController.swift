//
//  HistoricalViewController.swift
//  stockApp
//
//  Created by WangBi on 4/15/16.
//  Copyright © 2016 Bi Wang. All rights reserved.
//

import UIKit
import WebKit

class HistoricalViewController: UIViewController, UIWebViewDelegate {
    
    var highSymbol: String?
    var currStock: [String:AnyObject]?
    var guide: Int = 0
    var webView: WKWebView?
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var loadingIND: UIActivityIndicatorView!
    
    @IBOutlet weak var highChart: UIWebView!
    
    @IBOutlet weak var historicalBtn: UIButton!
    
    @IBAction func currentTapped(sender: AnyObject) {
        guide = 1
    }
    
    @IBAction func newsTapped(sender: AnyObject) {
        guide = 2
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let script = "setHighCharts('\(self.highSymbol!)')"
        highChart.stringByEvaluatingJavaScriptFromString(script)
        loadingIND.hidden = true
        loadingIND.stopAnimating()
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navBar.topItem?.title = self.highSymbol
        historicalBtn.backgroundColor = self.view.tintColor
        loadingIND.hidden = false
        loadingIND.startAnimating()

        let url = NSURL (string: "https://aabbccwe1314.appspot.com/highchart.html");
        let requestObj = NSURLRequest(URL: url!);
        highChart.loadRequest(requestObj);

    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if guide == 1 {
            
            let currentScene = segue.destinationViewController as! CurrentViewController
            currentScene.currSymbol = self.highSymbol
            currentScene.currStock = self.currStock
            
        } else if guide == 2 {
            
            let newsScene = segue.destinationViewController as! NewsViewController
            newsScene.newsSymbol = self.highSymbol
            newsScene.currStock = self.currStock
            
        } else {
            
            print("Back to main.")
            
        }
    }
}
