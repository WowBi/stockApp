//: Playground - noun: a place where people can play

import UIKit
import CoreData
import Alamofire

import CCAutocomplete
import MJAutoComplete
import MLPAutoCompleteTextField

import Foundation



//let xx="yyyy-MM-dd'T'HH:mm:ssZZZZZ"
////let date=NSDate(str)
let dateFormatter1 = NSDateFormatter()
let dateFormatter2 = NSDateFormatter()

let str="2016-05-03T22:27:38Z"
dateFormatter1.dateFormat = "yyyy-MM-ddEEEEEHH:mm:ssZ"
var newDate = dateFormatter1.dateFromString(str)
dateFormatter2.dateFormat = "MMMM d yyyy HH:mm"
let timeString=dateFormatter2.stringFromDate(newDate!)
print(timeString)
