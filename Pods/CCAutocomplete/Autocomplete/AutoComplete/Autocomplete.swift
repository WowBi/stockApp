//
//  Autocomplete.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit
public class Autocomplete {
    public class func setupAutocompleteForViewcontroller<T: UIViewController where T: AutocompleteDelegate>(viewController: T) {

        let podBundle: NSBundle = NSBundle(forClass: Autocomplete.self)

        let storyboard = UIStoryboard(name: "Autocomplete", bundle: podBundle)
        let autoCompleteViewController = storyboard.instantiateViewControllerWithIdentifier("autocompleteScene") as! AutoCompleteViewController
        
        autoCompleteViewController.delegate = viewController

        autoCompleteViewController.willMoveToParentViewController(viewController)
        viewController.addChildViewController(autoCompleteViewController)
        autoCompleteViewController.didMoveToParentViewController(viewController)

        autoCompleteViewController.view.willMoveToSuperview(viewController.view)
        viewController.view.addSubview(autoCompleteViewController.view)
        autoCompleteViewController.view.didMoveToSuperview()

    }
}
